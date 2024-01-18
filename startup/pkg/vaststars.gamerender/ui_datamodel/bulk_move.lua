local ecs, mailbox = ...
local world = ecs.world

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"

local math3d = require "math3d"
local XZ_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})

local icoord = require "coord"
local COORD_BOUNDARY <const> = icoord.boundary()

local select_mb = mailbox:sub {"select"}
local icamera_controller = ecs.require "engine.system.camera_controller"
local icoord = require "coord"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local ibuilding = ecs.require "render_updates.building"
local iprototype = require "gameplay.interface.prototype"
local iroadnet_converter = require "roadnet_converter"
local iroadnet = ecs.require "engine.roadnet"

local selected = {}

local M = {}
function M.create()
    return {}
end

local function _update_object_state(coord, state, color, emissive_color, render_layer)
    local x, y = iprototype.unpackcoord(coord)
    local object = objects:coord(x, y)
    if object then
        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {state = state, color = color, emissive_color = emissive_color, render_layer = render_layer}
    end
end

local function _update_road_state(coord, color)
    local x, y = iprototype.unpackcoord(coord)
    local v = ibuilding.get(x, y)
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

local function _update_selected_coords(coords, state, color, render_layer)
    for _, coord in ipairs(coords) do
        _update_object_state(coord, state, color, color, render_layer)
        _update_road_state(coord, _to_road_color(color))
    end
end

function M.update(datamodel)
    for _, _, _, left, top, width, height in select_mb:unpack() do
        local lefttop = icamera_controller.screen_to_world(left, top, XZ_PLANE)
        local rightbottom = icamera_controller.screen_to_world(left + width, top + height, XZ_PLANE)

        local ltcoord = icoord.position2coord(lefttop) or {0, 0}
        local rbcoord = icoord.position2coord(rightbottom) or {COORD_BOUNDARY[2][1], COORD_BOUNDARY[2][2]}

        local new = {}
        for x = ltcoord[1], rbcoord[1] do
            for y = ltcoord[2], rbcoord[2] do
                local object = objects:coord(x, y)
                if object then
                    new[iprototype.packcoord(object.x, object.y)] = true
                end
                local road_x, road_y = x//2*2, y//2*2
                local v = ibuilding.get(road_x, road_y)
                if v then
                    new[iprototype.packcoord(road_x, road_y)] = true
                end
            end
        end

        local old = selected
        local add, del = {}, {}

        for coord in pairs(old) do
            if new[coord] == nil then
                del[#del+1] = coord
            end
        end

        for coord in pairs(new) do
            if old[coord] == nil then
                add[#add+1] = coord
            end
        end

        _update_selected_coords(add, "translucent", SPRITE_COLOR.SELECTED, RENDER_LAYER.TRANSLUCENT_BUILDING)
        _update_selected_coords(del, "opaque", "null", RENDER_LAYER.BUILDING)

        selected = new
        iroadnet:flush()
    end
end

return M