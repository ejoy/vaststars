local iprototype = require "gameplay.interface.prototype"

local get_dir_bit do
    local function get_bit_func()
        local shift = 0
        local dir_bit = {}

        return function (dir, ground)
            dir_bit[dir] = dir_bit[dir] or {}
            if not dir_bit[dir][ground] then
                shift = shift + 1
                dir_bit[dir][ground] = shift
            end
            return dir_bit[dir][ground]
        end
    end

    local cache = {}
    function get_dir_bit(pipe_type, dir, ground)
        cache[pipe_type] = cache[pipe_type] or get_bit_func()
        return cache[pipe_type](dir, ground)
    end
end

local accel = {} -- pipe_type + bits -> prototype_name + dir
local prototype_bits = {} -- prototype_name + dir -> bits
for _, typeobject in pairs(iprototype.each_maintype "entity") do
    if not typeobject.pipe_type then
        goto continue
    end

    -- pipe_direction is a table of all directions that the pipe can rotate around.
    for _, entity_dir in ipairs(typeobject.pipe_direction) do
        local bits = 0
        for _, connection in ipairs(typeobject.fluidbox.connections) do
            local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
            bits = bits | (1 << get_dir_bit(typeobject.pipe_type, dir, connection.ground ~= nil))
        end

        accel[typeobject.pipe_type] = accel[typeobject.pipe_type] or {}
        assert(not accel[typeobject.pipe_type][entity_dir])
        accel[typeobject.pipe_type][bits] = {prototype_name = typeobject.name, entity_dir = entity_dir}

        prototype_bits[typeobject.name] = prototype_bits[typeobject.name] or {}
        assert(not prototype_bits[typeobject.name][entity_dir])
        prototype_bits[typeobject.name][entity_dir] = bits
    end
    ::continue::
end

local function _get_covers(pipe_type, pipe_bits)
    local r = pipe_bits
    for bits in pairs(accel[pipe_type]) do
        if pipe_bits ~= bits and pipe_bits & bits == pipe_bits then
            r = r | bits
        end
    end
    return assert(accel[pipe_type][r])
end

local function _get_cleanup(prototype_name, entity_dir)
    local typeobject = assert(iprototype.queryByName("entity", prototype_name))
    local bits = 0
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        if connection.ground then
            local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
            bits = bits | (1 << get_dir_bit(typeobject.pipe_type, dir, true))
        end
    end
    return assert(accel[typeobject.pipe_type][bits])
end

local prototype_covers = {}
local prototype_cleanup = {}
for prototype_name, t in pairs(prototype_bits) do
    for entity_dir, bits in pairs(t) do
        local typeobject = iprototype.queryByName("entity", prototype_name)
        prototype_covers[prototype_name] = prototype_covers[prototype_name] or {}
        prototype_covers[prototype_name][entity_dir] = _get_covers(typeobject.pipe_type, bits)

        prototype_cleanup[prototype_name] = prototype_cleanup[prototype_name] or {}
        prototype_cleanup[prototype_name][entity_dir] = _get_cleanup(prototype_name, entity_dir)
    end
end

local M = {}
function M.covers(prototype_name, entity_dir)
    assert(prototype_covers[prototype_name], ("invalid prototype_name `%s`"):format(prototype_name))
    assert(prototype_covers[prototype_name][entity_dir], ("invalid entity_dir `%s`"):format(entity_dir))
    local c = prototype_covers[prototype_name][entity_dir]
    return c.prototype_name, c.entity_dir
end

function M.set_connection(prototype_name, entity_dir, connection_dir, s)
    local covers_prototype_name, covers_dir = M.covers(prototype_name, entity_dir)

    assert(prototype_bits[covers_prototype_name], ("invalid prototype_name `%s`"):format(covers_prototype_name))
    assert(prototype_bits[covers_prototype_name][covers_dir], ("invalid entity_dir `%s`"):format(covers_dir))
    local bits
    local typeobject = iprototype.queryByName("entity", prototype_name)

    if s == true then
        bits = prototype_bits[covers_prototype_name][covers_dir]
        if bits & (1 << get_dir_bit(typeobject.pipe_type, connection_dir, false)) == 0 then
            return
        end
        bits = prototype_bits[prototype_name][entity_dir]
        bits = bits | (1 << get_dir_bit(typeobject.pipe_type, connection_dir, false))
    else
        bits = prototype_bits[prototype_name][entity_dir]
        bits = bits & ~(1 << get_dir_bit(typeobject.pipe_type, connection_dir, false))
    end
    local c = assert(accel[typeobject.pipe_type][bits])
    return c.prototype_name, c.entity_dir
end

function M.cleanup(prototype_name, entity_dir)
    assert(prototype_cleanup[prototype_name], ("invalid prototype_name `%s`"):format(prototype_name))
    assert(prototype_cleanup[prototype_name][entity_dir], ("invalid entity_dir `%s`"):format(entity_dir))
    local c = prototype_cleanup[prototype_name][entity_dir]
    return c.prototype_name, c.entity_dir
end

return M