local ecs = ...
local world = ecs.world

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iobject = ecs.require "object"
local iflow_connector = require "gameplay.interface.flow_connector"

--
local M = {}

function M:revert_changes(revert_cache_names)
    local t = {}
    for _, cache_name in ipairs(revert_cache_names) do
        for id, object in objects:all(cache_name) do
            t[id] = object
        end
    end
    objects:clear(revert_cache_names)

    for id, object in pairs(t) do
        local old_object = objects:get(id, {"CONFIRM", "CONSTRUCTED"})
        if old_object then
            object.prototype_name = old_object.prototype_name
            object.dir = old_object.dir
            object.state = old_object.state
            object.fluid_name = old_object.fluid_name
            object.fluidflow_id = old_object.fluidflow_id
        else
            iobject.remove(object)
        end
    end
    iobject.flush() -- object is removed from cache, so we need to flush it, else it will keep the old state
end

local function get_dir_coord(x, y, dir, dx, dy)
    local dir_coord = {
        ['N'] = {x = 0,  y = -1},
        ['E'] = {x = 1,  y = 0},
        ['S'] = {x = 0,  y = 1},
        ['W'] = {x = -1, y = 0},
    }

    local function axis_value(v)
        v = math.max(v, 0)
        v = math.min(v, 255)
        return v
    end

    local c = assert(dir_coord[dir])
    return axis_value(x + c.x * (dx or 1)), axis_value(y + c.y * (dy or 1))
end

function M:get_dir_coord(...)
    return get_dir_coord(...)
end

local function refresh_pipe(prototype_name, dir, entry_dir, value)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    if not typeobject.pipe then
        return
    end

    return iflow_connector.set_connection(prototype_name, dir, entry_dir, value)
end

function M:refresh_pipe(...)
    return refresh_pipe(...)
end

function M:refresh_flow_shape(cache_names_r, cache_name_w, object, entry_dir, raw_x, raw_y) -- TODO
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    if typeobject.pipe then
        local prototype_name, dir = refresh_pipe(object.prototype_name, object.dir, entry_dir)
        if prototype_name then
            object = iobject.clone(object)
            object.prototype_name = prototype_name
            object.dir = dir
            objects:set(object, cache_name_w)
        end
    end

    local dx, dy = self:get_dir_coord(raw_x, raw_y, entry_dir)
    local object = objects:coord(dx, dy, cache_names_r)
    if object then
        local typeobject = iprototype.queryByName("entity", object.prototype_name)
        if typeobject.pipe then
            local prototype_name, dir = refresh_pipe(object.prototype_name, object.dir, iprototype.reverse_dir(entry_dir))
            if prototype_name then
                object = iobject.clone(object)
                object.prototype_name = prototype_name
                object.dir = dir
                objects:set(object, cache_name_w)
            end
        end
    end
end

return M