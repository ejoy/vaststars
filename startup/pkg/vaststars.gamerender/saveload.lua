local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local fs = require "bee.filesystem"
local json = import_package "ant.json"
local debugger = require "debugger"
local CUSTOM_ARCHIVING <const> = require "debugger".custom_archiving
local iprototype_cache = require "gameplay.prototype_cache.init"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS

local archival_base_dir
if CUSTOM_ARCHIVING then
    archival_base_dir = (fs.exe_path():parent_path() / CUSTOM_ARCHIVING):lexically_normal():string()
else
    archival_base_dir = (fs.app_path "vaststars" / "archiving/"):string()
end
local archiving_list_path = archival_base_dir .. "archiving.json"
local camera_setting_path = archival_base_dir .. "camera.json"
local iprototype = require "gameplay.interface.prototype"
local iroadnet_converter = require "roadnet_converter"
local objects = require "objects"
local ifluid = require "gameplay.interface.fluid"
local iscience = require "gameplay.interface.science"
local iguide = require "gameplay.interface.guide"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local PROTOTYPE_VERSION <const> = import_package("vaststars.prototype")("version")
local global = require "global"
local create_buildings = require "building_components"
local mineral_map = import_package "vaststars.prototype"("map")

local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local irq = ecs.import.interface "ant.render|irenderqueue"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ic = ecs.import.interface "ant.camera|icamera"
local math3d = require "math3d"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local icamera_controller = ecs.interface "icamera_controller"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local iroadnet = ecs.require "roadnet"
local MAX_ARCHIVING_COUNT <const> = 9

local function clean()
    -- clean
    for _, object in objects:all() do
        iobject.remove(object)
    end
    for _, building in pairs(global.buildings) do
        for _, o in pairs(building) do
            o:remove()
        end
    end
    global.buildings = create_buildings()
    objects:clear()
    iroadnet:clear("indicator")
    iroadnet:clear("road")
end

local function restore_world()
    local function _finish_task(task)
        local typeobject = iprototype.queryByName(task)
        gameplay_core.get_world():research_progress(task, typeobject.count)
    end

    local function _debug()
        local guide = import_package "vaststars.prototype"("guide")
        if debugger.skip_guide then
            print("skip guide")
            gameplay_core.get_storage().guide_id = #guide
            iui.set_guide_progress(guide[#guide].narrative_end.guide_progress)

            for _, guide in ipairs(guide) do
                if next(guide.narrative_end.task) then
                    for _, task in ipairs(guide.narrative_end.task) do
                        _finish_task(task)
                    end
                end
            end
        end
    end
    _debug()

    local coord_system = require "global".coord_system

    --
    local function restore_object(gameplay_eid, prototype_name, dir, x, y, fluid_name)
        local typeobject = iprototype.queryByName(prototype_name)
        local object = iobject.new {
            prototype_name = prototype_name,
            dir = dir,
            x = x,
            y = y,
            srt = {
                t = math3d.ref(math3d.vector(coord_system:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)))),
                r = ROTATORS[dir],
            },
            fluid_name = fluid_name,
        }
        object.gameplay_eid = gameplay_eid
        objects:set(object)
    end

    -- restore
    local all_object = {}
    local map = {} -- coord -> id
    local fluidbox_map = {} -- coord -> id -- only for fluidbox
    for v in gameplay_core.select("eid:in building:in fluidbox?in fluidboxes?in assembling?in") do
        local e = v.building
        local typeobject = iprototype.queryById(e.prototype)
        local fluid_name = ""
        if v.fluidbox then
            fluid_name = ""
            if v.fluidbox.fluid == 0 then
                fluid_name = ""
            else
                local typeobject_fluid = assert(iprototype.queryById(v.fluidbox.fluid))
                fluid_name = typeobject_fluid.name
            end
            local w, h = iprototype.rotate_area(typeobject.area, iprototype.dir_tostring(e.direction))
            for i = 0, w - 1 do
                for j = 0, h - 1 do
                    local coord = iprototype.packcoord(e.x + i, e.y + j)
                    assert(fluidbox_map[coord] == nil, ("duplicate fluidbox coord: %d, %d"):format(e.x + i, e.y + j))
                    fluidbox_map[coord] = v.eid
                end
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

        all_object[v.eid] = {
            prototype_name = typeobject.name,
            dir = iprototype.dir_tostring(e.direction),
            x = e.x,
            y = e.y,
            fluid_name = fluid_name,
        }

        local w, h = iprototype.rotate_area(typeobject.area, iprototype.dir_tostring(e.direction))
        for i = 0, w - 1 do
            for j = 0, h - 1 do
                local coord = iprototype.packcoord(e.x + i, e.y + j)
                assert(map[coord] == nil, ("duplicate fluidbox coord: %d, %d"):format(e.x + i, e.y + j))
                map[coord] = v.eid
            end
        end

        world:pub {"gameplay", "create_entity", v.eid, typeobject}
    end

    -----------
    for id, v in pairs(all_object) do
        restore_object(id, v.prototype_name, v.dir, v.x, v.y, v.fluid_name)
    end

    iobject.flush()
    iscience.update_tech_list(gameplay_core.get_world())
    -- update power network
    ipower:build_power_network(gameplay_core.get_world())
    ipower_line.update_line(ipower:get_pole_lines())
    global.statistic.valid = false
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
    local ce <close> = w:entity(irq.main_camera())
    local t = {
        s = math3d.tovalue(iom.get_scale(ce)),
        r = math3d.tovalue(iom.get_rotation(ce)),
        t = math3d.tovalue(iom.get_position(ce)),
        frustum = ic.get_frustum(ce),
    }
    return t
