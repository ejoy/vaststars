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

function M.collect_item(world, e, check)
    local r = {}
    for i = 1, 256 do
        local slot = world:container_get(e, i)
        if not slot then
            break
        end
        if slot.item ~= 0 then
            if not check and slot.amount == 0 then
                goto continue
            end
            r[slot.item] = slot
        end
        ::continue::
    end
    return r
end

function M.get_amount(slot)
    return slot.amount - slot.lock_item
end

function M.get_space(slot)
    return slot.limit - slot.amount + slot.lock_space
end

-- special treatment for chest of the headquarter
local iprototype = require "gameplay.interface.prototype"
local debugger = require "debugger"

local function __get_item_stack(item)
    local typeobject = assert(iprototype.queryById(item))
    return typeobject.stack
end

local function __rebuild_chest(world, e, new_item)
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

    e.inventory.chest = world:container_create(table.concat(r))
end

local function __get_inventory_entity(world)
    local e = assert(world.ecs:first("inventory eid:in"))
    return world.entity[e.eid]
end

-- item count
-- this function assumes that there are already enough items in the chest
function M.move_to_inventory(world, chest, item, count)
    local e = __get_inventory_entity(world)
    local slot = M.collect_item(world, e.inventory)[item]
    if not slot then
        __rebuild_chest(world, e, item)
        slot = assert(M.collect_item(world, e.inventory, true)[item])
    end

    local existing = M.get_amount(slot)
    local stack = __get_item_stack(item)
    if existing >= stack then
        return false
    end

    local available = math.min(stack - existing, count)
    if not M.chest_pickup(world, chest, item, available) then
        return false
    end

    M.chest_place(world, e.inventory, item, available)
    return true, available
end

-- item count
function M.inventory_pickup(world, ...)
    if debugger.infinite_item then
        return true
    end

    local e = assert(world.ecs:first("inventory:in"))
    return M.chest_pickup(world, e.inventory, ...)
end

function M.get_inventory_item_count(world, item)
    if debugger.infinite_item then
        return 99999
    end

    local e = __get_inventory_entity(world)
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