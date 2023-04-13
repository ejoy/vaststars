local BUILDING_COMPONENTS = {
    io_shelves = true,
    drone_depot_shelf = true,
    assembling_icon = true,
}
local BUILDING_COMPONENT_METHODS = {
    on_position_change = true,
    remove = true,
}
local component_mt = {}
function component_mt:__index(k)
    assert(BUILDING_COMPONENTS[k], "invalid building component: " .. k)
    return rawget(self, k)
end
function component_mt:__newindex(k, v)
    for method in pairs(BUILDING_COMPONENT_METHODS) do
        assert(v[method], ("component '%s' does not support method '%s'"):format(k, method))
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