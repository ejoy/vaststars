local create_buildings = require "building_components"

return {
    startup_args = {},
    is_webserver_started = false,
    science = {},
    statistic = {
        valid = false,
    },
    buildings = create_buildings(), -- { object-id = {}, ...}
}
