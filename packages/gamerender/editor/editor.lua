local ecs = ...
local world = ecs.world

local objects = require "objects"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local ifluid = require "gameplay.interface.fluid"
local iassembling = require "gameplay.interface.assembling"
local ichest = require "gameplay.interface.chest"
local iworld = require "gameplay.interface.world"
local iobject = ecs.require "object"
local iflow_connector = require "gameplay.interface.flow_connector"
local terrain = ecs.require "terrain"
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local iguide = require "gameplay.interface.guide"

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
            object.__object.OBJECT_REMOVED = nil
        else
            iobject.remove(object)
        end
    end
    iobject.flush() -- object is removed from cache, so we need to flush it, else it will keep the old state
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

local function shift_pipe(object, prototype_name, dir)
    -- TODO: prototype_name or direction of entity may changed when it's neighbor has removed, need to rebuild the entity in gameplay
    if not ( iprototype.is_road(object.prototype_name) or iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) )  then
        return
    end

    object = iobject.clone(object)
    object.prototype_name = prototype_name
    object.dir = dir
    objects:set(object)

    igameplay.remove_entity(object.gameplay_eid)
    object.gameplay_eid = igameplay.create_entity(object)
end

local function is_connection(self, x1, y1, dir1, x2, y2, dir2)
    local dx1, dy1 = self:get_dir_coord(x1, y1, dir1)
    local dx2, dy2 = self:get_dir_coord(x2, y2, dir2)
    return (dx1 == x2 and dy1 == y2) and (dx2 == x1 and dy2 == y1)
end

-- TODO: duplicate code with roadbuilding.lua
local function _get_road_connections(prototype_name, x, y, dir)
    local typeobject = assert(iprototype.queryByName("entity", prototype_name))
    local result = {}
    if not typeobject.crossing then
        return result
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local dx, dy, dir = iprototype.rotate_fluidbox(conn.position, dir, typeobject.area)
        result[#result+1] = {x = x + dx, y = y + dy, dir = dir, ground = conn.ground}
    end
    return result
end

local function teardown(self, object, changed_set)
    for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
        local succ, dx, dy = terrain:move_coord(v.x, v.y, v.dir, 1)
        if not succ then
            goto continue
        end

        local neighbor = objects:coord(dx, dy)
        if not neighbor then
            goto continue
        end

        if not iprototype.is_pipe(neighbor.prototype_name) and not iprototype.is_pipe_to_ground(neighbor.prototype_name) then
            goto continue
        end

        for _, v1 in ipairs(ifluid:get_fluidbox(neighbor.prototype_name, neighbor.x, neighbor.y, neighbor.dir)) do
            if is_connection(self, v.x, v.y, v.dir, v1.x, v1.y, v1.dir) then
                local prototype_name, dir = iflow_connector.set_connection(neighbor.prototype_name, neighbor.dir, v1.dir, false)
                if prototype_name ~= neighbor.prototype_name or dir ~= neighbor.dir then
                    neighbor.prototype_name = prototype_name
                    neighbor.dir = dir
                    changed_set[neighbor.id] = neighbor
                end
            end
        end
        ::continue::
    end

    for _, conn in ipairs(_get_road_connections(object.prototype_name, object.x, object.y, object.dir)) do
        local succ, dx, dy = terrain:move_coord(conn.x, conn.y, conn.dir, 1)
        if not succ then
            goto continue
        end

        local neighbor = objects:coord(dx, dy)
        if not neighbor then
            goto continue
        end

        if not iprototype.is_road(neighbor.prototype_name) then
            goto continue
        end

        for _, _conn in ipairs(_get_road_connections(neighbor.prototype_name, neighbor.x, neighbor.y, neighbor.dir)) do
            if is_connection(self, conn.x, conn.y, conn.dir, _conn.x, _conn.y, _conn.dir) then
                local prototype_name, dir = iflow_connector.set_connection(neighbor.prototype_name, neighbor.dir, _conn.dir, false)
                if prototype_name ~= neighbor.prototype_name or dir ~= neighbor.dir then
                    neighbor.prototype_name = prototype_name
                    neighbor.dir = dir
                    changed_set[neighbor.id] = neighbor
                end
            end
        end

        ::continue::
    end
end

function M:teardown_complete()
    local changed_set = {}
    local removed_set = {}
    for _, object in objects:select("TEMPORARY", "teardown", true) do
        world:pub {"teardown", object.prototype_name}
        teardown(self, object, changed_set)
        removed_set[object.id] = object
    end

    local power_network_dirty = false
    local item_counts = {}
    for id, object in pairs(removed_set) do
        iobject.remove(object)
        objects:remove(object.id)

        local e = gameplay_core.get_entity(object.gameplay_eid)
        if e.assembling then
            for prototype_name, count in pairs(iassembling.item_counts(gameplay_core.get_world(), e)) do
                local typeobject_item = iprototype.queryByName("item", prototype_name)
                if typeobject_item then
                    item_counts[typeobject_item.id] = item_counts[typeobject_item.id] or 0
                    item_counts[typeobject_item.id] = item_counts[typeobject_item.id] + count
                end
            end
        end
        if e.chest and e.chest.chest_in == e.chest.chest_out and e.chest.chest_in ~= 0xffff then
            for prototype, count in pairs(ichest:item_counts(gameplay_core.get_world(), e)) do
                item_counts[prototype] = item_counts[prototype] or 0
                item_counts[prototype] = item_counts[prototype] + count
            end
        end

        local prototype_name = object.prototype_name
        -- object.prototype_name may be not a item, such as "pipe"/"road"
        if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) or iprototype.is_road(object.prototype_name) then
            prototype_name = iflow_connector.covers(object.prototype_name, object.dir)
        end
        local typeobject_item = iprototype.queryByName("item", prototype_name)
        if typeobject_item then
            item_counts[typeobject_item.id] = (item_counts[typeobject_item.id] or 0) + 1
        end
        local typeobject = iprototype.queryByName("entity", prototype_name)
        if not power_network_dirty then
            if typeobject.power_pole then
                power_network_dirty = true
            else
                local aw, ah = iprototype.unpackarea(typeobject.area)
                local net = ipower:get_network_id({x = object.x, y = object.y, w = aw, h = ah })
                if #net > 1 then
                    power_network_dirty = true
                end
            end
        end

        igameplay.remove_entity(object.gameplay_eid)
        changed_set[id] = nil
    end

    -- TODO: inventory full check -> revert teardown
    for prototype, count in pairs(item_counts) do
        local r = iworld.base_chest_place(gameplay_core.get_world(), prototype, count)
        if r ~= 0 then
            log.error(("failed to place `%s` `%s` `%s`"):format(prototype, count, r))
        end
    end

    for _, object in pairs(changed_set) do
        shift_pipe(object, object.prototype_name, object.dir)
    end

    gameplay_core.build()

    objects:clear({"TEMPORARY"})

    if power_network_dirty then
        -- update power network
        ipower:build_power_network(gameplay_core.get_world())
        ipower_line.update_line(ipower:get_pole_lines())
    else

    end
end

function M:teardown(id)
    local object = iobject.clone(assert(objects:get(id, EDITOR_CACHE_NAMES)))
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    if typeobject.teardown == false then
        log.info(("`%s` cannot be demolished"):format(object.prototype_name))
        return
    end

    if typeobject.teardown ~= nil then
        assert(type(typeobject.teardown) == "number")
        if typeobject.teardown > iguide.get_progress() then
            log.info(("`%s` - `%s` cannot be torn down before the progress of `%s`"):format(object.prototype_name, iguide.get_progress(), typeobject.teardown))
            return
        end
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