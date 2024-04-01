local MAX_AMOUNT <const> = 99999

local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local math_max = math.max

local infinite_item = false
local lorry_ids = {}

local function _get_limit(item)
    local typeobject = assert(iprototype.queryById(item))
    return typeobject.backpack_limit or 0
end

local function _get_base_entity(world)
    return world.ecs:first "base building:in chest:in eid:in" or error "can not found base"
end

local function _query(world, e, item)
    local first_empty
    for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(world, e.chest, idx)
        if not slot then
            break
        end
        if slot.item == item then
            return slot
        end
        if not first_empty then
            if slot.item == 0 or slot.amount == 0 then
                first_empty = slot
            end
        end
    end
    return first_empty
end

local function set_infinite_item(b)
    infinite_item = b
end

local function set_lorry_ids(l)
    lorry_ids = l
end

-- The chest of the command center can only hold buildings or lorries
local function is_valid_item(item)
    if lorry_ids[item] then
        return true
    end
    local typeobject = iprototype.queryById(item)
    return iprototype.has_type(typeobject.type, "building")
end

local function query(world, e, item)
    if infinite_item then
        return MAX_AMOUNT
    end
    local slot = _query(world, e, item)
    if not slot then
        return 0
    end
    if slot.item == 0 or slot.amount == 0 then
        return 0
    end
    return slot.amount
end

local function pickup(world, e, item, amount)
    if infinite_item then
        return true
    end
    if query(world, e, item) < amount then
        return false
    end
    ichest.pickup(world, e, item, amount)
    return true
end

local function get_capacity(world, e, item)
    if not is_valid_item(item) then
        return 0
    end
    local slot = _query(world, e, item)
    if not slot then
        return 0
    end
    if slot.item == 0 or slot.amount == 0 then
        return _get_limit(item)
    end
    return math_max(slot.limit - slot.amount, 0)
end

local function place(world, e, item, amount)
    if get_capacity(world, e, item) < amount then
        return false
    end
    assert(is_valid_item(item))
    ichest.place(world, e, item, amount)
    return true
end

local function all(world, e)
    local items = {}
    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(world, e.chest, i)
        if not slot then
            break
        end
        if slot.item ~= 0 and slot.amount > 0 then
            items[#items+1] = slot
        end
    end
    return items
end

return {
    set_infinite_item = set_infinite_item,
    set_lorry_ids = set_lorry_ids,
    query = query,
    get_capacity = get_capacity,
    place = place,
    pickup = pickup,
    all = all,
    is_valid_item = is_valid_item,
    get_base_entity = _get_base_entity,
}