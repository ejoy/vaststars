local iprototype = require "gameplay.interface.prototype"

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
    local typeobject = iprototype.queryById(e.building.prototype)
    for i = 1, typeobject.slots do
        local slot = M.chest_get(world, e.chest, i)
        if slot then
            r[slot.item] = slot
        end
    end
    return r
end

return M