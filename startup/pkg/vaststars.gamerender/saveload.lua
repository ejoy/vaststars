local ecs = ...
local world = ecs.world
local w = world.w

local MAX_ARCHIVING_COUNT <const> = 9
local PROTOTYPE_VERSION <const> = ecs.require "vaststars.prototype|version"
local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local CHANGED_FLAG_ALL <const> = CONSTANT.CHANGED_FLAG_ALL

local archiving = require "archiving"
local CAMERA_CONFIG = archiving.PATH() .. "camera.json"

local gameplay_core = require "gameplay.core"
local fs = require "bee.filesystem"
local json = import_package "ant.json"
local iprototype_cache = require "gameplay.prototype_cache.init"
local iprototype = require "gameplay.interface.prototype"
local iroadnet_converter = require "roadnet_converter"
local objects = require "objects"
local global = require "global"
local create_buildings = require "building_components"
local igameplay = ecs.require "gameplay.gameplay_system"
local irq = ecs.require "ant.render|render_system.renderqueue"
local iom = ecs.require "ant.objcontroller|obj_motion"
local ic = ecs.require "ant.camera|camera"
local math3d = require "math3d"
local iobject = ecs.require "object"
local icoord = require "coord"
local iroadnet = ecs.require "engine.roadnet"
local srt = require "utility.srt"
local fastio = require "fastio"
local inner_building = require "editor.inner_building"

local function clean()
    global.buildings = create_buildings()
    objects:clear()
    inner_building:clear()
end

local function restore_world(gameplay_world)
    local function restore_object(gameplay_eid, prototype_name, dir, x, y, debris)
        local typeobject = iprototype.queryByName(prototype_name)
        local object = iobject.new {
            prototype_name = prototype_name,
            dir = dir,
            x = x,
            y = y,
            srt = srt.new {
                t = math3d.vector(icoord.position(x, y, iprototype.rotate_area(typeobject.area, dir))),
                r = ROTATORS[dir],
            },
            debris = debris,
        }
        object.gameplay_eid = gameplay_eid
        objects:set(object)
    end

    -- restore
    local all_object = {}
    local map = {} -- coord -> id
    for v in gameplay_world.ecs:select("eid:in building:in road:absent inner_building:absent fluidbox?in fluidboxes?in assembling?in debris?in") do
        local e = v.building
        local typeobject = iprototype.queryById(e.prototype)
        local debris
        if v.debris then
            debris = v.debris.prototype
        end

        assert(iprototype.has_type(typeobject.type, "road") == false)
        all_object[v.eid] = {
            prototype_name = typeobject.name,
            dir = iprototype.dir_tostring(e.direction),
            x = e.x,
            y = e.y,
            debris = debris,
        }

        local w, h = iprototype.rotate_area(typeobject.area, e.direction)
        for i = 0, w - 1 do
            for j = 0, h - 1 do
                local coord = icoord.pack(e.x + i, e.y + j)
                assert(map[coord] == nil, ("duplicate fluidbox coord: %d, %d"):format(e.x + i, e.y + j))
                map[coord] = v.eid
            end
        end

        world:pub {"gameplay", "create_entity", v.eid, typeobject}
    end

    -----------
    for id, v in pairs(all_object) do
        restore_object(id, v.prototype_name, v.dir, v.x, v.y, v.debris)
    end

    iobject.flush()
    global.statistic.valid = false

    for e in gameplay_world.ecs:select("inner_building:in eid:in building:in") do
        local typeobject = iprototype.queryById(e.building.prototype)
        local w, h = iprototype.rotate_area(typeobject.area, e.building.direction)
        inner_building:set(e.eid, e.building.x, e.building.y, w, h)
    end
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
    local fullpath = archiving.PATH() .. ("%s"):format(dn)

    list[#list + 1] = {dir = dn}
    gameplay_core.backup(fullpath)

    writeall(fullpath .. "/version", json.encode({PROTOTYPE_VERSION = PROTOTYPE_VERSION}))
    writeall(CAMERA_CONFIG, json.encode(get_camera_setting()))
    print("save success", fullpath)
    return true
end

function M:restore(fullpath)
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
    for v in gameplay_world.ecs:select "road building:in" do
        local typeobject = iprototype.queryById(v.building.prototype)
        local shape = iroadnet_converter.to_shape(typeobject.name)
        iroadnet:set("road", v.building.x, v.building.y, 0xffffffff, shape, iprototype.dir_tostring(v.building.direction))
    end
    iroadnet:flush()

    restore_world(gameplay_world)
    gameplay_core.set_changed(CHANGED_FLAG_ALL)
    gameplay_core.world_update = true
    print("restore success", fullpath)
    return true
end

function M:restart(game_template_file)
    world:pipeline_func "gameworld_clean" ()
    gameplay_core.restart()
    gameplay_core.get_storage().game_template = assert(game_template_file)

    iprototype_cache.reload()
    local gameplay_world = gameplay_core.get_world()
    world:pipeline_func "prototype" (gameplay_world)

    self.running = true
    local game_template = ecs.require(("vaststars.prototype|%s"):format(game_template_file))

    --
    clean()

    --
    for _, e in ipairs(game_template.entities or {}) do
        local typeobject = iprototype.queryByName(e.prototype_name)
        local create_builder = ecs.require("editor.builder." .. typeobject.builder)
        local builder = create_builder("build")
        builder:build(e)
    end

    for _, road in ipairs(game_template.road or {}) do
        igameplay.create_entity(road)
        local shape, dir = iroadnet_converter.to_shape(road.prototype_name), road.dir
        iroadnet:set("road", road.x, road.y, 0xffffffff, shape, dir)
    end
    iroadnet:flush()

    local prepare = game_template.prepare
    if prepare then
        prepare(gameplay_world)
    end

    restore_world(gameplay_world)
    gameplay_core.set_changed(CHANGED_FLAG_ALL)
    gameplay_core.world_update = true
end

return M