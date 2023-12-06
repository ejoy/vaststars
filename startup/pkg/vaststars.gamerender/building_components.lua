local BUILDING_COMPONENTS = {
    io_shelves = true,
    station_shelf = true,
    depot_items = true,
    assembling_icon = true,
    chimney_icon = true,
    consumer_icon = true,
    storage_tank_icon = true,
}
local BUILDING_COMPONENT_METHODS = {
    on_position_change = true,
    remove = true,
}
local component_mt = {}
function component_mt:__index(k)
    local _ = BUILDING_COMPONENTS[k] or error("invalid building component: " .. k)
    return rawget(self, k)
end
function component_mt:__newindex(k, v)
    if v ~= nil then
        for method in pairs(BUILDING_COMPONENT_METHODS) do
            local _ = v[method] or error(("component '%s' does not support method '%s'"):format(k, method))
        end
    end
    return rawset(self, k, v)
end

local mt = {}
function mt:__index(k)
    self[k] = setmetatable({}, component_mt)
    return self[k]
end

return function()
    return setmetatable({}, mt)
end