end

local M = {running = false}
function M:restore_camera_setting()
    if fs.exists(fs.path(camera_setting_path)) then
        local camera_setting = json.decode(readall(camera_setting_path))
        local ce <close> = w:entity(irq.main_camera())
        iom.set_srt(ce, camera_setting.s, camera_setting.r, camera_setting.t)
        ic.set_frustum(ce, camera_setting.frustum)
    end

    if terrain.init then
        local coord = terrain:align(icamera_controller.get_central_position(), 1, 1)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end
    end
end

function M:backup()
    if not self.running then
        log.error("not running")
        return false
    end

    local archival_list = M:get_archival_list()
    while #archival_list + 1 > MAX_ARCHIVING_COUNT do
        local archival = table.remove(archival_list, 1)
        local archival_dir = archival_base_dir .. ("%s"):format(archival.dir)
        print("remove", archival_dir)
        fs.remove_all(archival_dir)
    end

    local t = os.date("*t")
    local dn = ("%04d-%02d-%02d-%02d-%02d-%02d"):format(t.year, t.month, t.day, t.hour, t.min, t.sec)
    local archival_dir = archival_base_dir .. ("%s"):format(dn)

    archival_list[#archival_list + 1] = {dir = dn}
    gameplay_core.backup(archival_dir)

    writeall(archival_dir .. "/version", json.encode({PROTOTYPE_VERSION = PROTOTYPE_VERSION}))
    writeall(archiving_list_path, json.encode(archival_list))
    writeall(camera_setting_path, json.encode(get_camera_setting()))
    print("save success", archival_dir)
    return true
end

function M:clean()
    clean()
end

function M:restore(index)
    self:restore_camera_setting()

    --
    if not fs.exists(fs.path(archiving_list_path)) then
        self:restart()
        return true
    end
    local archival_list = json.decode(readall(archiving_list_path))
    if #archival_list <= 0 then
        self:restart()
        return true
    end

    index = index or #archival_list
    if index > #archival_list then
        log.error(("Failed to restore `%s`"):format(index))
        iui.open({"option_pop.rml"})
        return false
    end

    local archival_dir
    while index > 0 do
        local archival_relative_dir = archival_list[index].dir
        archival_dir = archival_base_dir .. ("%s"):format(archival_relative_dir)

        if not fs.exists(fs.path(archival_dir)) then
            log.warn(("`%s` not exists"):format(archival_relative_dir))
            archival_list[index] = nil
            index = index - 1
            goto continue
        end

        if not fs.exists(fs.path(archival_dir .. "/version")) then
            log.warn(("`%s` not exists"):format(archival_dir .. "/version"))
            archival_list[index] = nil
            index = index - 1
            goto continue
        end

        local version = json.decode(readall(archival_dir .. "/version"))
        if version.PROTOTYPE_VERSION ~= PROTOTYPE_VERSION then
            log.error(("Failed `%s` version `%s` current `%s`"):format(archival_relative_dir, archival_list[index].version, PROTOTYPE_VERSION))
            iui.open({"option_pop.rml"})
            return false
        else
            break
        end

        ::continue::
    end

    if index == 0 then
        log.error("Failed to restore")
        iui.open({"option_pop.rml"})
        return false
    end

    self.running = true
    gameplay_core.restore(archival_dir)
    iprototype_cache.reload()

    clean()
    local renderData = {}
    for v in gameplay_core.select("road:in endpoint_road:absent") do
        local shape, dir = iroadnet_converter.mask_to_shape_dir(v.road.mask) -- TODO: remove this
        renderData[iprototype.packcoord(v.road.x * 2, v.road.y * 2)] = {v.road.x * 2, v.road.y * 2, "normal", shape, dir}
    end
    iroadnet:init(renderData, true)

    terrain:reset_mineral(mineral_map)

    iscience.update_tech_list(gameplay_core.get_world())
    debugger.set_free_mode(gameplay_core.get_storage().game_mode == "free")
    restore_world()

    igameplay.build_world()
    iroadnet:editor_build()

    iui.open({"construct.rml"})
    iui.open({"message_pop.rml"})
    print("restore success", archival_dir)
    return true
end

function M:restart(mode, game_template)
    gameplay_core.restart()
    iprototype_cache.reload()

    self.running = true
    local cw = gameplay_core.get_world()
    iscience.update_tech_list(cw)
    iguide.world = cw
    iui.set_guide_progress(iguide.get_progress())

    local coord = terrain:align(icamera_controller.get_central_position(), 1, 1)
    if coord then
        terrain:enable_terrain(coord[1], coord[2])
    end

    game_template = game_template or "item.startup"
    local game_template_entities = import_package("vaststars.prototype")(game_template).entities
    local game_template_road = import_package("vaststars.prototype")(game_template).road

    --
    clean()
    local game_template_mineral = import_package("vaststars.prototype")(game_template).mineral
    terrain:reset_mineral(game_template_mineral or mineral_map)

    --
    for _, e in ipairs(game_template_entities) do
        igameplay.create_entity(e)
    end
    local renderData = {}
    for _, road in ipairs(game_template_road) do
        local e = {
            road = {
                x = road.x,
                y = road.y,
                mask = road.mask,
                classid = iprototype.queryByName(road.prototype).id
            }
        }
        gameplay_core.get_world().ecs:new(e)

        local shape, dir = iroadnet_converter.mask_to_shape_dir(road.mask) -- TODO: remove this
        renderData[iprototype.packcoord(road.x * 2, road.y * 2)] = {road.x * 2, road.y * 2, "normal", shape, dir}
    end
    iroadnet:init(renderData, true)


    local prepare = import_package("vaststars.prototype")(game_template).prepare
    if prepare then
        prepare(gameplay_core.get_world())
    end

    restore_world()
    igameplay.build_world()
    iroadnet:editor_build()

    iui.open({"construct.rml"})
    iui.open({"message_pop.rml"})
    if mode then
        gameplay_core.get_storage().game_mode = mode
    end

end

function M:get_archival_list()
    if not fs.exists(fs.path(archiving_list_path)) then
        return {}
    end
    return json.decode(readall(archiving_list_path))
end

return M