local ecs   = ...

local iroad     = ecs.require "ant.landform|road"
local terrain   = ecs.require "terrain"

local RENDER_LAYER <const> = ecs.require "engine.render_layer".RENDER_LAYER
local CONST<const>  = ecs.require "gameplay.interface.constant"
local ROAD_HEIGHT<const> = CONST.ROAD_HEIGHT
local function convertTileToWorld(x, y)
    local pos = terrain:get_begin_position_by_coord(x, y, 1, 1)
    return pos[1], pos[3] - ROAD_HEIGHT
end

local road = {}

local function is_empty_road(g)
    return nil == g.road or nil == g.indicator
end

local function add_road(groups, x, y, state, shape, dir, layer)
    local gid = terrain:get_group_id(x, y)
    local g = groups[gid]
    local idx = terrain:coord2idx(x, y)
    local posx, posy = convertTileToWorld(x, y)
    
    g[idx] = {
        x = x, y = y,
        pos = {posx, posy},
        [layer] = {
            state   = state,
            shape   = shape,
            dir     = dir,
        }
    }
end

local function del_road(groups, x, y, layer)
    local gid = terrain:get_group_id(x, y)
    local idx = terrain:coord2idx(x, y)
    local g = groups[gid]
    local gi = g[idx]
    gi[layer] = nil
    if is_empty_road(gi) then
        g[idx] = nil
    end
end

local function new_groups()
    return setmetatable({}, {__index=function (tt, gid) local t = {}; tt[gid] = t; return t end})
end
function road:init()
    iroad.create(CONST.ROAD_WIDTH, CONST.ROAD_HEIGHT)
end

-- map = {{x, y, state, shape, dir}, ...}
function road:update(roads, layername)
    local groups = new_groups()
    for _, v in ipairs(roads) do
        local x, y, state, shape, dir = table.unpack(v)
        add_road(groups, x, y, state, shape, dir, layername)
    end
    iroad.update_roadnet(groups, RENDER_LAYER.ROAD)
end

function road:update_raw(groups)
    iroad.update_roadnet(groups, RENDER_LAYER.ROAD)
end

function road:group_obj()
    return setmetatable({
        add = add_road,
        remove = del_road,
        commit = function (self)
            iroad.update_roadnet(self, RENDER_LAYER.ROAD)
        end
    }, {__index=function (tt, gid) local t = {}; tt[gid] = t; return t end})
end

local MODIFY_GROUPS = new_groups()

-- shape = "I" / "U" / "L" / "T" / "O"
-- dir = "N" / "E" / "S" / "W"
function road:set(layer_name, state, x, y, shape, dir)
    add_road(MODIFY_GROUPS, x, y, state, shape, dir, layer_name)
end

function road:del(layer_name, x, y)
    del_road(MODIFY_GROUPS, x, y, layer_name)
end

function road:flush()
    if next(MODIFY_GROUPS) then
        iroad.update_roadnet(MODIFY_GROUPS, RENDER_LAYER.ROAD)
        MODIFY_GROUPS = new_groups()
    end
end

return road