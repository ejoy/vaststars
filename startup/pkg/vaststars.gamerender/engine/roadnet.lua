local ecs = ...
local world = ecs.world
local w = world.w

local iroad = ecs.require "ant.landform|road"
local CONSTANT <const> = require "gameplay.interface.constant"

local RENDER_LAYER <const> = ecs.require "engine.render_layer".RENDER_LAYER
local icoord = require "coord"
local igroup = ecs.require "group"

local roadnet = {}
local function new_groups() return setmetatable({}, {__index=function (tt, gid) local t = {}; tt[gid] = t; return t end}) end

local GROUP_ROADS = new_groups()

---------------------------------------------------------
function roadnet:create()
    iroad.create(CONSTANT.ROAD_WIDTH, CONSTANT.ROAD_HEIGHT)
end

local function cvtcoord2pos(x, y)
    local pos = icoord.lefttop_position(x, y)
    return {pos[1], pos[3] - CONSTANT.ROAD_HEIGHT}
end

local function add_road(layer, x, y, state, shape, dir)
    local gid = igroup.id(x, y)
    local idx = icoord.coord2idx(x, y)
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
    local gid = igroup.id(x, y)
    local idx = icoord.coord2idx(x, y)
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

function roadnet:set(layer_name, x, y, shape_state, shape, dir)
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