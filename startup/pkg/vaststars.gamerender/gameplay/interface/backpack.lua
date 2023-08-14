local iBackpack = import_package "vaststars.gameplay".interface "backpack"
local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local debugger = require "debugger"
local math_min = math.min
local MAX_AMOUNT <const> = 99999

local function get_backpack_limit(item)
    local typeobject = assert(iprototype.queryById(item))
    return typeobject.backpack_limit or 0
end

local function set_base_changed(world)
    local e = world.ecs:first("base base_changed?out")
    e.base_changed = true
    world.ecs:submit(e)
end

local function query(world, item)
    return debugger.infinite_item and MAX_AMOUNT or iBackpack.query(world, item)
end

local function pickup(world, item, amount)
    if debugger.infinite_item then
        return true
    end
    local ok = iBackpack.pickup(world, item, amount)
    if ok then
        set_base_changed(world)
    end
    return ok
end

local function get_moveable_count(world, item, count)
    local limit = get_backpack_limit(item)
    local existing = iBackpack.query(world, item)
    if existing >= limit then
        return 0
    end

    return math_min(limit - existing, count)
end

local function get_placeable_count(world, item, count)
    local existing = debugger.infinite_item and MAX_AMOUNT or iBackpack.query(world, item)
    return math_min(count, existing)
end

local function move_to_backpack(world, chest, idx)
    local slot = assert(world:container_get(chest, idx))
    if slot.item == 0 or slot.amount <= 0 then
        return 0
    end

    local existing = iBackpack.query(world, slot.item)
    local limit = get_backpack_limit(slot.item)
    if existing >= limit then
        return 0
    end

    local available = math_min(limit - existing, slot.amount)
    assert(available > 0)

    -- if the number of available items to take is insufficient, then forcibly unlock the specified count
    local lock_item = slot.lock_item
    local unlocked = slot.amount - lock_item
    if available > unlocked then
        lock_item = lock_item - (available - unlocked)
    end

    ichest.set(world, chest, idx, {lock_item = lock_item, amount = slot.amount - available})
    iBackpack.place(world, slot.item, available)
    set_base_changed(world)
    return available
end

local function backpack_to_chest(world, e, f)
    local chest = e[ichest.get_chest_component(e)]
    for idx = 1, ichest.MAX_SLOT do
        local slot = ichest.get(world, chest, idx)
        if not slot then
            break
        end

        local c = get_placeable_count(world, slot.item, ichest.get_space(slot))
        if c <= 0 then
            goto continue
        end

        assert(pickup(world, slot.item, c))
        ichest.set(world, chest, idx, {amount = ichest.get_amount(slot) + c})

        f(slot.item, c)
        ::continue::
    end
end

local function chest_to_backpack(world, e, f)
    local chest = e[ichest.get_chest_component(e)]
    for i = 1, ichest.MAX_SLOT do
        local slot = ichest.get(world, chest, i)
        if not slot then
            break
        end

        local c = move_to_backpack(world, chest, i)
        if c <= 0 then
            goto continue
        end

        f(slot.item, c)
        ::continue::
    end
end

local function backpack_to_assembling(world, e, f)
    if e.assembling.recipe == 0 then
        return
    end

    local recipe = iprototype.queryById(e.assembling.recipe)
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local chest = e[ichest.get_chest_component(e)]

    for idx = 1, ingredients_n do
        local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        if iprototype.is_fluid_id(id) then
            goto continue
        end

        local slot = assert(ichest.get(world, chest, idx))
        local amount = ichest.get_amount(slot)
        if amount >= n then
            goto continue
        end

        local c = get_placeable_count(world, slot.item, n - amount)
        if c <= 0 then
            goto continue
        end
        assert(pickup(world, slot.item, c))
        ichest.set(world, chest, idx, {amount = amount + c})

        f(id, c)
        ::continue::
    end
end

local function assembling_to_backpack(world, e, f)
    if e.assembling.recipe == 0 then
        return
    end
    local chest = e[ichest.get_chest_component(e)]
    local recipe = iprototype.queryById(e.assembling.recipe)
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    for i = 1, results_n do
        local idx = ingredients_n + i
        local slot = assert(ichest.get(world, chest, idx))
        if iprototype.is_fluid_id(slot.item) then
            goto continue
        end

        local c = move_to_backpack(world, chest, idx)
        if c <= 0 then
            goto continue
        end

        f(slot.item, c)
        ::continue::
    end
end

local function can_move_to_backpack(world, chest)
    for i = 1, ichest.MAX_SLOT do
        local slot = world:container_get(chest, i)
        if not slot then
            break
        end
        if slot.item == 0 then
            goto continue
        end
        local count = get_moveable_count(world, slot.item, slot.amount)
        if count < slot.amount then
            return false
        end
        ::continue::
    end
    return true
end

return {
    query = query,
    pickup = pickup,
    get_moveable_count = get_moveable_count,
    get_placeable_count = get_placeable_count,
    move_to_backpack = move_to_backpack,
    can_move_to_backpack = can_move_to_backpack,
    backpack_to_chest = backpack_to_chest,
    chest_to_backpack = chest_to_backpack,
    backpack_to_assembling = backpack_to_assembling,
    assembling_to_backpack = assembling_to_backpack,
}