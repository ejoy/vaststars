-- world coordinate system
-- z   y
-- ▲  7 
-- | /
-- └──►x

-- logical coordinate system
-- range: [0, MAP_WIDTH_COUNT - 1], determined by gameplay
-- ┌──►x
-- │
-- ▼
-- y

local CONSTANT <const> = require "gameplay.interface.constant"
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local OFFSET_3D <const> = {-(MAP_WIDTH_COUNT * TILE_SIZE)/2, 0.0, -(MAP_HEIGHT_COUNT * TILE_SIZE)/2}
local BOUNDARY_3D <const> = {OFFSET_3D, {OFFSET_3D[1] + MAP_WIDTH_COUNT * TILE_SIZE, OFFSET_3D[2], OFFSET_3D[3] + MAP_HEIGHT_COUNT * TILE_SIZE}}
local ORIGIN <const> = {OFFSET_3D[1], BOUNDARY_3D[2][3]} -- the world position corresponding to the logical origin (0, 0)
local COORD_BOUNDARY <const> = {{0, 0}, {MAP_WIDTH_COUNT - 1, MAP_HEIGHT_COUNT - 1}}
local ROAD_WIDTH_COUNT <const> = CONSTANT.ROAD_WIDTH_COUNT
local ROAD_HEIGHT_COUNT <const> = CONSTANT.ROAD_HEIGHT_COUNT

local iprototype = require "gameplay.interface.prototype"
local math3d = require "math3d"

local function _position2coord(position)
    local posx, posz = math3d.index(position, 1, 3)
    if (posx < BOUNDARY_3D[1][1] or posx > BOUNDARY_3D[2][1]) or
        (posz < BOUNDARY_3D[1][3] or posz > BOUNDARY_3D[2][3]) then
        -- log.error(("out of bounds (%f, %f) : (%s) - (%s)"):format(posx, posz, table.concat(BOUNDARY_3D[1], ","), table.concat(BOUNDARY_3D[2], ",")))
        return
    end

    return {math.floor((posx - ORIGIN[1]) // TILE_SIZE), math.floor((ORIGIN[2] - posz) // TILE_SIZE)}
end

local function _verify(x, y)
    if x < COORD_BOUNDARY[1][1] or x > COORD_BOUNDARY[2][1] then
        return false
    end
    if y < COORD_BOUNDARY[1][2] or y > COORD_BOUNDARY[2][2] then
        return false
    end
    return true
end

local coord = {}
function coord.bound(x, y)
    x = math.max(x, COORD_BOUNDARY[1][1])
    x = math.min(x, COORD_BOUNDARY[2][1])
    y = math.max(y, COORD_BOUNDARY[1][2])
    y = math.min(y, COORD_BOUNDARY[2][2])
    return x, y
end

function coord.boundary()
    return COORD_BOUNDARY
end

function coord.move(x, y, dir, dx, dy)
    local _x, _y = iprototype.move_coord(x, y, dir, dx, dy)
    if not _verify(_x, _y) then
        return false, coord.bound(_x, _y)
    end
    return true, _x, _y
end

function coord.lefttop_position(x, y)
    if not _verify(x, y) then
        log.error(("out of bounds (%s,%s) : (%s) - (%s)"):format(x, y, table.concat(COORD_BOUNDARY[1], ","), table.concat(COORD_BOUNDARY[2], ",")))
        return
    end
    return {ORIGIN[1] + (x * TILE_SIZE), 0, ORIGIN[2] - (y * TILE_SIZE)}
end

function coord.origin_position()
    return ORIGIN
end

-- return the position of the center of the entity
function coord.position(x, y, w, h)
    local begining = coord.lefttop_position(x, y)
    if not begining then
        return
    end

    return {begining[1] + (w / 2 * TILE_SIZE), begining[2], begining[3] - (h / 2 * TILE_SIZE)}
end

function coord.position2coord(position)
    return _position2coord(position)
end

function coord.posxy2coord_nocheck(posx, posy)
    return {math.floor((posx - ORIGIN[1]) // TILE_SIZE), math.floor((ORIGIN[2] - posy) // TILE_SIZE)}
end

function coord.position2coord_nocheck(position)
    local posx, posz = math3d.index(position, 1, 3)
    return coord.posxy2coord_nocheck(posx, posz)
end

function coord.align(position, w, h)
    local c = _position2coord(position)
    if not c then
        return
    end

    c[1], c[2] = c[1] - (w // 2), c[2] - (h // 2)
    local begining = coord.lefttop_position(c[1], c[2])
    if not begining then
        return
    end

    return c, {begining[1] + (w / 2 * TILE_SIZE), math3d.index(position, 2), begining[3] - (h / 2 * TILE_SIZE)}
end

--base 0
function coord.unpack(idx)
    return (idx % MAP_WIDTH_COUNT), (idx // MAP_WIDTH_COUNT)
end

--base 0
function coord.pack(x, y)
    return y * MAP_WIDTH_COUNT + x
end

function coord.road_coord(x, y)
    return x - (x % ROAD_WIDTH_COUNT), y - (y % ROAD_HEIGHT_COUNT)
end

function coord.assert_road_coord(x, y)
    assert(x % ROAD_WIDTH_COUNT == 0)
    assert(y % ROAD_HEIGHT_COUNT == 0)
end

return coord