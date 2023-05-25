local iprototype = require "gameplay.interface.prototype"
local iprototype_cache = require "gameplay.prototype_cache.init"

local M = {}
function M.covers(prototype_name, entity_dir)
    local prototype_covers = iprototype_cache.get("flow_connector").prototype_covers
    assert(prototype_covers[prototype_name], ("invalid prototype_name `%s`"):format(prototype_name))
    assert(prototype_covers[prototype_name][entity_dir], ("invalid entity_dir `%s`"):format(entity_dir))
    local c = prototype_covers[prototype_name][entity_dir]
    return c.prototype_name, c.entity_dir
end

function M.covers_building_category(prototype_name, entity_dir, building_category)
    local prototype_bits = iprototype_cache.get("flow_connector").prototype_bits
    local accel = iprototype_cache.get("flow_connector").accel
    local bits = assert(prototype_bits[prototype_name][entity_dir])
    local c = assert(accel[building_category][bits])
    return c.prototype_name, c.entity_dir
end

-- the entity corresponding to the given building_category must be pipe to ground.
function M.covers_pipe_to_ground(building_category, dir, ground_dir)
    local get_dir_bit = iprototype_cache.get("flow_connector").get_dir_bit
    local accel = iprototype_cache.get("flow_connector").accel
    local bits = 0
    if dir then
        bits = bits | (1 << get_dir_bit(building_category, dir, false))
    end
    if ground_dir then
        bits = bits | (1 << get_dir_bit(building_category, ground_dir, true))
    end
    local c = assert(accel[building_category][bits])
    return c.prototype_name, c.entity_dir
end

function M.set_connection(prototype_name, entity_dir, connection_dir, s)
    local covers_prototype_name, covers_dir = M.covers(prototype_name, entity_dir)
    local get_dir_bit = iprototype_cache.get("flow_connector").get_dir_bit
    local accel = iprototype_cache.get("flow_connector").accel
    local prototype_bits = iprototype_cache.get("flow_connector").prototype_bits

    assert(prototype_bits[covers_prototype_name], ("invalid prototype_name `%s`"):format(covers_prototype_name))
    assert(prototype_bits[covers_prototype_name][covers_dir], ("invalid entity_dir `%s`"):format(covers_dir))
    local bits
    local typeobject = iprototype.queryByName(prototype_name)

    if s == true then
        bits = prototype_bits[covers_prototype_name][covers_dir]
        if bits & (1 << get_dir_bit(typeobject.building_category, connection_dir, false)) == 0 then -- TODO: special case for pipe-to-ground
            return
        end
        bits = prototype_bits[prototype_name][entity_dir]
        bits = bits | (1 << get_dir_bit(typeobject.building_category, connection_dir, false))
    else
        bits = prototype_bits[prototype_name][entity_dir]
        bits = bits & ~(1 << get_dir_bit(typeobject.building_category, connection_dir, false))
    end
    local c = assert(accel[typeobject.building_category][bits])
    return c.prototype_name, c.entity_dir
end

function M.set_road_connection(prototype_name, entity_dir, connection_dir, s)
    local bits
    local typeobject = iprototype.queryByName(prototype_name)
    local prototype_bits = iprototype_cache.get("flow_connector").prototype_bits
    local accel = iprototype_cache.get("flow_connector").accel
    local get_dir_bit = iprototype_cache.get("flow_connector").get_dir_bit

    -- & 0xF -- exclude road side
    if s == true then
        bits = prototype_bits[prototype_name][entity_dir] & 0xF
        bits = bits | (1 << get_dir_bit(typeobject.building_category, connection_dir, false))
    else
        bits = prototype_bits[prototype_name][entity_dir] & 0xF
        bits = bits & ~(1 << get_dir_bit(typeobject.building_category, connection_dir, false))
    end
    local c = assert(accel[typeobject.building_category][bits])
    return c.prototype_name, c.entity_dir
end

function M.cleanup(prototype_name, entity_dir)
    local prototype_cleanup = iprototype_cache.get("flow_connector").prototype_cleanup
    assert(prototype_cleanup[prototype_name], ("invalid prototype_name `%s`"):format(prototype_name))
    assert(prototype_cleanup[prototype_name][entity_dir], ("invalid entity_dir `%s`"):format(entity_dir))
    local c = prototype_cleanup[prototype_name][entity_dir]
    return c.prototype_name, c.entity_dir
end

function M.ground(building_category)
    local max_ground = iprototype_cache.get("flow_connector").max_ground
    return assert(max_ground[building_category])
end

return M