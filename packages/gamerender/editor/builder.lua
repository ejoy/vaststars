local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local vsobject_manager = ecs.require "vsobject_manager"
local ieditor = ecs.require "editor.editor"
local ifluid = require "gameplay.interface.fluid"
local gameplay_core = require "gameplay.core"

local function check_construct_detector(self, prototype_name, x, y, dir)
    local typeobject = iprototype:queryByName("entity", prototype_name)
    local construct_detector = typeobject.construct_detector
    if not construct_detector then
        return true
    end

    local w, h = iprototype:rotate_area(typeobject.area, dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            if objects:coord(x + i, y + j, EDITOR_CACHE_NAMES) then
                return false
            end
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
        vsobject_manager:remove(self.pickup_object.id)
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
    for _, object in objects:all("CONFIRM") do
        object.state = "constructed"

        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {type = "constructed"}

        if object.gameplay_eid == 0 then
            object.gameplay_eid = gameplay_core.create_entity(object)
        else
            local typeobject = iprototype:queryByName("entity", object.prototype_name)
            if iprototype:has_type(typeobject.type, "fluidbox") then
                ifluid:update_fluidbox(gameplay_core.get_entity(object.gameplay_eid), object.fluid_name)
            end
        end
        needbuild = true
    end
    objects:commit("CONFIRM", "CONSTRUCTED")

    if needbuild then
        gameplay_core.build()
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

    return M
end
return create
