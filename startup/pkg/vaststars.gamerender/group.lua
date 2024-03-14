local ecs   = ...
local world = ecs.world
local w     = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local MAP_CHUNK_WIDTH_COUNT <const> = 16
local MAP_CHUNK_HEIGHT_COUNT <const> = 16
assert(MAP_CHUNK_WIDTH_COUNT % 2 == 0 and MAP_CHUNK_HEIGHT_COUNT % 2 == 0)
assert(MAP_WIDTH_COUNT % MAP_CHUNK_WIDTH_COUNT == 0 and MAP_HEIGHT_COUNT % MAP_CHUNK_HEIGHT_COUNT == 0)
local MAX_BUILDING_WIDTH_SIZE <const> = CONSTANT.MAX_BUILDING_WIDTH_SIZE
local MAX_BUILDING_HEIGHT_SIZE <const> = CONSTANT.MAX_BUILDING_HEIGHT_SIZE

local icoord = require "coord"
local COORD_BOUNDARY <const> = icoord.boundary()

local math3d = require "math3d"
local ig        = ecs.require "ant.group|group"
local irender   = ecs.require "ant.render|render"

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
    return icoord.pack(_get_gridxy(x, y))
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

local LEFTTOP_CORNER_OFFSET<const>      = math3d.constant("v4", {-MAX_BUILDING_WIDTH_SIZE, 0,  MAX_BUILDING_HEIGHT_SIZE, 0})
local RIGHTBOTTOM_CORNER_OFFSET<const>  = math3d.constant("v4", { MAX_BUILDING_WIDTH_SIZE, 0, -MAX_BUILDING_HEIGHT_SIZE, 0})

local group_selector = {
    last_enabled = {},
    find = function (self, lefttop, rightbottom)
        -- because the group id of the buildings is calculated based on the coordinates of the top-left corner, so we need to expand the range
        lefttop     = math3d.add(lefttop,       LEFTTOP_CORNER_OFFSET)
        rightbottom = math3d.add(rightbottom,   RIGHTBOTTOM_CORNER_OFFSET)

        local ltCoord = icoord.position2coord(lefttop)      or {0, 0}
        local rbCoord = icoord.position2coord(rightbottom)  or {COORD_BOUNDARY[2][1], COORD_BOUNDARY[2][2]}

        local X, Y = _get_gridxy(ltCoord[1], ltCoord[2])
        local W, H = _get_gridxy(rbCoord[1], rbCoord[2])
        return X, Y, W, H
    end,
    select = function (self, x, y, ww, hh)
        local go = ig.obj "view_visible"
        local new, old = {}, self.last_enabled
        for ix=x, ww do
            for iy=y, hh do
                local gid = assert(group_ids[icoord.pack(ix, iy)])
                new[gid] = true
                old[gid] = nil
                go:enable(gid, true)
            end
        end

        for gid in pairs(old) do
            go:enable(gid, false)
        end
        irender.group_flush(go)
        self.last_enabled = new
    end
}

function group.enable(lefttop, rightbottom)
    if lock == true then
        return
    end

    local X, Y, W, H = group_selector:find(lefttop, rightbottom)
    group_selector:select(X, Y, W, H)
end

return group