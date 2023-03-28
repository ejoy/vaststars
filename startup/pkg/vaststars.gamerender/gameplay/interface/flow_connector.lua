local iprototype = require "gameplay.interface.prototype"

local get_dir_bit do
    local function get_bit_func()
        local dir_bit <const> = {
            N = 0,
            E = 1,
            S = 2,
            W = 3,
        }

        local ground_bit <const> = { -- ground for the pipe, roadside for the road
            N = 4,
            E = 5,
            S = 6,
            W = 7,
        }

        return function (dir, ground)
            if ground == true then
                return ground_bit[dir]
            else
                return dir_bit[dir]
            end
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
local max_ground = {} -- flow_type -> max_ground

for _, typeobject in pairs(iprototype.each_type "building") do
    if not typeobject.flow_type then
        goto continue
    end

    -- flow_direction is a table of all directions that the entity can rotate around.
    for _, entity_dir in ipairs(typeobject.flow_direction) do
        local bits = 0
        for _, connection in ipairs(_get_connections(typeobject)) do
            local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
            bits = bits | (1 << get_dir_bit(typeobject.flow_type, dir, (connection.ground ~= nil or connection.roadside ~= nil ) )) -- TODO: special case for pipe-to-ground and road

            -- 
            if connection.ground then
                if not max_ground[typeobject.flow_type] then
                    max_ground[typeobject.flow_type] = connection.ground
                else
                    assert(max_ground[typeobject.flow_type] == connection.ground)
                end
            end
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

local function _get_road_covers(flow_type, pipe_bits)
    local r = pipe_bits & 0xF
    for bits in pairs(accel[flow_type]) do
        if pipe_bits ~= bits and r & bits == r then
            r = r | (bits & 0xF)
        end
    end
    return assert(accel[flow_type][r])
end

local function _get_cleanup(prototype_name, entity_dir)
    local typeobject = assert(iprototype.queryByName(prototype_name))
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
        local typeobject = iprototype.queryByName(prototype_name)
        prototype_covers[prototype_name] = prototype_covers[prototype_name] or {}

        if iprototype.is_road(typeobject.name) then -- TODO: special case for road
            prototype_covers[prototype_name][entity_dir] = _get_road_covers(typeobject.flow_type, bits)
        else
            prototype_covers[prototype_name][entity_dir] = _get_covers(typeobject.flow_type, bits)
        end

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

function M.covers_flow_type(prototype_name, entity_dir, flow_type)
    local bits = assert(prototype_bits[prototype_name][entity_dir])
    local c = assert(accel[flow_type][bits])
    return c.prototype_name, c.entity_dir
end

-- the entity corresponding to the given flow_type must be pipe to ground.
function M.covers_pipe_to_ground(flow_type, dir, ground_dir)
    local bits = 0
    if dir then
        bits = bits | (1 << get_dir_bit(flow_type, dir, false))
    end
    if ground_dir then
        bits = bits | (1 << get_dir_bit(flow_type, ground_dir, true))
    end
    local c = assert(accel[flow_type][bits])
    return c.prototype_name, c.entity_dir
end

-- TODO: spec case for road
function M.covers_roadside(prototype_name, entity_dir, roadside_dir, v)
    -- local prototype_name, dir = M.set_connection(prototype_name, entity_dir, roadside_dir, false)
    local bits
    local typeobject = iprototype.queryByName(prototype_name)

    if v == true then
        bits = assert(prototype_bits[prototype_name][entity_dir])
        bits = prototype_bits[prototype_name][entity_dir]
        bits = bits | (1 << get_dir_bit(typeobject.flow_type, roadside_dir, v))
    else
        bits = prototype_bits[prototype_name][entity_dir]
        bits = bits & ~(1 << get_dir_bit(typeobject.flow_type, roadside_dir, v))
    end

    if not accel[typeobject.flow_type][bits] then -- TODO: remove this
        return prototype_name, entity_dir
    end
    -- local c = assert(accel[typeobject.flow_type][bits])
    local c = accel[typeobject.flow_type][bits]
    return c.prototype_name, c.entity_dir
end

function M.set_connection(prototype_name, entity_dir, connection_dir, s)
    local covers_prototype_name, covers_dir = M.covers(prototype_name, entity_dir)

    assert(prototype_bits[covers_prototype_name], ("invalid prototype_name `%s`"):format(covers_prototype_name))
    assert(prototype_bits[covers_prototype_name][covers_dir], ("invalid entity_dir `%s`"):format(covers_dir))
    local bits
    local typeobject = iprototype.queryByName(prototype_name)

    if s == true then
        bits = prototype_bits[covers_prototype_name][covers_dir]
        if bits & (1 << get_dir_bit(typeobject.flow_type, connection_dir, false)) == 0 then -- TODO: special case for pipe-to-ground
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

function M.set_road_connection(prototype_name, entity_dir, connection_dir, s)
    local bits
    local typeobject = iprototype.queryByName(prototype_name)

    -- & 0xF -- exclude road side
    if s == true then
        bits = prototype_bits[prototype_name][entity_dir] & 0xF
        bits = bits | (1 << get_dir_bit(typeobject.flow_type, connection_dir, false))
    else
        bits = prototype_bits[prototype_name][entity_dir] & 0xF
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

function M.ground(flow_type)
    return assert(max_ground[flow_type])
end

return M