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
        local slot = world:container_get(e.chest, i)
        if not slot then
            break
        end
        r[slot.item] = slot
    end
    return r
end

return M