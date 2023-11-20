local MAX_AMOUNT <const> = 99999

local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local math_max = math.max

local infinite_item = false
local lorry_prototype = {}

local function get_limit(item)
    local typeobject = assert(iprototype.queryById(item))
    return typeobject.backpack_limit or 0
end

local function set_infinite_item(b)
    infinite_item = b
end

local function set_lorry_list(l)
    lorry_prototype = l
end

local function get_entity(world)
    return world.ecs:first "base chest:in building:in" or error "can not found base"
end

local function is_valid_item(item)
    if lorry_prototype[item] then
        return true
    end
    local typeobject = iprototype.queryById(item)
    return iprototype.has_type(typeobject.type, "building")
end

local function _query(world, item)
    local e = get_entity(world)
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

local function query(world, item)
    if infinite_item then
        return MAX_AMOUNT
    end
    local slot = _query(world, item)
    if not slot then
        return 0
    end
    if slot.item == 0 or slot.amount == 0 then
        return 0
    end
    return slot.amount
end

local function pickup(world, item, amount)
    if infinite_item then
        return true
    end
    ichest.pickup(world, get_entity(world), item, amount)
    return true
end

local function place(world, item, amount)
    assert(is_valid_item(item))
    return ichest.place(world, get_entity(world), item, amount)
end

local function get_capacity(world, item)
    if not is_valid_item(item) then
        return 0
    end
    local slot = _query(world, item)
    if not slot then
        return 0
    end
    if slot.item == 0 or slot.amount == 0 then
        return get_limit(item)
    end
    return math_max(slot.limit - slot.amount, 0)
end

local function all(world)
    local e = get_entity(world)
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
    set_lorry_list = set_lorry_list,
    query = query,
    get_capacity = get_capacity,
    place = place,
    pickup = pickup,
    all = all,
    is_valid_item = is_valid_item,
}