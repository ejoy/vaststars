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
    frame_ratio = 30,
    frame_count = 0,
    building_coord_system = require "coord_transform"(255, 255),
    logistic_coord_system = require "coord_transform"(256, 256),
    construct_queue = create_consruct_queue(),
    base_chest_cache = tracedoc.new {},
    roadnet = {}, -- = {[coord] = {prototype_name, dir}, ...}
}
