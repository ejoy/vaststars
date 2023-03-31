return {
    fluidflow_id = 0,
    science = {},
    statistic = {
        valid = false,
    },
    building_coord_system = require "coord_transform"(255, 255),
    logistic_coord_system = require "coord_transform"(256, 256),
    roadnet = {}, -- = {[coord] = {prototype_name, dir}, ...}
}
