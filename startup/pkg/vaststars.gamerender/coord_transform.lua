local iprototype = require "gameplay.interface.prototype"
local math3d = require "math3d"

local TILE_UNIT = 10

local mt = {}
mt.__index = mt

local function _verify_coord(self, x, y)
    local coord_bounds = self._coord_bounds
    if x < coord_bounds[1][1] or x > coord_bounds[2][1] then
        return false
    end
    if y < coord_bounds[1][2] or y > coord_bounds[2][2] then
        return false
    end
    return true
end

local function _bound_coord(self, x, y)
    x = math.max(x, self._coord_bounds[1][1])
    x = math.min(x, self._coord_bounds[2][1])
    y = math.max(x, self._coord_bounds[1][2])
    y = math.min(x, self._coord_bounds[2][2])
    return x, y
end

local function _get_coord_by_position(self, position)
    local boundary_3d = self._boundary_3d
    local posx, posz = math3d.index(position, 1, 3)

    if (posx < boundary_3d[1][1] or posx > boundary_3d[2][1]) or
        (posz < boundary_3d[1][3] or posz > boundary_3d[2][3]) then
        log.error(("out of bounds (%f, %f) : (%s) - (%s)"):format(posx, posz, table.concat(boundary_3d[1], ","), table.concat(boundary_3d[2], ",")))
        return
    end

    local origin = self._origin_3d
    return {math.floor((posx - origin[1]) / TILE_UNIT), math.floor((origin[2] - posz) / TILE_UNIT)}
end

--
function mt:move(x, y, dir, dx, dy)
    local _x, _y = iprototype.move_coord(x, y, dir, dx, dy)
    if not _verify_coord(self, _x, _y) then
        return false, _bound_coord(self, _x, _y)
    end
    return true, _x, _y
end

function mt:get_begin_position_by_coord(x, y)
    local coord_bounds = self._coord_bounds
    local origin = self._origin_3d

    if not _verify_coord(self, x, y) then
        log.error(("out of bounds (%s,%s) : (%s) - (%s)"):format(x, y, table.concat(coord_bounds[1], ","), table.concat(coord_bounds[2], ",")))
        return
    end
    return {origin[1] + (x * TILE_UNIT), 0, origin[2] - (y * TILE_UNIT)}
end

-- return the position of the center of the entity
function mt:get_position_by_coord(x, y, w, h)
    local begining = self:get_begin_position_by_coord(x, y)
    if not begining then
        return
    end

    return {begining[1] + (w / 2 * TILE_UNIT), begining[2], begining[3] - (h / 2 * TILE_UNIT)}
end

-- position is the center of the entity
function mt:align(position, w, h)
    -- equivalent to: math3d.vector {math3d.index(position, 1) - (w / 2 * TILE_SIZE), math3d.index(position, 2), math3d.index(position, 3) + (h / 2 * TILE_SIZE)}
    local begin_position = math3d.muladd(1/2*TILE_UNIT, math3d.vector(-w, 0.0, h), position)
    local coord = _get_coord_by_position(self, begin_position)
    if not coord then
        return
    end

    local begining = self:get_begin_position_by_coord(coord[1], coord[2])
    if not begining then
        return
    end

    return coord, {begining[1] + (w / 2 * TILE_UNIT), math3d.index(position, 2), begining[3] - (h / 2 * TILE_UNIT)}
end

function mt:get_coord_by_position(position)
    return _get_coord_by_position(self, position)
end

return function(tile_width, tile_height)
    local M = {}
    M.tile_width, M.tile_height = tile_width, tile_height
    M.tile_unit_width = TILE_UNIT
    M.tile_unit_height = TILE_UNIT
    M.tile_size = TILE_UNIT

    local offset_3d = {-(M.tile_width * TILE_UNIT)/2, 0.0, -(M.tile_height * TILE_UNIT)/2}
    local boundary_3d = {
        offset_3d,
        {offset_3d[1] + M.tile_width * TILE_UNIT, offset_3d[2], offset_3d[3] + M.tile_height * TILE_UNIT}
    }

    M._boundary_3d = boundary_3d
    M._origin_3d = {offset_3d[1], boundary_3d[2][3]} -- origin in logical coordinates
    M._coord_bounds = {
        {0, 0},
        {M.tile_width - 1, M.tile_height - 1},
    }
    return setmetatable(M, mt)
end
