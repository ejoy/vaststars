local ecs   = ...
local world = ecs.world
local w     = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local MAP_CHUNK_WIDTH_COUNT <const> = 16
local MAP_CHUNK_HEIGHT_COUNT <const> = 16
assert(MAP_CHUNK_WIDTH_COUNT % 2 == 0 and MAP_CHUNK_HEIGHT_COUNT % 2 == 0)
assert(MAP_WIDTH_COUNT % MAP_CHUNK_WIDTH_COUNT == 0 and MAP_HEIGHT_COUNT % MAP_CHUNK_HEIGHT_COUNT == 0)
local MAX_BUILDING_WIDTH_COUNT <const> = 6
local MAX_BUILDING_HEIGHT_COUNT <const> = 6
local MAX_BUILDING_WIDTH_SIZE <const> = MAX_BUILDING_WIDTH_COUNT * TILE_SIZE
local MAX_BUILDING_HEIGHT_SIZE <const> = MAX_BUILDING_HEIGHT_COUNT * TILE_SIZE

local icoord = require "coord"
local COORD_BOUNDARY <const> = icoord.boundary()

local math3d = require "math3d"
local ig = ecs.require "ant.group|group"
local iprototype = require "gameplay.interface.prototype"

local enabled_group_ids = {}
local group_ids = setmetatable({}, {
    __index = function (tt, k)
        local o = "TERRAIN_GROUP_" .. k
        local gid = ig.register(o)
        tt[k] = gid
        return tt[k]
end})
local lock = false

local function _get_gridxy(x, y)
    return (x // MAP_CHUNK_WIDTH_COUNT) + 1, (y // MAP_CHUNK_HEIGHT_COUNT) + 1
end

local function _get_grid_id(x, y)
    return iprototype.packcoord(_get_gridxy(x, y))
end

local group = {}
function group.id(x, y)
    return group_ids[_get_grid_id(x, y)]
end

function group.is_lock()
    return lock
end

function group.lock(b)
    lock = b
end

function group.map_chunk_wh()
    return MAP_CHUNK_WIDTH_COUNT, MAP_CHUNK_HEIGHT_COUNT
end

function group.enable(lefttop, rightbottom)
    if lock == true then
        return
    end
    local function diff(t1, t2)
        local add, del = {}, {}
        for group_id in pairs(t1) do
            if t2[group_id] == nil then
                del[#del+1] = group_id
            end
        end
        for group_id in pairs(t2) do
            if t1[group_id] == nil then
                add[#add+1] = group_id
            end
        end
        return add, del
    end

    -- because the group id of the buildings is calculated based on the coordinates of the top-left corner, so we need to expand the range
    lefttop = math3d.add(lefttop, {-(MAX_BUILDING_WIDTH_SIZE), 0, MAX_BUILDING_HEIGHT_SIZE})
    rightbottom = math3d.add(rightbottom, {MAX_BUILDING_WIDTH_SIZE, 0, -(MAX_BUILDING_HEIGHT_SIZE)})

    local ltCoord = icoord.position2coord(lefttop) or {0, 0}
    local rbCoord = icoord.position2coord(rightbottom) or {COORD_BOUNDARY[2][1], COORD_BOUNDARY[2][2]}

    local ltGridCoord = {_get_gridxy(ltCoord[1], ltCoord[2])}
    local rbGridCoord = {_get_gridxy(rbCoord[1], rbCoord[2])}

    local new = {}
    for x = ltGridCoord[1], rbGridCoord[1] do
        for y = ltGridCoord[2], rbGridCoord[2] do
            local group_id = assert(group_ids[iprototype.packcoord(x, y)])
            new[group_id] = true
        end
    end

    local add, del = diff(enabled_group_ids, new)
    enabled_group_ids = new
    local go = ig.obj "view_visible"
    for _, group_id in ipairs(add) do
        go:enable(group_id, true)
    end
    for _, group_id in ipairs(del) do
        go:enable(group_id, false)
    end

    go:flush()
    go:filter("render_object_visible", "render_object")
    go:filter("hitch_visible", "hitch")
    go:filter("efk_visible", "efk")
end

return group