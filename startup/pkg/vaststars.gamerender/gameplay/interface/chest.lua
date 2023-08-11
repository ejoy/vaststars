local CHEST_COMPONENT <const> = {
    ["assembling"] = "chest",
    ["chest"] = "chest",
    ["laboratory"] = "chest",
    ["station_producer"] = "chest",
    ["station_consumer"] = "chest",
    ["hub"] = "hub",
}

local MAX_SLOT <const> = 256

local function get_chest_component(e)
    for name, chest_component in pairs(CHEST_COMPONENT) do
        if e[name] then
            return chest_component
        end
    end
end

local function get(world, ...)
    local c = world:container_get(...)
    if c and c.item == 0 then
        return
    end
    return c
end

local function get_amount(slot)
    return slot.amount
end

local function get_space(slot)
    return slot.limit - slot.amount - slot.lock_space
end

local function set(world, ...)
    return world:container_set(...)
end

local function collect_item(world, e)
    local r = {}
    for i = 1, MAX_SLOT do
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

return {
    MAX_SLOT = MAX_SLOT,
    get_chest_component = get_chest_component,
    get = get,
    get_amount = get_amount,
    get_space = get_space,
    set = set,
    collect_item = collect_item,
}
