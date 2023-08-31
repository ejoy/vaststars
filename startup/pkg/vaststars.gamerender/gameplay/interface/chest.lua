local iprototype = require "gameplay.interface.prototype"

local CHEST_COMPONENT <const> = {
    ["assembling"] = "chest",
    ["chest"] = "chest",
    ["laboratory"] = "chest",
    ["station"] = "chest",
}

local CHEST_TYPES <const> = {
    "assembling",
    "chest",
    "laboratory",
    "station",
    "airport",
}

local MAX_SLOT <const> = 256

local function get_chest_component(e)
    for name, chest_component in pairs(CHEST_COMPONENT) do
        if e[name] then
            return chest_component
        end
    end
end

local function get_max_slot(typeobject)
    if iprototype.has_types(typeobject.type, "station") then
        return typeobject.supply_max + typeobject.demand_max
    else
        return MAX_SLOT
    end 
end

local function has_chest(type)
    return iprototype.has_types(type, table.unpack(CHEST_TYPES))
end

local function get(world, ...)
    local c = world:container_get(...)
    if c and c.item == 0 then
        return
    end
    return c
end

local function get_amount(slot)
    return slot.amount
end

local function get_space(slot)
    return slot.limit - slot.amount - slot.lock_space
end

local function set(world, ...)
    return world:container_set(...)
end

local function has_item(world, e)
    for i = 1, MAX_SLOT do
        local slot = world:container_get(e, i)
        if not slot then
            return false
        end
        if slot.item ~= 0 and slot.amount ~= 0 then
            return true
        end
    end
    return false
end

return {
    MAX_SLOT = MAX_SLOT,
    get_chest_component = get_chest_component,
    has_chest = has_chest,
    get = get,
    get_amount = get_amount,
    get_space = get_space,
    set = set,
    has_item = has_item,
    get_max_slot = get_max_slot,
}
