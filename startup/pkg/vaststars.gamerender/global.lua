local BUILDING_COMPONENTS = {
    io_shelves = true,
    drone_depot_shelf = true,
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

return {
    fluidflow_id = 0,
    science = {},
    statistic = {
        valid = false,
    },
    building_coord_system = require "coord_transform"(255, 255),
    logistic_coord_system = require "coord_transform"(256, 256),
    roadnet = {}, -- = {[coord] = {prototype_name, dir}, ...}
    item_transfer_src = nil,
    item_transfer_dst = nil,
    buildings = setmetatable({}, mt), -- { object-id = {}, ...}
}
