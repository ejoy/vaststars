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

local function add_road(layer, x, y, state, shape, dir)
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
    GROUP_ROADS[gid][idx] = item
    return gid, idx
end

local function del_road(layer, x, y)
    local gid = terrain:get_group_id(x, y)
    local idx = terrain:coord2idx(x, y)
    local item = GROUP_ROADS[gid][idx]
    if item then
        item[layer] = nil
        if nil == item.road and nil == item.indicator then
            GROUP_ROADS[gid][idx] = nil
        end
        return gid, idx
    end
end

function roadnet:update(g)
    iroad.update_roadnet(g, RENDER_LAYER.ROAD)
end

function roadnet:clear(layer_name)
    local g = {}
    for gid, items in pairs(GROUP_ROADS) do
        for idx, item in pairs(items) do
            -- if it has any layer we want
            if item[layer_name] then
                g[gid] = true
                item[layer_name] = nil
            end
        end
    end
    iroad.clear(g, layer_name)
end

local MODIFIED_GROUPS = {
    which_groups = {},
    clear   = function (self) self.which_groups = {} end,
    mark    = function (self, gid) self.which_groups[gid] = GROUP_ROADS[gid] end,
    update  = function (self)
        if next(self.which_groups) then
            iroad.update_roadnet(self.which_groups, RENDER_LAYER.ROAD)
            self:clear()
        end
    end,
}
function roadnet:flush()
    MODIFIED_GROUPS:update()
end

function roadnet:set(layer_name, shape_state, x, y, shape, dir)
    local gid = add_road(layer_name, x, y, shape_state, shape, dir)
    MODIFIED_GROUPS:mark(gid)
end

function roadnet:del(layer_name, x, y)
    local gid = del_road(layer_name, x, y)
    MODIFIED_GROUPS:mark(gid)
end

function roadnet:cvtcoord2pos(x, y)
    return cvtcoord2pos(x, y)
end

return roadnet