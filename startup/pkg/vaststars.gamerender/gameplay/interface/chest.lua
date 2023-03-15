local iprototype = require "gameplay.interface.prototype"

local M = {}

function M.chest_get(world, chest, i)
    local c = world:container_get(chest, i)
    if c and c.item == 0 then
        return
    end
    return c
end

-- prototype, count
function M.chest_pickup(world, chest, ...)
    return world:container_pickup(chest, ...)
end

-- prototype, count
function M.chest_place(world, chest, ...)
    return world:container_place(chest, ...)
end

function M.collect_item(world, e)
    local r = {}
    local typeobject = iprototype.queryById(e.building.prototype)
    for i = 1, typeobject.slots do
        local slot = M.chest_get(world, e.chest, i)
        if slot then
            r[slot.item] = slot
        end
    end
    return r
end

function M.add_req(world, e, prototype_name, count)
    local prototype = iprototype.queryByName(prototype_name).id
    local typeobject = iprototype.queryById(e.building.prototype)
    for i = 1, typeobject.slots do
        local slot = world:container_get(e.chest, i)
        if slot then
            if slot.item == prototype then
                world:container_set(e.chest, i, {limit = slot.limit + count})
                return
            end
        end
    end

    local info = world:chest_slot {
        type = "blue",
        item = prototype_name,
        amount = 0,
        limit = count,
    }
    world:container_add(e.chest, info)
end

function M.add_req_force(world, e, prototype_name, count)
    local prototype = iprototype.queryByName(prototype_name).id
    local typeobject = iprototype.queryById(e.building.prototype)
    for i = 1, typeobject.slots do
        local slot = world:container_get(e.chest, i)
        if slot then
            if slot.item == prototype then
                world:container_set(e.chest, i, {amount = slot.amount + count})
                return
            end
        end
    end

    local info = world:chest_slot {
        type = "blue",
        item = prototype_name,
        amount = count,
        limit = 0,
    }
    world:container_add(e.chest, info)
end

-- prototype, count
function M.base_chest_place(world, ...)
    local e = assert(world.ecs:first("base chest:in"))
    world:container_place(e.chest, ...)
end

-- prototype, count
function M.base_chest_pickup(world, ...)
    local e = assert(world.ecs:first("base chest:in"))
    return world:container_pickup(e.chest, ...)
end

function M.base_collect_item(world)
    local e = assert(world.ecs:first("base building:in chest:in"))
    return M.collect_item(world, e)
end

function M.base_add_req(world, prototype_name, count)
    local e = assert(world.ecs:first("base building:in chest:in"))
    return M.add_req(world, e, prototype_name, count)
end

function M.base_add_req_force(world, prototype_name, count)
    local e = assert(world.ecs:first("base building:in chest:in"))
    return M.add_req_force(world, e, prototype_name, count)
end
return M