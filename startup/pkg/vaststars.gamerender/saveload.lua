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
local CHANGED_FLAG_ALL <const> = require("gameplay.interface.constant").CHANGED_FLAG_ALL
local iBackpack = import_package "vaststars.gameplay".interface "backpack"
local directory = require "directory"

local archival_base_dir
if CUSTOM_ARCHIVING then
    archival_base_dir = (fs.exe_path():parent_path() / CUSTOM_ARCHIVING):lexically_normal():string()
else
    archival_base_dir = (directory.app_path "vaststars" / "archiving/"):string()
end
local archiving_list_path = archival_base_dir .. "archiving.json"
local camera_setting_path = archival_base_dir .. "camera.json"
local iprototype = require "gameplay.interface.prototype"
local iroadnet_converter = require "roadnet_converter"
local objects = require "objects"
local ifluid = require "gameplay.interface.fluid"
local iscience = require "gameplay.interface.science"
local iguide = require "gameplay.interface.guide"
local iui = ecs.require "engine.system.ui_system"
local PROTOTYPE_VERSION <const> = import_package("vaststars.prototype")("version")
local global = require "global"
local create_buildings = require "building_components"

local igameplay = ecs.require "gameplay_system"
local irq = ecs.require "ant.render|render_system.renderqueue"
local iom = ecs.require "ant.objcontroller|obj_motion"
local ic = ecs.require "ant.camera|camera"
local math3d = require "math3d"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local icamera_controller = ecs.require "engine.system.camera_controller"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local iroadnet = ecs.require "roadnet"
local MAX_ARCHIVING_COUNT <const> = 9

local function clean()
    global.buildings = create_buildings()
    objects:clear()
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

    --
    local function restore_object(gameplay_eid, prototype_name, dir, x, y, fluid_name)
        local typeobject = iprototype.queryByName(prototype_name)
        local object = iobject.new {
            prototype_name = prototype_name,
            dir = dir,
            x = x,
            y = y,
            srt = {
                t = math3d.ref(math3d.vector(terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)))),
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
    for v in gameplay_core.select("eid:in building:in road:absent fluidbox?in fluidboxes?in assembling?in") do
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
            local w, h = iprototype.rotate_area(typeobject.area, e.direction)
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

        assert(iprototype.has_type(typeobject.type, "road") == false)
        all_object[v.eid] = {
            prototype_name = typeobject.name,
            dir = iprototype.dir_tostring(e.direction),
            x = e.x,
            y = e.y,
            fluid_name = fluid_name,
        }

        local w, h = iprototype.rotate_area(typeobject.area, e.direction)
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
    local ce <close> = world:entity(irq.main_camera())
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
        local ce <close> = world:entity(irq.main_camera())
        iom.set_srt(ce, camera_setting.s, camera_setting.r, camera_setting.t)
        ic.set_frustum(ce, camera_setting.frustum)
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

function M:check_restore_index(index)
    local archival_list = json.decode(readall(archiving_list_path))
    if #archival_list <= 0 then
        return false
    end

    local archival_relative_dir = archival_list[index].dir
    local archival_dir = archival_base_dir .. ("%s"):format(archival_relative_dir)

    if not fs.exists(fs.path(archival_dir)) then
        log.warn(("`%s` not exists"):format(archival_relative_dir))
        archival_list[index] = nil
        index = index - 1
        return false
    end

    if not fs.exists(fs.path(archival_dir .. "/version")) then
        log.warn(("`%s` not exists"):format(archival_dir .. "/version"))
        archival_list[index] = nil
        index = index - 1
        return false
    end

    local version = json.decode(readall(archival_dir .. "/version"))
    if version.PROTOTYPE_VERSION ~= PROTOTYPE_VERSION then
        log.error(("Failed `%s` version `%s` current `%s`"):format(archival_relative_dir, archival_list[index].version, PROTOTYPE_VERSION))
        return false
    else
        return true
    end
end

