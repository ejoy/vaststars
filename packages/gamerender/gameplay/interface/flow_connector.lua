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
    function get_dir_bit(flow_type, dir, ground)
        cache[flow_type] = cache[flow_type] or get_bit_func()
        return cache[flow_type](dir, ground)
    end
end

local function _get_connections(typeobject)
    if typeobject.pipe or typeobject.pipe_to_ground then
        return typeobject.fluidbox.connections
    elseif typeobject.crossing then
        return typeobject.crossing.connections
    end
    assert(false)
end

local accel = {} -- flow_type + bits -> prototype_name + dir
local prototype_bits = {} -- prototype_name + dir -> bits
for _, typeobject in pairs(iprototype.each_maintype "entity") do
    if not typeobject.flow_type then
        goto continue
    end

    -- flow_direction is a table of all directions that the entity can rotate around.
    for _, entity_dir in ipairs(typeobject.flow_direction) do
        local bits = 0
        for _, connection in ipairs(_get_connections(typeobject)) do
            local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
            bits = bits | (1 << get_dir_bit(typeobject.flow_type, dir, connection.ground ~= nil))
        end

        accel[typeobject.flow_type] = accel[typeobject.flow_type] or {}
        assert(not accel[typeobject.flow_type][entity_dir])
        accel[typeobject.flow_type][bits] = {prototype_name = typeobject.name, entity_dir = entity_dir}

        prototype_bits[typeobject.name] = prototype_bits[typeobject.name] or {}
        assert(not prototype_bits[typeobject.name][entity_dir])
        prototype_bits[typeobject.name][entity_dir] = bits
    end
    ::continue::
end

local function _get_covers(flow_type, pipe_bits)
    local r = pipe_bits
    for bits in pairs(accel[flow_type]) do
        if pipe_bits ~= bits and pipe_bits & bits == pipe_bits then
            r = r | bits
        end
    end
    return assert(accel[flow_type][r])
end

local function _get_cleanup(prototype_name, entity_dir)
    local typeobject = assert(iprototype.queryByName("entity", prototype_name))
    local bits = 0
    for _, connection in ipairs(_get_connections(typeobject)) do
        if connection.ground then
            local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
            bits = bits | (1 << get_dir_bit(typeobject.flow_type, dir, true))
        end
    end
    return assert(accel[typeobject.flow_type][bits])
end

local prototype_covers = {}
local prototype_cleanup = {}
for prototype_name, t in pairs(prototype_bits) do
    for entity_dir, bits in pairs(t) do
        local typeobject = iprototype.queryByName("entity", prototype_name)
        prototype_covers[prototype_name] = prototype_covers[prototype_name] or {}
        prototype_covers[prototype_name][entity_dir] = _get_covers(typeobject.flow_type, bits)

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
        if bits & (1 << get_dir_bit(typeobject.flow_type, connection_dir, false)) == 0 then
            return
        end
        bits = prototype_bits[prototype_name][entity_dir]
        bits = bits | (1 << get_dir_bit(typeobject.flow_type, connection_dir, false))
    else
        bits = prototype_bits[prototype_name][entity_dir]
        bits = bits & ~(1 << get_dir_bit(typeobject.flow_type, connection_dir, false))
    end
    local c = assert(accel[typeobject.flow_type][bits])
    return c.prototype_name, c.entity_dir
end

function M.cleanup(prototype_name, entity_dir)
    assert(prototype_cleanup[prototype_name], ("invalid prototype_name `%s`"):format(prototype_name))
    assert(prototype_cleanup[prototype_name][entity_dir], ("invalid entity_dir `%s`"):format(entity_dir))
    local c = prototype_cleanup[prototype_name][entity_dir]
    return c.prototype_name, c.entity_dir
end

return M