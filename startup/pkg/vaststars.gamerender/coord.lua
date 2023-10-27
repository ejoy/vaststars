-- world coordinate system
-- z   y
-- ▲  7 
-- | /
-- └──►x

-- logical coordinate system
-- range: [0, WIDTH - 1], determined by gameplay
-- ┌──►x
-- │
-- ▼
-- y

local CONSTANT <const> = require "gameplay.interface.constant"
local SURFACE_HEIGHT <const> = CONSTANT.SURFACE_HEIGHT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local WIDTH <const> = CONSTANT.MAP_WIDTH
local HEIGHT <const> = CONSTANT.MAP_HEIGHT
local OFFSET_3D <const> = {-(WIDTH * TILE_SIZE)/2, 0.0, -(HEIGHT * TILE_SIZE)/2}
local BOUNDARY_3D <const> = {OFFSET_3D, {OFFSET_3D[1] + WIDTH * TILE_SIZE, OFFSET_3D[2], OFFSET_3D[3] + HEIGHT * TILE_SIZE}}
local ORIGIN <const> = {OFFSET_3D[1], BOUNDARY_3D[2][3]} -- the world position corresponding to the logical origin (0, 0)
local COORD_BOUNDARY <const> = {{0, 0}, {WIDTH - 1, HEIGHT - 1}}

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
    return {ORIGIN[1] + (x * TILE_SIZE), SURFACE_HEIGHT, ORIGIN[2] - (y * TILE_SIZE)}
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

-- position is the center of the entity
function coord.align(position, w, h)
    -- equivalent to: math3d.vector {math3d.index(position, 1) - (w / 2 * TILE_SIZE), math3d.index(position, 2), math3d.index(position, 3) + (h / 2 * TILE_SIZE)}
    local begin_position = math3d.muladd(1/2*TILE_SIZE, math3d.vector(-w, 0.0, h), position)
    local c = _position2coord(begin_position)
    if not c then
        return
    end

    local begining = coord.lefttop_position(c[1], c[2])
    if not begining then
        return
    end

    return c, {begining[1] + (w / 2 * TILE_SIZE), math3d.index(position, 2), begining[3] - (h / 2 * TILE_SIZE)}
end

--base 0
function coord.idx2coord(idx)
    return (idx % WIDTH), (idx // WIDTH)
end

--base 0
function coord.coord2idx(x, y)
    return y * WIDTH + x
end

return coord