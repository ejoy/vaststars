local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"

local M = {}
function M:query(...)
    return gameplay.query(...)
end

function M:queryByName(...)
    return gameplay.queryByName(...)
end

function M:all_prototype_name(...)
    return gameplay.prototype_name
end

function M:packcoord(x, y)
    assert(x & 0xFF == x)
    assert(y & 0xFF == y)
    return x | (y<<8)
end

function M:unpackcoord(coord)
    return coord & 0xFF, coord >> 8
end

function M:unpackarea(area)
    return area >> 8, area & 0xFF
end

function M:has_type(types, type)
    for i = 1, #types do
        if types[i] == type then
            return true
        end
    end
    return false
end

function M:is_fluid_id(id)
    return id & 0x0C00 == 0x0C00
end

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}

local DIRECTION_REV = {}
for dir, v in pairs(DIRECTION) do
    DIRECTION_REV[v] = dir
end

function M:rotate_dir(dir, rotate_dir)
    return DIRECTION_REV[(DIRECTION[dir] + DIRECTION[rotate_dir]) % 4]
end

function M:rotate_dir_times(dir, times)
    return DIRECTION_REV[(DIRECTION[dir] + times) % 4]
end

local OPPOSITE <const> = {
    N = 'S',
    E = 'W',
    S = 'N',
    W = 'E',
}
function M:opposite_dir(dir)
    return OPPOSITE[dir]
end

function M:dir_tonumber(dir)
    return assert(DIRECTION[dir])
end

function M:dir_tostring(dir)
    return assert(DIRECTION_REV[dir])
end

function M:rotate_area(area, dir)
    local w, h = self:unpackarea(area)
    if dir == 'N' or dir == 'S' then
        return w, h
    elseif dir == 'E' or dir == 'W' then
        return h, w
    end
end

function M:rotate_fluidbox(position, direction, area)
    local w, h = self:unpackarea(area)
    local x, y = position[1], position[2]
    local dir = self:rotate_dir(position[3], direction)
    w = w - 1
    h = h - 1
    if direction == 'N' then
        return x, y, dir
    elseif direction == 'E' then
        return h - y, x, dir
    elseif direction == 'S' then
        return w - x, h - y, dir
    elseif direction == 'W' then
        return y, w - x, dir
    end
end

return M