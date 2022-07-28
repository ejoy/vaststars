local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local ieditor = ecs.require "editor.editor"
local ifluid = require "gameplay.interface.fluid"
local gameplay_core = require "gameplay.core"
local ientity = require "gameplay.interface.entity"
local imining = require "gameplay.interface.mining"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local global = require "global"

local function check_construct_detector(self, prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            if objects:coord(x + i, y + j, EDITOR_CACHE_NAMES) then
                return false
            end
        end
    end

    local found_mineral
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local mineral = terrain:get_mineral(x + i, y + j) -- TODO: maybe have multiple minerals in the area
            if mineral then
                found_mineral = mineral
            end
        end
    end

    if iprototype.has_type(typeobject.type, "mining") then
        if not found_mineral then
            return false
        end

        if not imining.get_mineral_recipe(prototype_name, found_mineral) then
            return false
        end
    else
        if found_mineral then -- can not construct in the area with mineral
            return false
        end
    end

    return true
end

local get_neighbor_fluid_types; do
    local function is_neighbor(x1, y1, dir1, x2, y2, dir2)
        local dx1, dy1 = ieditor:get_dir_coord(x1, y1, dir1)
        local dx2, dy2 = ieditor:get_dir_coord(x2, y2, dir2)
        return (dx1 == x2 and dy1 == y2) and (dx2 == x1 and dy2 == y1)
    end

    function get_neighbor_fluid_types(self, cache_names_r, prototype_name, x, y, dir)
        local fluid_names = {}

        for _, v in ipairs(ifluid:get_fluidbox(prototype_name, x, y, dir, "")) do
            local dx, dy = ieditor:get_dir_coord(v.x, v.y, v.dir)
            local object = objects:coord(dx, dy, cache_names_r)
            if object then
                for _, v1 in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
                    if is_neighbor(v.x, v.y, v.dir, v1.x, v1.y, v1.dir) then
                        fluid_names[v1.fluid_name] = true
                    end
                end
            end
        end

        local array = {}
        for fluid in pairs(fluid_names) do
            array[#array + 1] = fluid
        end
        return array
    end
end

local function clean(self, datamodel)
    if self.pickup_object then
        iobject.remove(self.pickup_object)
    end

    ieditor:revert_changes({"TEMPORARY"})
end

local function check_unconfirmed(self, double_confirm)
    if not objects:empty("CONFIRM") then
        if not double_confirm then
            return true
        end
    end
    return false
end

local function complete(self)
    local needbuild = false
    for object_id, object in objects:all("CONFIRM") do -- TODO: duplicate code, see also pipe_function_pop.lua
        if object.REMOVED then
            if object.gameplay_eid then
                gameplay_core.remove_entity(object.gameplay_eid)
            end
        else
            object.state = "constructed"

            -- TODO: special case for assembling machine
            local recipe
            local typeobject = iprototype.queryByName("entity", object.prototype_name)
            if iprototype.has_type(typeobject.type, "assembling") then
                recipe = ""
            end

            local old = objects:get(object_id, {"CONSTRUCTED"})
            if not old then
                object.gameplay_eid = gameplay_core.create_entity(object)
                object.recipe = recipe
            else
                if old.prototype_name ~= object.prototype_name then
                    gameplay_core.remove_entity(object.gameplay_eid)
                    object.gameplay_eid = gameplay_core.create_entity(object)
                elseif old.dir ~= object.dir then
                    ientity:set_direction(gameplay_core.get_world(), gameplay_core.get_entity(object.gameplay_eid), object.dir)
                elseif old.fluid_name ~= object.fluid_name then
                    if iprototype.has_type(iprototype.queryByName("entity", object.prototype_name).type, "fluidbox") then -- TODO: object may be fluidboxes
                        ifluid:update_fluidbox(gameplay_core.get_entity(object.gameplay_eid), object.fluid_name)
                    end
                end
            end
        end
        needbuild = true
    end
    objects:commit("CONFIRM", "CONSTRUCTED")
    objects:cleanup("CONFIRM")
    objects:cleanup("CONSTRUCTED")

    if needbuild then
        gameplay_core.build()
    end
end

-- TODO recipe_pop.lua
local function is_connection(x1, y1, dir1, x2, y2, dir2)
    local dx1, dy1 = ieditor:get_dir_coord(x1, y1, dir1)
    local dx2, dy2 = ieditor:get_dir_coord(x2, y2, dir2)
    return (dx1 == x2 and dy1 == y2) and (dx2 == x1 and dy2 == y1)
end

local function update_fluidbox(self, cache_names_r, cache_name_w, prototype_name, x, y, dir, fluid_name)
    for _, v in ipairs(ifluid:get_fluidbox(prototype_name, x, y, dir, fluid_name)) do
        local succ, dx, dy = terrain:move_coord(v.x, v.y, v.dir, 1)
        if not succ then
            goto continue
        end

        local object = objects:coord(dx, dy, cache_names_r)
        if not object then
            goto continue
        end

        local typeobject = iprototype.queryByName("entity", object.prototype_name)
        if not iprototype.has_type(typeobject.type, "fluidbox") then
            goto continue
        end

        for _, v1 in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
            if is_connection(v.x, v.y, v.dir, v1.x, v1.y, v1.dir) then
                if object.fluidflow_id ~= 0 then
                    for _, object in objects:selectall("fluidflow_id", object.fluidflow_id, cache_names_r) do
                        local o = iobject.clone(object)
                        global.fluidflow_id = global.fluidflow_id + 1
                        o.fluidflow_id = global.fluidflow_id
                        o.fluid_name = v.fluid_name
                        objects:set(o, cache_name_w)
                    end
                else
                    if object.fluid_name ~= v.fluid_name then
                        local prototype_name, dir = ieditor:refresh_pipe(object.prototype_name, object.dir, v1.dir, false)
                        if prototype_name then
                            object.prototype_name, object.dir = prototype_name, dir
                        end
                    end
                end
            end
        end
        ::continue::
    end
end

local function create()
    local M = {}
    -- M.pickup_object
    M.check_construct_detector = check_construct_detector
    M.revert_changes = ieditor.revert_changes
    M.get_neighbor_fluid_types = get_neighbor_fluid_types
    M.clean = clean
    M.check_unconfirmed = check_unconfirmed
    M.complete = complete
    M.update_fluidbox = update_fluidbox

    return M
end
return create
