local ecs = ...
local world = ecs.world

local vsobject_manager = ecs.require "vsobject_manager"
local gameplay_core = require "gameplay.core"
local iroadnet_converter = require "roadnet_converter"
local ibuilding = ecs.require "render_updates.building"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iroadnet = ecs.require "engine.roadnet"
local math3d = require "math3d"

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

local function _update_buildings_state(gameplay_eids, state, color, render_layer)
    for gameplay_eid in pairs(gameplay_eids) do
        _update_object_state(gameplay_eid, state, color, color, render_layer)
        _update_road_state(gameplay_eid, _to_road_color(color))
    end
end

return {
    update_buildings_state = _update_buildings_state,
}