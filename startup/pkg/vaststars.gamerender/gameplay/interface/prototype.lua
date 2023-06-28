local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local math_abs = math.abs

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
    assert(x & 0xFF == x)
    assert(y & 0xFF == y)
    return x | (y<<8)
end

function M.unpackcoord(coord)
    return coord & 0xFF, coord >> 8
end

function M.unpackarea(area)
    return area >> 8, area & 0xFF
end

function M.is_fluid_id(id)
    local typeobject = assert(M.queryById(id))
    return M.has_type(typeobject.type, "fluid")
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

function M.rotate_dir(dir, rotate_dir, anticlockwise)
    if anticlockwise == nil then
        return DIRECTION_REV[(DIRECTION[dir] + DIRECTION[rotate_dir]) % 4]
    else
        return DIRECTION_REV[(DIRECTION[dir] - DIRECTION[rotate_dir]) % 4]
    end
end

function M.rotate_dir_times(dir, times)
    return DIRECTION_REV[(DIRECTION[dir] + times) % 4]
end

local REVERSE <const> = {
    N = 'S',
    E = 'W',
    S = 'N',
    W = 'E',
}
function M.reverse_dir(dir)
    return REVERSE[dir]
end

function M.dir_tonumber(dir)
    return assert(DIRECTION[dir])
end

function M.dir_tostring(dir)
    return assert(DIRECTION_REV[dir])
end

local dir_move_delta = {
    ['N'] = {x = 0,  y = -1},
    ['E'] = {x = 1,  y = 0},
    ['S'] = {x = 0,  y = 1},
    ['W'] = {x = -1, y = 0},
}

function M.calc_dir(x1, y1, x2, y2)
    local dx = math_abs(x1 - x2)
    local dy = math_abs(y1 - y2)
    if dx > dy then
        if x1 < x2 then
            return 'E', dir_move_delta['E']
        else
            return 'W', dir_move_delta['W']
        end
    else
        if y1 < y2 then
            return 'S', dir_move_delta['S']
        else
            return 'N', dir_move_delta['N']
        end
    end
end

function M.rotate_area(area, dir)
    local w, h = M.unpackarea(area)
    if dir == 'N' or dir == 'S' then
        return w, h
    elseif dir == 'E' or dir == 'W' then
        return h, w
    end
end

function M.move_coord(x, y, dir, dx, dy)
    dx = dx or 1
    dy = dy or dx

    local c = assert(dir_move_delta[dir])
    return x + c.x * dx, y + c.y * dy
end

function M.rotate_connection(position, direction, area)
    local w, h = M.unpackarea(area)
    local x, y = position[1], position[2]
    local dir = M.rotate_dir(position[3], direction)
    w, h = w - 1, h - 1
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

function M.show_prototype_name(typeobject)
    if typeobject.show_prototype_name then
        return typeobject.show_prototype_name
    else
        return typeobject.name
    end
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

local CHEST_TYPES <const> = {
    "assembling",
    "chest",
    "laboratory",
    "station_producer",
    "station_consumer",
    "hub",
    "base",
}

local PICKUP_TYPES <const> = {
    "assembling",
    "station_producer",
    "station_consumer",
    "hub",
    "chest",
}

local PLACE_TYPES <const> = {
    "assembling",
    "laboratory",
    "station_producer",
    "station_consumer",
    "hub",
}

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

function M.has_chest(prototype_name)
    return __check_types(prototype_name, CHEST_TYPES)
end

function M.has_pickup(prototype_name)
    return __check_types(prototype_name, PICKUP_TYPES)
end

function M.has_place(prototype_name)
    return __check_types(prototype_name, PLACE_TYPES)
end

return M