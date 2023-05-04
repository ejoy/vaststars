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
        r[slot.item] = slot
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

-- index
function M.base_chest_get(world, ...)
    local e = assert(world.ecs:first("base base_chest:in"))
    return M.chest_get(world, e.base_chest, ...)
end

-- item count
function M.base_chest_pickup(world, ...)
    local e = assert(world.ecs:first("base base_chest:in"))
    return M.chest_pickup(world, e.base_chest, ...)
end

-- item count
function M.base_chest_place(world, item, count)
    local typeobject = assert(iprototype.queryById(item))
    local stack = typeobject.stack

    local e = assert(world.ecs:first("base base_chest:in"))
    local r = M.collect_item(world, e.base_chest)
    local slot = r[item]
    if slot and slot.amount + count > stack then
        return false
    end
    if count > stack then
        return false
    end

    M.chest_place(world, e.base_chest, item, count)
    return true
end

return M