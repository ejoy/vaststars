local MAX_AMOUNT <const> = 99999

local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local math_min = math.min
local math_max = math.max

local infinite_item = false

local function get_limit(item)
    local typeobject = assert(iprototype.queryById(item))
    return typeobject.backpack_limit or 0
end

local function set_infinite_item(b)
    infinite_item = b
end

local function _query(world, item)
    local e = assert(world.ecs:first "base chest:in building:in")
    for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(world, e.chest, idx)
        if not slot then
            break
        end
        if slot.item == item then
            return slot
        end
    end
end

local function query(world, item)
    if infinite_item then
        return MAX_AMOUNT
    end
    local slot = _query(world, item)
    if not slot then
        return 0
    end
    return slot.amount
end

local function pickup(world, item, amount)
    if infinite_item then
        return true
    end
    local e = assert(world.ecs:first "base chest:in building:in")
    return ichest.pickup(world, e, item, amount) > 0
end

local function place(world, item, amount)
    local e = assert(world.ecs:first "base building:in chest:update")
    return ichest.place(world, e, item, amount)
end

local function get_capacity(world, item)
    local slot = _query(world, item)
    return slot and math_max(slot.limit - slot.amount, 0) or get_limit(item)
end

local function move_to_inventory(world, e, idx)
    local slot = assert(ichest.get(world, e.chest, idx))
    if slot.item == 0 or slot.amount <= 0 then
        return 0
    end

    local available = math_min(get_capacity(world, slot.item), slot.amount)
    if available <= 0 then
        return 0
    end

    ichest.pickup_at(world, e, idx, available)
    place(world, slot.item, available)
    return available
end

local function inventory_to_chest(world, e, f)
    for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(world, e.chest, idx)
        if not slot then
            break
        end
        if slot.item == 0 then
            goto continue
        end
        local c = math_min(query(world, slot.item), ichest.get_space(slot))
        if c <= 0 then
            goto continue
        end

        assert(pickup(world, slot.item, c))
        ichest.place_at(world, e, idx, c)
        f(slot.item, c)
        ::continue::
    end
end

local function chest_to_inventory(world, e, f)
    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(world, e.chest, i)
        if not slot then
            break
        end
        if slot.item == 0 then
            goto continue
        end

        local c = move_to_inventory(world, e, i)
        if c <= 0 then
            goto continue
        end

        f(slot.item, c)
        ::continue::
    end
end

local function inventory_to_assembling(world, e, f)
    if e.assembling.recipe == 0 then
        return
    end

    local recipe = iprototype.queryById(e.assembling.recipe)
    local ingredients_n <const> = #recipe.ingredients//4 - 1

    for idx = 1, ingredients_n do
        local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        if iprototype.is_fluid_id(id) then
            goto continue
        end

        local slot = assert(ichest.get(world, e.chest, idx))
        local amount = ichest.get_amount(slot)
        if amount >= n then
            goto continue
        end

        local c = math_min(query(world, slot.item), n - amount)
        if c <= 0 then
            goto continue
        end
        assert(pickup(world, slot.item, c))
        ichest.place_at(world, e, idx, c)

        f(id, c)
        ::continue::
    end
end

local function assembling_to_inventory(world, e, f)
    if e.assembling.recipe == 0 then
        return
    end
    local recipe = iprototype.queryById(e.assembling.recipe)
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    for i = 1, results_n do
        local idx = ingredients_n + i
        local slot = assert(ichest.get(world, e.chest, idx))
        if iprototype.is_fluid_id(slot.item) then
            goto continue
        end

        local c = move_to_inventory(world, e, idx)
        if c <= 0 then
            goto continue
        end

        f(slot.item, c)
        ::continue::
    end
end

local function all(world)
    local e = assert(world.ecs:first "base chest:in building:in")
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
    query = query,
    place = place,
    pickup = pickup,
    all = all,
    get_capacity = get_capacity,
    inventory_to_chest = inventory_to_chest,
    chest_to_inventory = chest_to_inventory,
    inventory_to_assembling = inventory_to_assembling,
    assembling_to_inventory = assembling_to_inventory,
}