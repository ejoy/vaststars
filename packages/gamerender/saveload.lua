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
local ifluid = require "gameplay.interface.fluid"
local iscience = require "gameplay.interface.science"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local GAMEPLAY_VERSION <const> = require "version"
local global = require "global"

local irq = ecs.import.interface "ant.render|irenderqueue"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ic = ecs.import.interface "ant.camera|icamera"
local math3d = require "math3d"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"

local MAX_ARCHIVING_COUNT <const> = 9

local archival_list = {}

local function restore_world()
    -- clean
    for _, object in objects:all() do
        iobject.remove(object)
    end
    objects:clear()

    -- restore world
    local function restore_object(gameplay_eid, prototype_name, dir, x, y, fluid_name, fluidflow_network_id)
        local typeobject = iprototype.queryByName("entity", prototype_name)

        local object = iobject.new {
            prototype_name = prototype_name,
            dir = dir,
            x = x,
            y = y,
            fluid_name = fluid_name,
            fluidflow_network_id = fluidflow_network_id,
            headquater = typeobject.headquater or false,
            state = "constructed",
        }
        object.gameplay_eid = gameplay_eid
        objects:set(object)
    end

    -- restore
    local all_object = {}
    local empty_fluidbox = {}
    for v in gameplay_core.select("id:in entity:in fluidbox?in fluidboxes?in") do
        local e = v.entity
        local typeobject = iprototype.queryById(e.prototype)
        local fluid_name = ""
        if v.fluidbox then
            fluid_name = ""
            if v.fluidbox.fluid ~= 0 then
                local typeobject_fluid = assert(iprototype.queryById(v.fluidbox.fluid))
                fluid_name = typeobject_fluid.name
            else
                empty_fluidbox[iprototype.packcoord(e.x, e.y)] = v.id
            end
        end
        if v.fluidboxes then
            fluid_name = {}
            for id, fluid in pairs(v.fluidboxes) do
                if fluid ~= 0 then
                    local iotype, index = id:match("(%a+)(%d+)%_fluid")
                    if iotype then
                        local classity = ifluid:iotype_to_classity(iotype)
                        local typeobject_fluid = assert(iprototype.queryById(fluid))

                        fluid_name[classity] = fluid_name[classity] or {}
                        fluid_name[classity][tonumber(index)] = typeobject_fluid.name
                    end
                end
            end
        end
        all_object[v.id] = {
            name = typeobject.name, 
            dir = iprototype.dir_tostring(e.direction),
            x = e.x,
            y = e.y,
            fluid_name = fluid_name,
            fluidflow_network_id = 0,
        }
    end

    local function dfs(all_object, empty_fluidbox, object, input_dir)
        local typeobject = iprototype.queryByName("entity", object.name)
        for _, v in ipairs(ifluid:get_fluidbox(typeobject.name, object.x, object.y, object.dir)) do
            if v.dir ~= input_dir then
                local succ, x, y
                if not v.ground then
                    succ, x, y = terrain:move_coord(v.x, v.y, v.dir, 1)
                    assert(succ)
                else
                    local function match_ground(dir) -- TODO：optimize
                        for i = 1, v.ground do
                            succ, x, y = terrain:move_coord(v.x, v.y, v.dir, i)
                            assert(succ)

                            local object_id = empty_fluidbox[iprototype.packcoord(x, y)]
                            if object_id then
                                local object = assert(all_object[object_id])
                                local typeobject = iprototype.queryByName("entity", object.name)
                                for _, v in ipairs(ifluid:get_fluidbox(typeobject.name, object.x, object.y, object.dir)) do
                                    if v.ground and v.dir == iprototype.opposite_dir(dir) then
                                        return x, y
                                    end
                                end
                            end
                        end
                    end
                    x, y = match_ground(v.dir)
                end

                if x and y then
                    local neighbor_id = empty_fluidbox[iprototype.packcoord(x, y)]
                    if neighbor_id then
                        local neighbor = assert(all_object[neighbor_id])
                        if neighbor then
                            assert(neighbor.fluidflow_network_id == 0)
                            neighbor.fluidflow_network_id = object.fluidflow_network_id
                            dfs(all_object, empty_fluidbox, neighbor, iprototype.opposite_dir(v.dir))
                        end
                    end
                end
            end
        end
    end

    for _, id in pairs(empty_fluidbox) do
        local object = all_object[id]
        if object.fluidflow_network_id == 0 then
            global.fluidflow_network_id = global.fluidflow_network_id + 1
            object.fluidflow_network_id = global.fluidflow_network_id + 1
            dfs(all_object, empty_fluidbox, object)
        end
    end

    for id, v in pairs(all_object) do
        restore_object(id, v.name, v.dir, v.x, v.y, v.fluid_name, v.fluidflow_network_id)
    end

    iobject.flush()
    iscience.update_tech_list(gameplay_core.get_world())
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

