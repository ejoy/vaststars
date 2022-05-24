local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local global = require "global"
local ALL_CACHE <const> = global.cache_names
local objects = global.objects
local tile_objects = global.tile_objects
local vsobject_manager = ecs.require "vsobject_manager"
local get_fluidboxes = require "gameplay.utility.get_fluidboxes"
local ieditor = ecs.require "editor.editor"

local get_dir_coord; do
    local dir_coord = {
        ['N'] = {x = 0,  y = -1},
        ['E'] = {x = 1,  y = 0},
        ['S'] = {x = 0,  y = 1},
        ['W'] = {x = -1, y = 0},
    }
    function get_dir_coord(x, y, dir)
        local c = assert(dir_coord[dir])
        return x + c.x, y + c.y
    end
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    local typeobject = iprototype:queryByName("entity", prototype_name)
    local construct_detector = typeobject.construct_detector
    if not construct_detector then
        return true
    end

    local w, h = iprototype:rotate_area(typeobject.area, dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local tile_object = tile_objects:get(ALL_CACHE, iprototype:packcoord(x + i, y + j))
            if tile_object then
                return false
            end
        end
    end

    return true
end

local function get_neighbor_fluid_types(self, cache_names, prototype_name, x, y, dir)
    local fluid_types = {}
    for _, v in ipairs(get_fluidboxes(prototype_name, x, y, dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local dx, dy = get_dir_coord(v.x, v.y, dir)
            local tile_object = tile_objects:get(cache_names, iprototype:packcoord(dx, dy))
            if tile_object and tile_object.fluidbox_dir then
                if tile_object.fluidbox_dir[iprototype:opposite_dir(dir)] then
                    local object = assert(objects:get(cache_names, tile_object.id))
                    local fluid = object.fluid_name
                    if fluid ~= "" then
                        fluid_types[fluid] = true
                    end
                end
            end
        end
    end

    local array = {}
    for fluid in pairs(fluid_types) do
        array[#array + 1] = fluid
    end
    return array
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

local function create()
    local M = {}
    -- M.pickup_object
    M.check_construct_detector = check_construct_detector
    M.revert_changes = ieditor.revert_changes
    M.set_object = ieditor.set_object
    M.get_neighbor_fluid_types = get_neighbor_fluid_types
    M.clean = clean
    M.check_unconfirmed = check_unconfirmed
    M.ALL_CACHE = ALL_CACHE

    return M
end
return create