function M:get_restore_index()
    if not fs.exists(fs.path(archiving_list_path)) then
        return
    end

    local archival_list = json.decode(readall(archiving_list_path))
    if #archival_list <= 0 then
        return
    end

    local index = #archival_list
    while index > 0 do
        local ok = self:check_restore_index(index)
        if ok then
            break
        end
        index = index - 1
    end

    if index == 0 then
        return
    end
    return index
end

function M:restore(index)
    assert(fs.exists(fs.path(archiving_list_path)))
    local archival_list = json.decode(readall(archiving_list_path))
    assert(#archival_list > 0)
    assert(#archival_list >= index)

    local archival_relative_dir = archival_list[index].dir
    local archival_dir = archival_base_dir .. ("%s"):format(archival_relative_dir)
    assert(fs.exists(fs.path(archival_dir)))
    assert(fs.exists(fs.path(archival_dir .. "/version")))

    local version = json.decode(readall(archival_dir .. "/version"))
    assert(version.PROTOTYPE_VERSION == PROTOTYPE_VERSION)

    self:restore_camera_setting()

    self.running = true
    world:pipeline_func "gameworld_clean" ()
    gameplay_core.restore(archival_dir)
    iprototype_cache.reload()
    world:pipeline_func "prototype" ()

    clean()
    local renderData = {}
    for v in gameplay_core.select("road building:in") do
        local typeobject = iprototype.queryById(v.building.prototype)
        local shape = iroadnet_converter.to_shape(typeobject.name)
        renderData[iprototype.packcoord(v.building.x, v.building.y)] = {v.building.x, v.building.y, "normal", shape, iprototype.dir_tostring(v.building.direction)}
    end
    iroadnet:init(renderData, true)

    local game_template = gameplay_core.get_storage().game_template or "item.startup"
    local game_template_mineral = import_package("vaststars.prototype")(game_template).mineral
    terrain:reset_mineral(game_template_mineral)

    iscience.update_tech_list(gameplay_core.get_world())
    debugger.set_free_mode(gameplay_core.get_storage().game_mode == "free")
    restore_world()
    gameplay_core.set_changed(CHANGED_FLAG_ALL)
    gameplay_core.world_update = true

    iui.open({"/pkg/vaststars.resources/ui/construct.rml"})
    iui.open({"/pkg/vaststars.resources/ui/message_pop.rml"})
    print("restore success", archival_dir)
    return true
end

function M:restart(mode, game_template)
    world:pipeline_func "gameworld_clean" ()
    gameplay_core.restart()
    iprototype_cache.reload()
    world:pipeline_func "prototype" ()

    self.running = true
    local cw = gameplay_core.get_world()
    iscience.update_tech_list(cw)
    iguide.world = cw
    iui.set_guide_progress(iguide.get_progress())

    game_template = game_template or "item.startup"
    gameplay_core.get_storage().game_template = game_template
    local config = import_package("vaststars.prototype")(game_template)

    --
    clean()
    local game_template_mineral = import_package("vaststars.prototype")(game_template).mineral
    terrain:reset_mineral(game_template_mineral)

    --
    for _, e in ipairs(config.entities or {}) do
        igameplay.create_entity(e)
    end

    local renderData = {}
    for _, road in ipairs(config.road or {}) do
        igameplay.create_entity(road)
        local shape, dir = iroadnet_converter.to_shape(road.prototype_name), road.dir
        renderData[iprototype.packcoord(road.x, road.y)] = {road.x, road.y, "normal", shape, dir}
    end
    iroadnet:init(renderData, true)

    for _, e in ipairs(config.backpack or {}) do
        local typeobject = iprototype.queryByName(e.prototype_name)
        iBackpack.place(gameplay_core.get_world(), typeobject.id, e.count)
    end

    local prepare = import_package("vaststars.prototype")(game_template).prepare
    if prepare then
        prepare(gameplay_core.get_world())
    end

    restore_world()
    gameplay_core.set_changed(CHANGED_FLAG_ALL)
    gameplay_core.world_update = true

    iui.open({"/pkg/vaststars.resources/ui/construct.rml"})
    iui.open({"/pkg/vaststars.resources/ui/message_pop.rml"})
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