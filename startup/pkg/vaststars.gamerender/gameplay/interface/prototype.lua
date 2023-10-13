local CONSTANT <const> = require("gameplay.interface.constant")
local MAP_WIDTH <const> = CONSTANT.MAP_WIDTH
local DIR_MOVE_DELTA <const> = CONSTANT.DIR_MOVE_DELTA
local DIRECTION <const> = CONSTANT.DIRECTION

local math_abs = math.abs
local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"

local function unpackarea(area)
    return area >> 8, area & 0xFF
end

local M = {}
function M.queryById(...)
    return gameplay.prototype.queryById(...)
end

function M.queryByName(...)
    return gameplay.prototype.queryByName(...)
end

function M.has_type(types, type)
    for i = 1, #types do
        if types[i] == type then
            return true
        end
    end
    return false
end

function M.has_types(types, ...)
    for i = 1, #types do
        for j = 1, select("#", ...) do
            if types[i] == select(j, ...) then
                return true
            end
        end
    end
    return false
end

do
    local cache = {}
    function M.each_type(...)
        local function _check_types(typeobject, types)
            for _, type in ipairs(types) do
                if not M.has_type(typeobject.type, type) then
                    return false
                end
            end
            return true
        end

        local types = {...}
        if #types == 0 then
            return gameplay.prototype.all()
        end

        table.sort(types)
        local combine_keys = table.concat(types, ":")
        if cache[combine_keys] then
            return cache[combine_keys]
        end

        local r = {}
        for _, typeobject in pairs(gameplay.prototype.all()) do
            if _check_types(typeobject, types) then
                r[typeobject.name] = typeobject
            end
        end

        cache[combine_keys] = r
        return r
    end
end

function M.queryFirstByType(...)
    for _, v in pairs(M.each_type(...)) do
        return v
    end
end

function M.packcoord(x, y)
    return y * MAP_WIDTH + x
end

function M.is_fluid_id(id)
    local typeobject = assert(M.queryById(id))
    return M.has_type(typeobject.type, "fluid")
end

local REVERSE <const> = {
    [DIRECTION.N] = DIRECTION.S,
    [DIRECTION.E] = DIRECTION.W,
    [DIRECTION.S] = DIRECTION.N,
    [DIRECTION.W] = DIRECTION.E,
    N = 'S', -- TODO: remove this
    E = 'W',
    S = 'N',
    W = 'E',
}

local N <const> = 0
local E <const> = 1
local S <const> = 2
local W <const> = 3

local DIRECTION_REV = {}
for dir, v in pairs(DIRECTION) do
    DIRECTION_REV[v] = dir
    DIRECTION_REV[dir] = dir
end

function M.rotate_dir(dir, rotate_dir, anticlockwise)
    if anticlockwise == nil then
        return (DIRECTION[dir] + DIRECTION[rotate_dir]) % 4
    else
        return (DIRECTION[dir] - DIRECTION[rotate_dir]) % 4
    end
end

function M.rotate_dir_times(dir, times)
    return (DIRECTION[dir] + times) % 4
end

function M.reverse_dir(dir)
    return REVERSE[dir]
end

function M.dir_tostring(dir)
    return assert(DIRECTION_REV[dir])
end

function M.calc_dir(x1, y1, x2, y2)
    local dx = math_abs(x1 - x2)
    local dy = math_abs(y1 - y2)
    if dx > dy then
        if x1 < x2 then
            return 'E', DIR_MOVE_DELTA['E']
        else
            return 'W', DIR_MOVE_DELTA['W']
        end
    else
        if y1 < y2 then
            return 'S', DIR_MOVE_DELTA['S']
        else
            return 'N', DIR_MOVE_DELTA['N']
        end
    end
end

function M.rotate_area(area, dir)
    dir = assert(DIRECTION_REV[dir]) -- TODO: remove this
    local w, h = unpackarea(area)
    if dir == 'N' or dir == 'S' then
        return w, h
    elseif dir == 'E' or dir == 'W' then
        return h, w
    end
    assert(false)
end

function M.move_coord(x, y, dir, dx, dy)
    dx = dx or 1
    dy = dy or dx
    dir = assert(DIRECTION_REV[dir]) -- TODO: remove this

    local c = assert(DIR_MOVE_DELTA[dir])
    return x + c.x * dx, y + c.y * dy
end

function M.rotate_connection(position, direction, area)
    direction = assert(DIRECTION[direction]) -- TODO: remove this
    local w, h = unpackarea(area)
    local x, y = position[1], position[2]
    local dir = M.rotate_dir(position[3], direction)
    w, h = w - 1, h - 1
    if direction == N then
        return x, y, assert(DIRECTION_REV[dir])
    elseif direction == E then
        return h - y, x, assert(DIRECTION_REV[dir])
    elseif direction == S then
        return w - x, h - y, assert(DIRECTION_REV[dir])
    elseif direction == W then
        return y, w - x, assert(DIRECTION_REV[dir])
    end
    assert(false)
end

function M.display_name(typeobject)
    return typeobject.display_name and typeobject.display_name or typeobject.name
end

function M.is_pipe(prototype_name)
    local typeobject = assert(M.queryByName(prototype_name))
    return M.has_type(typeobject.type, "pipe")
end

function M.is_pipe_to_ground(prototype_name)
    local typeobject = assert(M.queryByName(prototype_name))
    return M.has_type(typeobject.type, "pipe_to_ground")
end

function M.is_road(prototype_name)
    local typeobject = assert(M.queryByName(prototype_name))
    return M.has_type(typeobject.type, "road")
end

local function __check_types(prototype_name, types)
    local typeobject = assert(M.queryByName(prototype_name))
    for _, t in ipairs(types) do
        if M.has_type(typeobject.type, t) then
            return true
        end
    end
    return false
end

function M.check_types(...)
    return __check_types(...)
end

return M