local ecs = ...
local world = ecs.world
local w = world.w

local iroad = ecs.require "ant.landform|road"
local iroadnet_converter = require "roadnet_converter"
local CONSTANT <const> = require "gameplay.interface.constant"

local iterrain  = ecs.require "ant.landform|terrain_system"
local RENDER_LAYER <const> = ecs.require "engine.render_layer".RENDER_LAYER
local terrain   = ecs.require "terrain"

local roadnet = {}

-- logic axis
-- ┌──►x
-- │
-- │
-- ▼
-- y

-- render axis
-- z
-- ▲
-- │
-- │
-- └──►x

local function __pack(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function __unpack(coord)
    return coord & 0xFF, coord >> 8
end

local function new_groups() return setmetatable({}, {__index=function (tt, gid) local t = {}; tt[gid] = t; return t end}) end

local GROUP_ROADS = new_groups()

---------------------------------------------------------
function roadnet:create()
    iroad.create(CONSTANT.ROAD_WIDTH, CONSTANT.ROAD_HEIGHT)
    iterrain.gen_terrain_field(CONSTANT.MAP_WIDTH, CONSTANT.MAP_HEIGHT, CONSTANT.MAP_OFFSET, CONSTANT.TILE_SIZE, RENDER_LAYER.TERRAIN)
end

local function cvtcoord2pos(x, y)
    local pos = terrain:get_begin_position_by_coord(x, y, 1, 1)
    return {pos[1], pos[3] - CONSTANT.ROAD_HEIGHT}
end

local function add_road(groups, layer, x, y, state, shape, dir)
    local gid = terrain:get_group_id(x, y)
    local idx = terrain:coord2idx(x, y)
    local item = {
        x=x, y=y,
        pos = cvtcoord2pos(x, y),
        [layer] = {
            state   = state,
            shape   = shape,
            dir     = dir,
        }
    }
    groups[gid][idx] = item
    GROUP_ROADS[gid][idx] = item
end

local function del_road(groups, layer, x, y)
    local gid = terrain:get_group_id(x, y)
    local idx = terrain:coord2idx(x, y)
    local item = groups[gid][idx]
    if item then
        item[layer] = nil
        if nil == item.road and nil == item.indicator then
            groups[gid][idx] = nil
        end
    end
end

function roadnet:update(g)
    iroad.update_roadnet(g, RENDER_LAYER.ROAD)
end

local function find_layer_groups(layer)
    local g = {}
    for gid, items in pairs(GROUP_ROADS) do
        for idx, item in pairs(items) do
            -- if it has any layer we want
            if item[layer] then
                g[gid] = true
                break
            end
        end
    end
    return g
end

function roadnet:clear(layer_name)
    local groups = find_layer_groups(layer_name)
    for _, gid in ipairs(groups) do
        GROUP_ROADS[gid] = nil
    end
    iroad.clear(groups, layer)
end

local MODIFIED_GROUPS = new_groups()
function roadnet:flush()
    if next(MODIFIED_GROUPS) then
        iroad.update_roadnet(MODIFIED_GROUPS, RENDER_LAYER.ROAD)
        MODIFIED_GROUPS = new_groups()
    end
end

function roadnet:set(layer_name, shape_state, x, y, shape, dir)
    add_road(MODIFIED_GROUPS, layer_name, x, y, shape_state, shape, dir)
end

function roadnet:del(layer_name, x, y)
    del_road(MODIFIED_GROUPS, layer_name, x, y)
end

function roadnet:cvtcoord2pos(x, y)
    return cvtcoord2pos(x, y)
end

return roadnet