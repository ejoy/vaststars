local BUILDING_COMPONENTS = {
    io_shelves = true,
    drone_depot_shelf = true,
}
local component_mt = {}
function component_mt:__index(k)
    assert(BUILDING_COMPONENTS[k], "invalid building component: " .. k)
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
