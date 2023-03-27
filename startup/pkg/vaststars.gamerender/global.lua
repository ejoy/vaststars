local tracedoc = require "utility.tracedoc"
local create_consruct_queue = require "construct_queue"

return {
    fluidflow_id = 0,
    science = {},
    statistic = {
        pending_eid = {},
        power = {},
        power_group = {},
        -- power_consumed = {},
        -- power_generated = {}
    },
    building_coord_system = require "coord_transform"(255, 255),
    logistic_coord_system = require "coord_transform"(256, 256),
    construct_queue = create_consruct_queue(),
    roadnet = {}, -- = {[coord] = {prototype_name, dir}, ...}
}
