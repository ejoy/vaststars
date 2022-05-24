local create_cache = require "utility.multiple_cache"

local cache_names = {"INDICATOR", "TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local ALL_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local objects_index_field = {"id", "teardown", "headquater"}
local tile_objects_index_field = {"coord", "id"}

local objects = create_cache(cache_names, table.unpack(objects_index_field)) -- = {[id] = object, ...}
local tile_objects = create_cache(cache_names, table.unpack(tile_objects_index_field)) -- = {[coord] = {id = xx, fluidbox_dir = {[xx] = true, ...}}, ...}

local global = {
    mode = "normal",
    cache_names = ALL_CACHE_NAMES,
    objects = objects,
    tile_objects = tile_objects,
}

return global