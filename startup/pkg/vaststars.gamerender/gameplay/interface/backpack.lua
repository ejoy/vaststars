local MAX_AMOUNT <const> = 99999

local iBackpack = import_package "vaststars.gameplay".interface "backpack"
local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local debugger = require "debugger"
local math_min = math.min

local function get_backpack_limit(item)
    local typeobject = assert(iprototype.queryById(item))
    return typeobject.backpack_limit or 0
end

local function set_backpack_changed(world)
    world.ecs:new {
        backpack_changed = true
    }
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
        set_backpack_changed(world)
    end
    return ok
end

local function place(world, item, amount)
    return iBackpack.place(world, item, amount)
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

local function move_to_backpack(world, e, idx)
    local slot = assert(ichest.get(world, e.chest, idx))
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

    ichest.pickup(world, e, idx, available)
    iBackpack.place(world, slot.item, available)
    set_backpack_changed(world)
    return available
end

local function backpack_to_chest(world, e, f)
    for idx = 1, ichest.MAX_SLOT do
        local slot = ichest.get(world, e.chest, idx)
        if not slot then
            break
        end
        if slot.item == 0 then
            goto continue
        end

        local c = get_placeable_count(world, slot.item, ichest.get_space(slot))
        if c <= 0 then
            goto continue
        end

        assert(pickup(world, slot.item, c))
        ichest.place(world, e, idx, c)
        f(slot.item, c)
        ::continue::
    end
end

local function chest_to_backpack(world, e, f)
    for i = 1, ichest.MAX_SLOT do
        local slot = ichest.get(world, e.chest, i)
        if not slot then
            break
        end
        if slot.item == 0 then
            goto continue
        end

        local c = move_to_backpack(world, e, i)
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

        local c = get_placeable_count(world, slot.item, n - amount)
        if c <= 0 then
            goto continue
        end
        assert(pickup(world, slot.item, c))
        ichest.place(world, e, idx, c)

        f(id, c)
        ::continue::
    end
end

local function assembling_to_backpack(world, e, f)
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

        local c = move_to_backpack(world, e, idx)
        if c <= 0 then
            goto continue
        end

        f(slot.item, c)
        ::continue::
    end
end

local function can_move_to_backpack(world, e, item)
    for i = 1, ichest.MAX_SLOT do
        local slot = ichest.get(world, e.chest, i)
        if not slot then
            break
        end
        if slot.item ~= item then
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
    place = place,
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