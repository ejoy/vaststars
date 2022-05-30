local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local fs = require "bee.filesystem"
local json = import_package "ant.json"
local archival_base_dir = (fs.appdata_path() / "vaststars/archiving"):string()
local archiving_list_path = archival_base_dir .. "/archiving.json"
local camera_setting_path = archival_base_dir .. "/camera.json"
local iprototype = require "gameplay.interface.prototype"
local startup_entities = import_package("vaststars.prototype")("item.startup").entities
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local ifluid = require "gameplay.interface.fluid"

local irq = ecs.import.interface "ant.render|irenderqueue"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ic = ecs.import.interface "ant.camera|icamera"
local math3d = require "math3d"
local terrain = ecs.require "terrain"
local ieditor = ecs.require "editor.editor"

local MAX_ARCHIVING_COUNT <const> = 9

local archival_relative_dir_list = {}

local function restore_object(gameplay_eid, prototype_name, dir, x, y, fluid_name, fluidflow_network_id)
    local vsobject_type = "constructed"
    local typeobject = iprototype:queryByName("entity", prototype_name)
    local position = assert(terrain.get_position_by_coord(x, y, iprototype:rotate_area(typeobject.area, dir)))

    local vsobject = vsobject_manager:create {
        prototype_name = prototype_name,
        dir = dir,
        position = position,
        type = vsobject_type,
    }
    local object = {
        id = vsobject.id,
        gameplay_eid = gameplay_eid,
        prototype_name = prototype_name,
        dir = dir,
        x = x,
        y = y,
        teardown = false,
        headquater = typeobject.headquater or false,
        fluid_name = fluid_name,
        fluidflow_network_id = fluidflow_network_id,
        state = vsobject_type,
    }
    objects:set(object)
end

local function restore_world()
    -- clean
    for _, object in objects:all() do
        vsobject_manager:remove(object.id)
    end
    objects:clear()

    local duplicate = {}
    local network_id = 0
    local function get_network_id(id)
        if not duplicate[id] then
            network_id = network_id + 1
            duplicate[id] = network_id
        end
        return duplicate[id]
    end

    -- restore
    for v in gameplay_core.select("id:in entity:in fluidbox?in fluidboxes?in") do
        local e = v.entity
        local typeobject = iprototype:query(e.prototype)
        local fluid_name = ""
        local fluidflow_network_id = 0
        if v.fluidbox then
            if v.fluidbox.fluid ~= 0 then
                local typeobject_fluid = assert(iprototype:query(v.fluidbox.fluid))
                fluid_name = typeobject_fluid.name
            else
                fluidflow_network_id = get_network_id(v.fluidbox.id)
            end
        end
        if v.fluidboxes then
            fluid_name = {}
            for id, fluid in pairs(v.fluidboxes) do
                if fluid ~= 0 then
                    local iotype, index = id:match("(%a+)(%d+)%_fluid")
                    if iotype then
                        local classity = ifluid:iotype_to_classity(iotype)
                        local typeobject_fluid = assert(iprototype:query(fluid))

                        fluid_name[classity] = fluid_name[classity] or {}
                        fluid_name[classity][tonumber(index)] = typeobject_fluid.name
                    end
                end
            end
        end
        restore_object(v.id, typeobject.name, iprototype:dir_tostring(e.direction), e.x, e.y, fluid_name, fluidflow_network_id)
    end
end

local function writeall(file, content)
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local function readall(file)
    local f <close> = assert(io.open(file, "rb"))
    return f:read "a"
end

local function get_camera_setting()
    local ce = world:entity(irq.main_camera())
    local t = {
        s = math3d.tovalue(iom.get_scale(ce)),
        r = math3d.tovalue(iom.get_rotation(ce)),
        t = math3d.tovalue(iom.get_position(ce)),
        frustum = ic.get_frustum(ce),
    }
    return t
end

local function restore_camera_setting(camera_setting)
    local ce = world:entity(irq.main_camera())
    iom.set_srt(ce, camera_setting.s, camera_setting.r, camera_setting.t)
    ic.set_frustum(ce, camera_setting.frustum)
end

local M = {}
function M:backup()
    while #archival_relative_dir_list + 1 > MAX_ARCHIVING_COUNT do
        local archival_relative_dir = table.remove(archival_relative_dir_list, 1)
        local archival_dir = archival_base_dir .. ("/%s"):format(archival_relative_dir)
        print("remove", archival_dir)
        fs.remove_all(archival_dir)
    end

    local t = os.date("*t")
    local dn = ("%04d-%02d-%02d-%02d-%02d-%02d"):format(t.year, t.month, t.day, t.hour, t.min, t.sec)
    local archival_dir = archival_base_dir .. ("/%s"):format(dn)

    archival_relative_dir_list[#archival_relative_dir_list + 1] = dn
    gameplay_core.backup(archival_dir)

    writeall(archiving_list_path, json.encode(archival_relative_dir_list))
    writeall(camera_setting_path, json.encode(get_camera_setting()))
    print("save success", archival_dir)
end

function M:restore(index)
    local camera_setting
    if fs.exists(fs.path(camera_setting_path)) then
        camera_setting = json.decode(readall(camera_setting_path))
    end

    --
    if not fs.exists(fs.path(archiving_list_path)) then
        self:restart()
        return
    end
    archival_relative_dir_list = json.decode(readall(archiving_list_path))
    if #archival_relative_dir_list <= 0 then
        self:restart()
        return
    end

    index = index or #archival_relative_dir_list
    if index > #archival_relative_dir_list then
        log.error(("Failed to restore `%s`"):format(index))
        return
    end

    local archival_dir
    while index > 0 do
        local archival_relative_dir = archival_relative_dir_list[index]
        archival_dir = archival_base_dir .. ("/%s"):format(archival_relative_dir)

        if not fs.exists(fs.path(archival_dir)) then
            log.warn(("`%s` not exists"):format(archival_relative_dir))
            archival_relative_dir_list[index] = nil
            index = index - 1
        else
            break
        end
    end

    if index == 0 then
        log.error("Failed to restore")
        return
    end

    gameplay_core.restore(archival_dir)
    gameplay_core.build()
    restore_world()

    if camera_setting then
        restore_camera_setting(camera_setting)
    end
    print("restore success", archival_dir)
end

function M:restart()
    gameplay_core.restart()

    for _, e in ipairs(startup_entities) do
        gameplay_core.create_entity(e)
    end
    gameplay_core.build()
    restore_world()
end

function M:get_archival_relative_dir_list()
    return archival_relative_dir_list
end

return M