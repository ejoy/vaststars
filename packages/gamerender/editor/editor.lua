local ecs = ...
local world = ecs.world

local global = require "global"
local ALL_CACHE <const> = global.cache_names
local objects = global.objects
local tile_objects = global.tile_objects
local vsobject_manager = ecs.require "vsobject_manager"
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local get_fluidboxes = require "gameplay.utility.get_fluidboxes"
local get_roadboxes = require "gameplay.utility.get_roadboxes"
local flow_shape = require "gameplay.utility.flow_shape"

--
local M = {}

function M:clone_object(object)
    return {
        id = object.id,
        gameplay_eid = object.gameplay_eid,
        prototype_name = object.prototype_name,
        dir = object.dir,
        x = object.x,
        y = object.y,
        teardown = object.teardown,
        headquater = object.headquater,
        fluid_name = object.fluid_name,
        pipe_network_id = object.pipe_network_id,
    }
end

function M:revert_changes(revert_cache_names)
    local t = {}
    for _, cache_name in ipairs(revert_cache_names) do
        for id, object in objects:all(cache_name) do
            t[id] = object
        end
        objects:revert({cache_name})
        tile_objects:revert({cache_name})
    end

    for id, object in pairs(t) do
        local old_object = objects:get(ALL_CACHE, id)
        if old_object then
            local vsobject = assert(vsobject_manager:get(object.id))
            vsobject:update {prototype_name = old_object.prototype_name, type = old_object.vsobject_type}
            vsobject:set_dir(old_object.dir)
        else
            local vsobject = assert(vsobject_manager:get(object.id))
            vsobject:remove()
        end
    end
end

function M:set_object(object, cache_name)
    local t = {}

    --
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    local w, h = iprototype:rotate_area(typeobject.area, object.dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local coord = iprototype:packcoord(object.x + i, object.y + j)
            t[coord] = {id = object.id, coord = coord}
        end
    end

    --
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        assert(t[iprototype:packcoord(v.x, v.y)])
        t[iprototype:packcoord(v.x, v.y)].fluidbox_dir = v.fluidbox_dir
    end

    --
    for _, v in ipairs(get_roadboxes(object.prototype_name, object.x, object.y, object.dir)) do
        assert(t[iprototype:packcoord(v.x, v.y)])
        t[iprototype:packcoord(v.x, v.y)].road_dir = v.road_dir
    end

    --
    for _, tile_object in pairs(t) do
        tile_objects:set(cache_name, tile_object)
    end

    objects:set(cache_name, object)
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

local function refresh_pipe(prototype_name, dir, entry_dir)
    local typeobject = iprototype:queryByName("entity", prototype_name)
    if not typeobject.pipe then
        return
    end

    local state = flow_shape:to_state(prototype_name:gsub(".*%-(%u).*", "%1"), dir)
    state = flow_shape:set_state(state, iprototype:dir_tonumber(entry_dir), 1)
    local ntype, dir = flow_shape:to_type_dir(state)
    return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(ntype)), dir
end

function M:refresh_flow_shape(get_cache_names, set_cache_name, object, entry_dir)
    local vsobject = assert(vsobject_manager:get(object.id))
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    if not typeobject.pipe then -- todo
        return
    end

    local prototype_name, dir = refresh_pipe(object.prototype_name, object.dir, entry_dir)
    if prototype_name then
        object = self:clone_object(object)
        object.prototype_name = prototype_name
        object.dir = dir

        vsobject:update {prototype_name = prototype_name}
        vsobject:set_dir(dir)

        self:set_object(object, set_cache_name)
    end

    local dx, dy = self:get_dir_coord(object.x, object.y, entry_dir)
    local tile_object = tile_objects:get(get_cache_names, iprototype:packcoord(dx, dy))
    if tile_object then
        local object = assert(objects:get(get_cache_names, tile_object.id))
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

                self:set_object(object, set_cache_name)
            end
        end
    end
end

function M:teardown_complete()
    local removelist = {}
    for id, object in objects:select("TEMPORARY", "teardown", true) do
        local vsobject = assert(vsobject_manager:get(id))
        vsobject:remove()

        objects:remove("CONSTRUCTED", id)
        for coord in tile_objects:select("CONSTRUCTED", "id", id) do
            tile_objects:remove("CONSTRUCTED", coord)
        end

        removelist[iprototype:packcoord(object.x, object.y)] = object
    end

    for _, object in pairs(removelist) do
        -- TODO
    end

    local needbuild = false
    for e in gameplay_core.select("entity:in") do
        local coord = iprototype:packcoord(e.entity.x, e.entity.y)
        if removelist[coord] then
            gameplay_core.remove_entity(e)
            needbuild = true
        end
    end
    if needbuild then
        gameplay_core.build()
    end

    objects:clear("TEMPORARY")
end

function M:teardown(id)
    local object = self:clone_object(assert(objects:get(ALL_CACHE, id)))
    local vsobject = assert(vsobject_manager:get(id))

    object.teardown = not object.teardown

    if object.teardown then
        object.vsobject_type = "teardown"
        vsobject:update {type = "teardown"}
    else
        object.vsobject_type = "constructed"
        vsobject:update {type = "constructed"}
    end
    objects:set("TEMPORARY", object)
end

return M