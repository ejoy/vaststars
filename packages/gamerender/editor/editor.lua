local ecs = ...
local world = ecs.world

local objects = require "objects"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local vsobject_manager = ecs.require "vsobject_manager"
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local flow_shape = require "gameplay.utility.flow_shape"
local ifluid = require "gameplay.interface.fluid"
local terrain = ecs.require "terrain"

--
local M = {}

function M:clone_object(object)
    local t = {}
    for k, v in pairs(object) do
        t[k] = v
    end
    return t
end

function M:revert_changes(revert_cache_names)
    local t = {}
    for _, cache_name in ipairs(revert_cache_names) do
        for id, object in objects:all(cache_name) do
            t[id] = object
        end
    end
    objects:revert(revert_cache_names)

    for id, object in pairs(t) do
        local old_object = objects:get(id, EDITOR_CACHE_NAMES)
        if old_object then
            local vsobject = assert(vsobject_manager:get(object.id))
            vsobject:update {prototype_name = old_object.prototype_name, type = old_object.state}
            vsobject:set_dir(old_object.dir)
        else
            local vsobject = assert(vsobject_manager:get(object.id))
            vsobject:remove()
        end
    end
end

function M:teardown_begin()
    self:revert_changes({"TEMPORARY", "CONFIRM"})
end

local get_dir_coord ; do
    local dir_coord = {
        ['N'] = {x = 0,  y = -1},
        ['E'] = {x = 1,  y = 0},
        ['S'] = {x = 0,  y = 1},
        ['W'] = {x = -1, y = 0},
    }
    function get_dir_coord(x, y, dir, dx, dy)
        local c = assert(dir_coord[dir])
        return x + c.x * (dx or 1), y + c.y * (dy or 1)
    end
end
function M:get_dir_coord(...)
    return get_dir_coord(...)
end

local function refresh_pipe(prototype_name, dir, entry_dir, value)
    local typeobject = iprototype:queryByName("entity", prototype_name)
    if not typeobject.pipe then
        return
    end

    local state = flow_shape:to_state(prototype_name:gsub(".*%-(%u).*", "%1"), dir)
    state = flow_shape:set_state(state, iprototype:dir_tonumber(entry_dir), value or 1)
    local ntype, dir = flow_shape:to_type_dir(state)
    return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(ntype)), dir
end

function M:refresh_pipe(...)
    return refresh_pipe(...)
end

function M:refresh_flow_shape(cache_names_r, cache_name_w, object, entry_dir, raw_x, raw_y) -- TODO
    local vsobject = assert(vsobject_manager:get(object.id))
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    if typeobject.pipe then
        local prototype_name, dir = refresh_pipe(object.prototype_name, object.dir, entry_dir)
        if prototype_name then
            object = self:clone_object(object)
            object.prototype_name = prototype_name
            object.dir = dir

            vsobject:update {prototype_name = prototype_name}
            vsobject:set_dir(dir)

            objects:set(object, cache_name_w)
        end
    end

    local dx, dy = self:get_dir_coord(raw_x, raw_y, entry_dir)
    local object = assert(objects:coord(dx, dy, cache_names_r))
    if object then
        local typeobject = iprototype:queryByName("entity", object.prototype_name)
        if typeobject.pipe or typeobject.road then
            local vsobject = assert(vsobject_manager:get(object.id))
            local prototype_name, dir = refresh_pipe(object.prototype_name, object.dir, iprototype:opposite_dir(entry_dir))
            if prototype_name then
                object = self:clone_object(object)
                object.prototype_name = prototype_name
                object.dir = dir

                vsobject:update {prototype_name = prototype_name}
                vsobject:set_dir(dir)

                objects:set(object, cache_name_w)
            end
        end
    end
end

local function shift_pipe(self, object, prototype_name, dir)
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    if not typeobject.pipe then
        return
    end

    vsobject_manager:remove(object.id)
    gameplay_core.remove_entity(object.gameplay_eid)
    objects:remove(object.id)

    local position = assert(terrain.get_position_by_coord(object.x, object.y, iprototype:rotate_area(typeobject.area, object.dir)))
    object = self:clone_object(object)
    object.prototype_name = prototype_name
    object.dir = dir

    local vsobject = vsobject_manager:create {
        prototype_name = prototype_name,
        dir = dir,
        position = position,
        type = "constructed",
    }
    object.id = vsobject.id
    object.gameplay_eid = gameplay_core.create_entity(object)

    objects:set(object)
end

local function is_connection(self, x1, y1, dir1, x2, y2, dir2)
    local dx1, dy1 = self:get_dir_coord(x1, y1, dir1)
    local dx2, dy2 = self:get_dir_coord(x2, y2, dir2)
    return (dx1 == x2 and dy1 == y2) and (dx2 == x1 and dy2 == y1)
end

local function teardown(self, object, changed_set)
    for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, "")) do
        local dx, dy = self:get_dir_coord(v.x, v.y, v.dir)
        local nobject = objects:coord(dx, dy)
        if nobject then
            local typeobject = iprototype:queryByName("entity", nobject.prototype_name)
            if typeobject.pipe then
                for _, v1 in ipairs(ifluid:get_fluidbox(nobject.prototype_name, nobject.x, nobject.y, nobject.dir, nobject.fluid_name)) do
                    if is_connection(self, v.x, v.y, v.dir, v1.x, v1.y, v1.dir) then
                        local prototype_name, dir = self:refresh_pipe(nobject.prototype_name, nobject.dir, v1.dir, 0)
                        if prototype_name ~= nobject.prototype_name or dir ~= nobject.dir then
                            nobject.prototype_name = prototype_name
                            nobject.dir = dir
                            changed_set[nobject.id] = nobject
                        end
                    end
                end
            end
        end
    end
end

function M:teardown_complete()
    local changed_set = {}
    local removed_set = {}
    for id, object in objects:select("TEMPORARY", "teardown", true) do
        teardown(self, object, changed_set)
        removed_set[object.id] = object
    end

    for id, object in pairs(removed_set) do
        vsobject_manager:remove(id)
        objects:remove(object.id)
        gameplay_core.remove_entity(object.gameplay_eid)
        changed_set[id] = nil
    end

    for id, object in pairs(changed_set) do
        shift_pipe(self, object, object.prototype_name, object.dir)
    end

    gameplay_core.build()

    objects:clear({"TEMPORARY"})
end

function M:teardown(id)
    local object = self:clone_object(assert(objects:get(id, EDITOR_CACHE_NAMES)))
    local vsobject = assert(vsobject_manager:get(id))

    object.teardown = not object.teardown

    if object.teardown then
        object.state = "teardown"
        vsobject:update {type = "teardown"}
    else
        object.state = "constructed"
        vsobject:update {type = "constructed"}
    end
    objects:set(object, "TEMPORARY")
end

return M