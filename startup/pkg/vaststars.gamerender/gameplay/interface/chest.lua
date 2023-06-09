local M = {}

function M.chest_get(world, ...)
    local c = world:container_get(...)
    if c and c.item == 0 then
        return
    end
    return c
end

function M.chest_pickup(world, ...)
    return world:container_pickup(...)
end

function M.chest_place(world, ...)
    return world:container_place(...)
end

function M.collect_item(world, e)
    local r = {}
    for i = 1, 256 do
        local slot = world:container_get(e, i)
        if not slot then
            break
        end
        if slot.item ~= 0 and slot.amount ~= 0 then
            r[slot.item] = slot
        end
    end
    return r
end

function M.first_item(world, e, item)
    for i = 1, 256 do
        local slot = world:container_get(e, i)
        if not slot then
            break
        end
        if slot.item == item then
            return slot, i
        end
    end
end

function M.get_amount(slot)
    -- return slot.amount - slot.lock_item
    return slot.amount
end

function M.get_space(slot)
    return slot.limit - slot.amount + slot.lock_space
end

-- special treatment for chest of the headquarter
local iprototype = require "gameplay.interface.prototype"
local debugger = require "debugger"
local InvalidChest <const> = 0

local function __get_item_stack(item)
    local typeobject = assert(iprototype.queryById(item))
    return typeobject.stack or 0
end

local function __rebuild_chest(world, e, new_item)
    world.ecs:extend(e, "building:in")
    local typeobject = iprototype.queryById(e.building.prototype)

    local r = {}
    for i = 1, 256 do
        local slot = world:container_get(e.inventory, i)
        if not slot then
            break
        end
        if slot.item ~= 0 then
            r[#r+1] = world:chest_slot {
                type = typeobject.chest_type,
                item = slot.item,
                amount = slot.amount,
            }
        end
    end

    r[#r+1] = world:chest_slot {
        type = typeobject.chest_type,
        item = new_item,
        amount = 0,
        limit = __get_item_stack(new_item),
    }

    if e.inventory and e.inventory.chest ~= InvalidChest then
        world:container_destroy(e.inventory)
    end
    e.inventory.chest = world:container_create(table.concat(r))
end

-- item count
-- this function assumes that there are already enough items in the chest
function M.move_to_inventory(world, chest, item, count)
    local e = world.ecs:first("inventory:update inventory_changed?update")
    local slot = M.first_item(world, e.inventory, item)
    if not slot then
        __rebuild_chest(world, e, item)
        slot = M.first_item(world, e.inventory, item)
        assert(slot)
    end

    local existing = M.get_amount(slot)
    local stack = __get_item_stack(item)
    if existing >= stack then
        return false
    end

    local available = math.min(stack - existing, count)
    do
        -- if the number of available items to take is insufficient, then forcibly unlock the specified count
        local slot, idx = M.first_item(world, chest, item)
        if available > slot.amount - slot.lock_item then
            local unlock = available - (slot.amount - slot.lock_item)
            world:container_set(chest, idx, {lock_item = slot.lock_item - unlock})
        end
    end
    if not M.chest_pickup(world, chest, item, available) then
        return false
    end

    M.chest_place(world, e.inventory, item, available)
    e.inventory_changed = true
    world.ecs:submit(e)
    return true, available
end

function M.get_moveable_count(world, item, count)
    local stack = __get_item_stack(item)
    local e = world.ecs:first("inventory:in")
    local slot = M.collect_item(world, e.inventory)[item]
    if not slot then
        return true, math.min(stack, count)
    end

    local existing = M.get_amount(slot)
    if existing >= stack then
        log.debug(("get_moveable_count: %s %s >= %s"):format(item, existing, stack))
        return false
    end

    local available = math.min(stack - existing, count)
    return true, available
end

function M.can_move_to_inventory(world, chest)
    local slots = M.collect_item(world, chest)
    for _, slot in pairs(slots) do
        if slot.type == "unknown" then
            goto continue
        end
        local ok, count = M.get_moveable_count(world, slot.item, slot.amount)
        if not ok then
            log.debug(("can't move to inventory: %s %s"):format(slot.item, slot.amount))
            return false
        end
        if count < slot.amount then
            log.debug(("can't move to inventory: %s %s < %s"):format(slot.item, count, slot.amount))
            return false
        end
        ::continue::
    end
    return true
end

-- item count
function M.inventory_pickup(world, ...)
    if debugger.infinite_item then
        return true
    end

    local e = world.ecs:first("inventory:update inventory_changed?update")
    e.inventory_changed = true
    local res = M.chest_pickup(world, e.inventory, ...)
    if res then
        world.ecs:submit(e)
    end
    return res
end

function M.get_inventory_item_count(world, item)
    if debugger.infinite_item then
        return 99999
    end

    local e = world.ecs:first("inventory:in")
    for i = 1, 256 do
        local slot = world:container_get(e.inventory, i)
        if not slot then
            break
        end
        if slot.item == item then
            return M.get_amount(slot)
        end
    end
    return 0
end

return M