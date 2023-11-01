local ecs = ...
local world = ecs.world
local w = world.w

local MAX_ARCHIVING_COUNT <const> = 9
local PROTOTYPE_VERSION <const> = ecs.require "vaststars.prototype|version"
local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local CHANGED_FLAG_ALL <const> = CONSTANT.CHANGED_FLAG_ALL

local archiving = require "archiving"
local CAMERA_CONFIG = archiving.path() .. "camera.json"

local debugger = ecs.require "debugger"
local gameplay_core = require "gameplay.core"
local fs = require "bee.filesystem"
local json = import_package "ant.json"
local iprototype_cache = require "gameplay.prototype_cache.init"
local iBackpack = import_package "vaststars.gameplay".interface "backpack"
local iprototype = require "gameplay.interface.prototype"
local iroadnet_converter = require "roadnet_converter"
local objects = require "objects"
local ifluid = require "gameplay.interface.fluid"
local iscience = require "gameplay.interface.science"
local iguide = require "gameplay.interface.guide"
local iui = ecs.require "engine.system.ui_system"
local global = require "global"
local create_buildings = require "building_components"
local igameplay = ecs.require "gameplay_system"
local irq = ecs.require "ant.render|render_system.renderqueue"
local iom = ecs.require "ant.objcontroller|obj_motion"
local ic = ecs.require "ant.camera|camera"
local math3d = require "math3d"
local iobject = ecs.require "object"
local icoord = require "coord"
local iroadnet = ecs.require "roadnet"
local srt = require "utility.srt"
local imineral = ecs.require "mineral"
local imountain = ecs.require "engine.mountain"
local fastio = require "fastio"

local function clean()
    global.buildings = create_buildings()
    objects:clear()
end

local function restore_world(gameplay_world)
    local function _finish_task(task)
        local typeobject = iprototype.queryByName(task)
        gameplay_core.get_world():research_progress(task, typeobject.count)
    end

    local game_template = ecs.require(("vaststars.prototype|%s"):format(gameplay_core.get_storage().game_template))
    local guide = game_template.guide

    local function _debug()
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
            srt = srt.new({
                t = math3d.vector(icoord.position(x, y, iprototype.rotate_area(typeobject.area, dir))),
                r = ROTATORS[dir],
            }),
            fluid_name = fluid_name,
        }
        object.gameplay_eid = gameplay_eid
        objects:set(object)
    end

    -- restore
    local all_object = {}
    local map = {} -- coord -> id
    local fluidbox_map = {} -- coord -> id -- only for fluidbox
    for v in gameplay_world.ecs:select("eid:in building:in road:absent fluidbox?in fluidboxes?in assembling?in") do
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
    global.statistic.valid = false
end

local function writeall(file, content)
    local f <close> = assert(io.open(file, "wb"))
    f:write(content)
end

local function readall(file)
    return fastio.readall_s(file)
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

local function restore_camera_setting()
    if fs.exists(fs.path(CAMERA_CONFIG)) then
        local camera_setting = json.decode(readall(CAMERA_CONFIG))
        local ce <close> = world:entity(irq.main_camera())
        iom.set_srt(ce, camera_setting.s, camera_setting.r, camera_setting.t)
        ic.set_frustum(ce, camera_setting.frustum)
    end
end

local M = {running = false}

function M:backup()
    if not self.running then
        log.error("not running")
        return false
    end

    local list = archiving.list()
    while #list + 1 > MAX_ARCHIVING_COUNT do
        local fullpath = table.remove(list, 1)
        print("remove", fullpath)
        fs.remove_all(fullpath)
    end

    local t = os.date("*t")
    local dn = ("%04d-%02d-%02d-%02d-%02d-%02d"):format(t.year, t.month, t.day, t.hour, t.min, t.sec)
    local fullpath = archiving.path() .. ("%s"):format(dn)

    list[#list + 1] = {dir = dn}
    gameplay_core.backup(fullpath)

    writeall(fullpath .. "/version", json.encode({PROTOTYPE_VERSION = PROTOTYPE_VERSION}))
    writeall(CAMERA_CONFIG, json.encode(get_camera_setting()))
    print("save success", fullpath)
    return true
end

function M:restore(index)
    local list = archiving.list()
    assert(#list > 0)
    assert(#list >= index)

    local fullpath = list[index]
    assert(fs.exists(fs.path(fullpath)))
    assert(fs.exists(fs.path(fullpath .. "/version")))

    local version = json.decode(readall(fullpath .. "/version"))
    assert(version.PROTOTYPE_VERSION == PROTOTYPE_VERSION)

    restore_camera_setting()

    self.running = true
    world:pipeline_func "gameworld_clean" ()
    gameplay_core.restore(fullpath)
    iprototype_cache.reload()
    world:pipeline_func "prototype" ()
    clean()

    local gameplay_world = gameplay_core.get_world()
    local game_template_file = assert(gameplay_core.get_storage().game_template)
    local game_template = ecs.require(("vaststars.prototype|%s"):format(game_template_file))

    iguide.init(gameplay_world, game_template.guide)
    imineral.init(game_template.mineral)
    imountain:create(game_template.mountain)

    for v in gameplay_world.ecs:select "road building:in" do
        local typeobject = iprototype.queryById(v.building.prototype)
        local shape = iroadnet_converter.to_shape(typeobject.name)
        iroadnet:set("road", v.building.x, v.building.y, "normal", shape, iprototype.dir_tostring(v.building.direction))
    end
    iroadnet:flush()

    iscience.update_tech_list(gameplay_core.get_world())
    debugger.set_free_mode(gameplay_core.get_storage().game_mode == "free")
    restore_world(gameplay_world)
    gameplay_core.set_changed(CHANGED_FLAG_ALL)
    gameplay_core.world_update = true

    iui.open({rml = "/pkg/vaststars.resources/ui/construct.rml"})
    iui.open({rml = "/pkg/vaststars.resources/ui/message_pop.rml"})
    print("restore success", fullpath)
    return true
end

function M:restart(mode, game_template_file)
    world:pipeline_func "gameworld_clean" ()
    gameplay_core.restart()
    gameplay_core.get_storage().game_template = assert(game_template_file)

    iprototype_cache.reload()
    local gameplay_world = gameplay_core.get_world()
    world:pipeline_func "prototype" (gameplay_world)

    self.running = true
    iscience.update_tech_list(gameplay_world)

    local game_template = ecs.require(("vaststars.prototype|%s"):format(game_template_file))

    --
    clean()
    local game_template_mineral = game_template.mineral
    imineral.init(game_template_mineral)

    --
    for _, e in ipairs(game_template.entities or {}) do
        igameplay.create_entity(e)
    end

    for _, road in ipairs(game_template.road or {}) do
        igameplay.create_entity(road)
        local shape, dir = iroadnet_converter.to_shape(road.prototype_name), road.dir
        iroadnet:set("road", road.x, road.y, "normal", shape, dir)
    end
    iroadnet:flush()

    for _, e in ipairs(game_template.backpack or {}) do
        local typeobject = iprototype.queryByName(e.prototype_name)
        iBackpack.place(gameplay_world, typeobject.id, e.count)
    end

    local prepare = game_template.prepare
    if prepare then
        prepare(gameplay_world)
    end

    restore_world(gameplay_world)
    gameplay_core.set_changed(CHANGED_FLAG_ALL)
    gameplay_core.world_update = true

    iui.open({rml = "/pkg/vaststars.resources/ui/construct.rml"})
    iui.open({rml = "/pkg/vaststars.resources/ui/message_pop.rml"})
    if mode then
        gameplay_core.get_storage().game_mode = mode
    end

end

return M