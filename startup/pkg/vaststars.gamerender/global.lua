local create_buildings = require "building_components"

return {
    startup_args = {},
    science = {},
    statistic = {
        valid = false,
    },
    coord_system = require "coord_transform"(256, 256),
    buildings = create_buildings(), -- { object-id = {}, ...}
}