local M = {running = false}
function M:backup()
    if not self.running then
        log.error("not running")
        return
    end

    while #archival_list + 1 > MAX_ARCHIVING_COUNT do
        local archival_relative_dir = table.remove(archival_list, 1)
        local archival_dir = archival_base_dir .. ("/%s"):format(archival_relative_dir)
        print("remove", archival_dir)
        fs.remove_all(archival_dir)
    end

    local t = os.date("*t")
    local dn = ("%04d-%02d-%02d-%02d-%02d-%02d"):format(t.year, t.month, t.day, t.hour, t.min, t.sec)
    local archival_dir = archival_base_dir .. ("/%s"):format(dn)

    archival_list[#archival_list + 1] = {dir = dn, version = require("version")}
    gameplay_core.backup(archival_dir)

    writeall(archiving_list_path, json.encode(archival_list))
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
        self.running = true
        return true
    end
    archival_list = json.decode(readall(archiving_list_path))
    if #archival_list <= 0 then
        self:restart()
        self.running = true
        return true
    end

    index = index or #archival_list
    if index > #archival_list then
        log.error(("Failed to restore `%s`"):format(index))
        iui.open("option_pop.rml")
        return false
    end

    local archival_dir
    while index > 0 do
        local archival_relative_dir = archival_list[index].dir
        archival_dir = archival_base_dir .. ("/%s"):format(archival_relative_dir)

        if not fs.exists(fs.path(archival_dir)) then
            log.warn(("`%s` not exists"):format(archival_relative_dir))
            archival_list[index] = nil
            index = index - 1
            goto continue
        end

        if archival_list[index].version ~= GAMEPLAY_VERSION then
            log.error(("Failed `%s` version `%s` current `%s`"):format(archival_relative_dir, archival_list[index].version, GAMEPLAY_VERSION))
            -- archival_list[index] = nil
            -- index = index - 1
            iui.open("option_pop.rml")
            return false
        else
            break
        end

        ::continue::
    end

    if index == 0 then
        log.error("Failed to restore")
        iui.open("option_pop.rml")
        return false
    end

    gameplay_core.restore(archival_dir)
    self.running = true
    iscience.update_tech_list(gameplay_core.get_world())
    iui.open("construct.rml")

    if camera_setting then
        restore_camera_setting(camera_setting)
    end

    local coord = terrain:align(camera.get_central_position(), terrain.ground_width, terrain.ground_height)
    if coord then
        terrain:enable_terrain(coord[1], coord[2])
    end

    gameplay_core.build()
    restore_world()

    print("restore success", archival_dir)
    return true
end

function M:restart()
    gameplay_core.restart()

    self.running = true
    iscience.update_tech_list(gameplay_core.get_world())
    iui.open("construct.rml")

    local coord = terrain:align(camera.get_central_position(), terrain.ground_width, terrain.ground_height)
    if coord then
        terrain:enable_terrain(coord[1], coord[2])
    end

    for _, e in ipairs(startup_entities) do
        gameplay_core.create_entity(e)
    end
    gameplay_core.build()
    restore_world()
end

function M:get_archival_list()
    return archival_list
end

return M