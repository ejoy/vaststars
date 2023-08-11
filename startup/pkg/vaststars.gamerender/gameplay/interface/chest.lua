local CHEST_COMPONENT <const> = {
    ["assembling"] = "chest",
    ["chest"] = "chest",
    ["laboratory"] = "chest",
    ["station_producer"] = "chest",
    ["station_consumer"] = "chest",
    ["hub"] = "hub",
}

local M = {}

M.MAX_SLOT = 256

function M.get_chest_component(e)
    for name, chest_component in pairs(CHEST_COMPONENT) do
        if e[name] then
            return chest_component
        end
    end
end

function M.get(world, ...)
    local c = world:container_get(...)
    if c and c.item == 0 then
        return
    end
    return c
end

function M.get_amount(slot)
    return slot.amount
end

function M.get_space(slot)
    return slot.limit - slot.amount - slot.lock_space
end

function M.set(world, ...)
    return world:container_set(...)
end

function M.collect_item(world, e)
    local r = {}
    for i = 1, M.MAX_SLOT do
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

return M
