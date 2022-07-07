local create_cache = require "utility.multiple_cache"
local CONSTRUCT_INVENTORY_CACHE_NAMES = {"TEMPORARY", "CONFIRM"}

return {
    mode = "normal",
    fluidflow_id = 0,
    science = {},
    construct_inventory = create_cache(CONSTRUCT_INVENTORY_CACHE_NAMES, "prototype"),
}
