local create_buildings = require "building_components"

return {
    init = false,
    startup_args = {},
    science = {},
    statistic = {
        valid = false,
    },
    buildings = create_buildings(), -- { object-id = {}, ...}
}
