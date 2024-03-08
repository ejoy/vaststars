local ecs = ...
local world = ecs.world

local COLOR <const> = ecs.require "vaststars.prototype|color"

local vsobject_manager = ecs.require "vsobject_manager"
local gameplay_core = require "gameplay.core"
local iroadnet_converter = require "roadnet_converter"
local ibuilding = ecs.require "render_updates.building"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iroadnet = ecs.require "engine.roadnet"
local math3d = require "math3d"
local global = require "global"
local itranslucent_plane = ecs.require "translucent_plane"
local create_translucent_plane = itranslucent_plane.create
local flush_translucent_plane = itranslucent_plane.flush

local translucent_plane

local function _update_object_state(gameplay_eid, state, color, emissive_color, render_layer)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local object = objects:coord(e.building.x, e.building.y)
    if object then
        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {state = state, color = color, emissive_color = emissive_color, render_layer = render_layer}
    end
end

local function _update_road_state(gameplay_eid, color)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local v = ibuilding.get(e.building.x, e.building.y)
    if v then
        local typeobject = iprototype.queryByName(v.prototype)
        local shape = iroadnet_converter.to_shape(typeobject.name)
        iroadnet:set("road", v.x, v.y, color, shape, v.direction)
    end
end

local function _to_road_color(color)
    if color == "null" then
        return 0xffffffff
    end
    local r, g, b, a = math3d.index(color, 1, 2, 3, 4)
    r, g, b, a = math.floor(r*255), math.floor(g*255), math.floor(b*255), math.floor(a*255)
    return r | g<<8 | b<<16 | a<<24
end

local function _update_buildings_state_(gameplay_eids, state, color, render_layer)
    for gameplay_eid in pairs(gameplay_eids) do
        _update_object_state(gameplay_eid, state, color, color, render_layer)
        _update_road_state(gameplay_eid, _to_road_color(color))
    end
end

local function _update_buildings_state(t)
    for _, v in ipairs(t) do
        _update_buildings_state_(table.unpack(v))
    end
    iroadnet:flush()
end

local function _get_selected_ltrb()
    local aabb = math3d.aabb()
    for gameplay_eid in pairs(global.selected_buildings) do
        local e = assert(gameplay_core.get_entity(gameplay_eid))
        local x, y = e.building.x, e.building.y
        local object = objects:coord(x, y)
        if object then
            local typeobject = iprototype.queryByName(object.prototype_name)
            local w, h = iprototype.rotate_area(typeobject.area, object.dir)
            local aabb_ = math3d.aabb(math3d.vector(x, 0, y), math3d.vector(x+w, 0, y+h))
            aabb = math3d.aabb_merge(aabb, aabb_)
        end
        local v = ibuilding.get(x, y)
        if v then
            local typeobject = iprototype.queryByName(v.prototype)
            local w, h = iprototype.rotate_area(typeobject.area, v.direction)
            local aabb_ = math3d.aabb(math3d.vector(x, 0, y), math3d.vector(x+w, 0, y+h))
            aabb = math3d.aabb_merge(aabb, aabb_)
        end
    end

    if math3d.aabb_isvalid(aabb) then
        local lt = math3d.array_index(aabb, 1)
        local rb = math3d.array_index(aabb, 2)
        local l, t = math3d.index(lt, 1, 3)
        local r, b = math3d.index(rb, 1, 3)

        return l, t, r, b
    end
end

local function _recreate_translucent_plane()
    if translucent_plane then
        translucent_plane:remove()
    end
    local l, t, r, b = _get_selected_ltrb()
    if not l then
        flush_translucent_plane()
        return
    end
    translucent_plane = create_translucent_plane(l, t, r - l, b - t, COLOR.BULK_SELECTED_BUILDINGS_RANGE)
    flush_translucent_plane()
end

local function _remove_translucent_plane()
    if translucent_plane then
        translucent_plane:remove()
        translucent_plane = nil
        flush_translucent_plane()
    end
end

return {
    update_buildings_state = _update_buildings_state,
    get_selected_ltrb = _get_selected_ltrb,
    renew_selected_range = _recreate_translucent_plane,
    remove_selected_range = _remove_translucent_plane,
}