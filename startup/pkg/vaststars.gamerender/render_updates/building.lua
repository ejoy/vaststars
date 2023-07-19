local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local global = require "global"
local icanvas = ecs.require "engine.canvas"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local iterrain = ecs.require "terrain"
local datalist = require "datalist"
local fs = require "filesystem"
local building_base_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/config/canvas/building-base.cfg")):read "a")
local building_sys = ecs.system "building_system"
local gameplay_core = require "gameplay.core"
local ibuilding = ecs.interface "ibuilding"
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local gameplay = import_package "vaststars.gameplay"
local igameplay_building = gameplay.interface "building"

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
    [0] = 'N',
    [1] = 'E',
    [2] = 'S',
    [3] = 'W',
}

local EDITOR_CACHE_NAMES = {"CONSTRUCTED"}

local function __draw_building_base(object_id, building_srt, w, h)
    local cfg = assert(building_base_cfg[("%dx%d"):format(w, h)], ("no building_base of this size(%dx%d) available"):format(w, h))
    local item_x, item_y = building_srt.t[1] - (w/2 * iterrain.tile_size), building_srt.t[3] - (h/2 * iterrain.tile_size)
    local draw_x, draw_y, draw_w, draw_h = item_x, item_y, w * iterrain.tile_size, h * iterrain.tile_size

    icanvas.add_item(icanvas.types().BUILDING_BASE,
        object_id,
        icanvas.get_key("/pkg/vaststars.resources/materials/canvas/building-base.material", RENDER_LAYER.BUILDING_BASE),
        {
            texture = {
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
            },
            x = draw_x, y = draw_y, w = draw_w, h = draw_h,
        }
    )
end

local function __create_building_base(object_id, typeobject, building_srt, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    __draw_building_base(object_id, building_srt, w, h)
    local function remove()
        icanvas.remove_item(icanvas.types().BUILDING_BASE, object_id)
    end
    local function on_position_change(self, building_srt, dir)
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        icanvas.remove_item(icanvas.types().BUILDING_BASE, object_id)
        __draw_building_base(object_id, building_srt, w, h)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
    }
end

function building_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "building_new building:in road:absent eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local typeobject = iprototype.queryById(e.building.prototype)
        if typeobject.building_base == false then
            goto continue
        end

        local building = global.buildings[object.id]
        if not building.building_base then
            building.building_base = __create_building_base(object.id, typeobject, object.srt, object.dir)
        end

        ::continue::
    end

    for e in gameplay_world.ecs:select "building_changed building:in road:absent" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local typeobject = iprototype.queryById(e.building.prototype)
        object.prototype_name = typeobject.name
        object.dir = DIRECTION[e.building.direction]
        objects:set(object, EDITOR_CACHE_NAMES[1])
    end
end

local building_cache = {}

function building_sys:gameworld_build()
    building_cache = {}
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "road building:in eid:in" do
        building_cache[iprototype.packcoord(e.building.x, e.building.y)] = {
            eid = e.eid,
            x = e.building.x,
            y = e.building.y,
            prototype = iprototype.queryById(e.building.prototype).name,
            direction = iprototype.dir_tostring(e.building.direction),
        }
    end
end

function ibuilding.get(x, y)
    return building_cache[iprototype.packcoord(x, y)]
end

function ibuilding.remove(x, y)
    local gameplay_world = gameplay_core.get_world()
    local coord = iprototype.packcoord(x, y)
    local building = building_cache[coord]
    igameplay_building.destroy(gameplay_world, gameplay_world.entity[building.eid])

    building_cache[coord] = nil
end

function ibuilding.set(init)
    local coord = iprototype.packcoord(init.x, init.y)
    local building = building_cache[coord]
    if building then
        local gameplay_world = gameplay_core.get_world()
        igameplay_building.destroy(gameplay_world, gameplay_world.entity[building.eid])
        building_cache[coord] = nil
    end
    local eid = igameplay.create_entity(init)
    building_cache[iprototype.packcoord(init.x, init.y)] = {
        eid = eid,
        x = init.x,
        y = init.y,
        prototype = init.prototype_name,
        direction = init.direction,
    }
end