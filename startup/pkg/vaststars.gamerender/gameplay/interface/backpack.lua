local iBackpack = import_package "vaststars.gameplay".interface "backpack"
local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local debugger = require "debugger"
local math_min = math.min

local M = {}

local function get_backpack_limit(item)
    local typeobject = assert(iprototype.queryById(item))
    return typeobject.backpack_limit or 0
end

local function set_base_changed(world)
    local e = world.ecs:first("base base_changed?out")
    e.base_changed = true
    world.ecs:submit(e)
end

function M.move_to_backpack(world, chest, idx)
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

    world:container_set(chest, idx, { lock_item = lock_item, amount = slot.amount - available })
    iBackpack.place(world, slot.item, available)
    set_base_changed(world)
    return available
end


function M.can_move_to_backpack(world, chest)
    for i = 1, ichest.MAX_SLOT do
        local slot = world:container_get(chest, i)
        if not slot then
            break
        end
        if slot.type == "unknown" then
            goto continue
        end
        if slot.item == 0 then
            goto continue
        end
        local count = M.get_moveable_count(world, slot.item, slot.amount)
        if count < slot.amount then
            log.debug(("can't move to backpack: %s %s < %s"):format(slot.item, count, slot.amount))
            return false
        end
        ::continue::
    end
    return true
end

function M.get_moveable_count(world, item, count)
    local limit = get_backpack_limit(item)
    local existing = iBackpack.query(world, item)
    if existing >= limit then
        return 0
    end

    return math_min(limit - existing, count)
end

function M.get_placeable_count(world, item, max_count)
    local existing
    if debugger.infinite_item then
        existing = 99999
    else
        existing = iBackpack.query(world, item)
    end

    return math_min(max_count, existing)
end

function M.pickup(world, item, amount)
    if debugger.infinite_item then
        return true
    end
    local ok = iBackpack.pickup(world, item, amount)
    if ok then
        set_base_changed(world)
    end
    return ok
end

function M.query(world, item)
    if debugger.infinite_item then
        return 99999
    end
    return iBackpack.query(world, item)
end

return M