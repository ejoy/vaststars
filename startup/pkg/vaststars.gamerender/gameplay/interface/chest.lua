local iprototype = require "gameplay.interface.prototype"
local igameplay_chest = import_package "vaststars.gameplay".interface "chest"

local CHEST_TYPES <const> = {
    "assembling",
    "chest",
    "laboratory",
    "station",
}

local MAX_SLOT <const> = 256

local function get_max_slot(typeobject)
    return typeobject.maxslot and typeobject.maxslot or MAX_SLOT
end

local function has_chest(type)
    return iprototype.has_types(type, table.unpack(CHEST_TYPES))
end

local function set(world, e, item)
    return igameplay_chest.chest_set(world, e, item)
end

local function get(world, ...)
    return igameplay_chest.get(world, ...)
end

local function get_amount(slot)
    return slot.amount
end

local function get_space(slot)
    return slot.limit - slot.amount - slot.lock_space
end

local function pickup_at(world, ...)
    igameplay_chest.pickup_at(world, ...)
end

local function place_at(world, ...)
    igameplay_chest.place_at(world, ...)
end

local function pickup(world, ...)
    igameplay_chest.pickup(world, ...)
end

local function place(world, ...)
    igameplay_chest.place(world, ...)
end

local function has_item(world, e)
    for i = 1, MAX_SLOT do
        local slot = igameplay_chest.get(world, e, i)
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
    has_chest = has_chest,
    set = set,
    get = get,
    get_amount = get_amount,
    get_space = get_space,
    has_item = has_item,
    get_max_slot = get_max_slot,
    pickup_at = pickup_at,
    place_at = place_at,
    pickup = pickup,
    place = place,
}
