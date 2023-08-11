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

local function get_placeable_count(world, item, max_count)
    local existing = debugger.infinite_item and MAX_AMOUNT or iBackpack.query(world, item)
    return math_min(max_count, existing)
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

    ichest.set(world, chest, idx, { lock_item = lock_item, amount = slot.amount - available })
    iBackpack.place(world, slot.item, available)
    set_base_changed(world)
    return available
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
}