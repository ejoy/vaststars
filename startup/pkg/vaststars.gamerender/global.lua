local create_buildings = require "building_components"

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
    buildings = create_buildings(), -- { object-id = {}, ...}
}
