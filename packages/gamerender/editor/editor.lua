local ecs = ...
local world = ecs.world

local objects = require "objects"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local flow_shape = require "gameplay.utility.flow_shape"
local ifluid = require "gameplay.interface.fluid"
local iassembling = require "gameplay.interface.assembling"
local ichest = require "gameplay.interface.chest"
local iworld = require "gameplay.interface.world"
local iobject = ecs.require "object"

--
local M = {}

-- TODO
function M:revert_changes(revert_cache_names)
    local t = {}
    for _, cache_name in ipairs(revert_cache_names) do
        for id, object in objects:all(cache_name) do
            t[id] = object
        end
    end
    objects:clear(revert_cache_names)

    for id, object in pairs(t) do
        local old_object = objects:get(id, EDITOR_CACHE_NAMES)
        if old_object then
            object.prototype_name = old_object.prototype_name
            object.dir = old_object.dir
            object.state = old_object.state
            object.fluid_name = old_object.fluid_name
            object.fluidflow_network_id = old_object.fluidflow_network_id
        else
            iobject.remove(object)
        end
    end
end

function M:teardown_begin()
    self:revert_changes({"TEMPORARY", "CONFIRM"})
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

    local state = flow_shape:to_state(prototype_name:gsub(".*%-(%u).*", "%1"), dir)
    state = flow_shape:set_state(state, iprototype.dir_tonumber(entry_dir), value or 1)
    local ntype, dir = flow_shape:to_type_dir(state)
    return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(ntype)), dir
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
    local object = assert(objects:coord(dx, dy, cache_names_r))
    if object then
        local typeobject = iprototype.queryByName("entity", object.prototype_name)
        if typeobject.pipe or typeobject.road then
            local prototype_name, dir = refresh_pipe(object.prototype_name, object.dir, iprototype.opposite_dir(entry_dir))
            if prototype_name then
                object = iobject.clone(object)
                object.prototype_name = prototype_name
                object.dir = dir
                objects:set(object, cache_name_w)
            end
        end
    end
end

local function shift_pipe(self, object, prototype_name, dir)
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    if not typeobject.pipe then
        return
    end

    object = iobject.clone(object)
    object.prototype_name = prototype_name
    object.dir = dir
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
            local typeobject = iprototype.queryByName("entity", nobject.prototype_name)
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
    for _, object in objects:select("TEMPORARY", "teardown", true) do
        teardown(self, object, changed_set)
        removed_set[object.id] = object
    end

    local item_counts = {}
    for id, object in pairs(removed_set) do
        iobject.remove(object)
        objects:remove(object.id)

        -- TODO
        local e = gameplay_core.get_entity(object.gameplay_eid)
        if e.assembling then
            for prototype_name, count in pairs(iassembling:item_counts(gameplay_core.get_world(), e)) do
                local typeobject_item = iprototype.queryByName("item", prototype_name)
                if typeobject_item then
                    item_counts[typeobject_item.id] = item_counts[typeobject_item.id] or 0
                    item_counts[typeobject_item.id] = item_counts[typeobject_item.id] + count
                end
            end
        end
        if e.chest then
            for prototype, count in pairs(ichest:item_counts(gameplay_core.get_world(), e)) do
                item_counts[prototype] = item_counts[prototype] or 0
                item_counts[prototype] = item_counts[prototype] + count
            end
        end
        local typeobject_item = iprototype.queryByName("item", object.prototype_name)
        if typeobject_item then
            item_counts[typeobject_item.id] = item_counts[typeobject_item.id] or 0
            item_counts[typeobject_item.id] = item_counts[typeobject_item.id] + 1
        end

        gameplay_core.remove_entity(object.gameplay_eid)
        changed_set[id] = nil
    end

    local headquater_e = iworld:get_headquater_entity(gameplay_core.get_world())
    if headquater_e then
        for prototype, count in pairs(item_counts) do
            if not gameplay_core.get_world():container_place(headquater_e.chest.container, prototype, count) then
                log.error(("failed to place `%s` `%s`"):format(prototype, count))
            end
        end
    else
        log.error("no headquater")
    end

    for _, object in pairs(changed_set) do
        shift_pipe(self, object, object.prototype_name, object.dir)
    end

    gameplay_core.build()

    objects:clear({"TEMPORARY"})
end

function M:teardown(id)
    local object = iobject.clone(assert(objects:get(id, EDITOR_CACHE_NAMES)))
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    if typeobject.teardown == false then
        log.info(("`%s` cannot be demolished"):format(object.prototype_name))
        return
    end

    object.teardown = not object.teardown
    if object.teardown then
        object.state = "teardown"
    else
        object.state = "constructed"
    end
    objects:set(object, "TEMPORARY")
end

return M