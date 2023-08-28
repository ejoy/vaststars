local create_buildings = require "building_components"

return {
    startup_args = {},
    science = {},
    statistic = {
        valid = false,
    },
    buildings = create_buildings(), -- { object-id = {}, ...}
}
