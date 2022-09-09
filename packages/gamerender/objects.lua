local create_cache = require "utility.multiple_cache"
local iprototype = require "gameplay.interface.prototype"

local DEFAULT_CACHE_NAMES <const> = {"CONSTRUCTED"}
local DEFAULT_CACHE_NAME <const> = "CONSTRUCTED"

local ALL_CACHE_NAMES = {"SELECTED", "INDICATOR", "TEMPORARY", "CONFIRM", "CONSTRUCTED", "POWER_AREA"}

local objects = create_cache(ALL_CACHE_NAMES, "id", "REMOVED", "OBJECT_REMOVED", "teardown", "headquater", "fluidflow_id", "gameplay_eid") -- = {[id] = object, ...}
local tile_objects = create_cache(ALL_CACHE_NAMES, "coord", "id") -- = {[coord] = {id = xx, coord = coord}

local M = {}
function M:get(id, cache_names)
    cache_names = cache_names or DEFAULT_CACHE_NAMES
    assert(type(cache_names) == "table")
    local object = objects:get(cache_names, id)
    if object and object.OBJECT_REMOVED then
        return
    else
        return object
    end
end

function M:set(object, cache_name)
    cache_name = cache_name or DEFAULT_CACHE_NAME

    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    local w, h = iprototype.rotate_area(typeobject.area, object.dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local coord = iprototype.packcoord(object.x + i, object.y + j)
            tile_objects:set(cache_name, {coord = coord, id = object.id})
        end
    end

    objects:set(cache_name, object)
end

function M:coord(x, y, cache_names)
    cache_names = cache_names or DEFAULT_CACHE_NAMES
    local tile = tile_objects:get(cache_names, iprototype.packcoord(x, y))
    if not tile then
        return
    end
    local object = self:get(tile.id, cache_names)
    if object and object.OBJECT_REMOVED then
        return
    else
        return object
    end
end

function M:modify(x, y, cache_names, clone)
    local object = self:coord(x, y, cache_names)
    if not object then
        return
    end
    local _object = self:coord(x, y, {cache_names[1]})
    if not _object then
        _object = clone(object)
        self:set(_object, cache_names[1])
    end
    return _object
end

function M:remove(id, cache_name)
    cache_name = cache_name or DEFAULT_CACHE_NAME
    objects:remove(cache_name, id)

    for coord in tile_objects:select(cache_name, "id", id) do
        tile_objects:remove(cache_name, coord)
    end
end

function M:clear(cache_names)
    cache_names = cache_names or ALL_CACHE_NAMES
    objects:clear(cache_names)
    tile_objects:clear(cache_names)
end

function M:all(cache_name)
    cache_name = cache_name or DEFAULT_CACHE_NAME
    return objects:all(cache_name)
end

function M:select(...)
    return objects:select(...)
end

function M:selectall(index_field, cache_value, cache_names)
    local t = {}
    for id, obj in objects:selectall(cache_names, index_field, cache_value) do
        if not (obj.OBJECT_REMOVED == true) then
            t[id] = obj
        end
    end
    return next, t, nil
end

function M:commit(cache_name_1, cache_name_2)
    objects:commit(cache_name_1, cache_name_2)
    tile_objects:commit(cache_name_1, cache_name_2)
end

function M:cleanup(cache_name)
    for id, obj in objects:all(cache_name) do
        if obj.REMOVED then
            self:remove(id, cache_name)
        end
    end
end

function M:sync(...)
    objects:sync(...)
end

function M:empty(...)
    return objects:empty(...)
end

return M
