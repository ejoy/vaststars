local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local create_builder = ecs.require "editor.builder"
local iobject = ecs.require "object"
local objects = require "objects"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local ifluid = require "gameplay.interface.fluid"
local ieditor = ecs.require "editor.editor"
local flow_shape = require "gameplay.utility.flow_shape"

local function is_valid_starting(x, y)
    local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    if not object then
        return true
    end

    local t = ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)
    return #t > 0
end

local function is_valid_ending(x, y)
    return true
end

local function show_indicator(object, coord_indicator)
    ieditor:revert_changes({"INDICATOR"})

    local typeobject = iprototype:queryByName("entity", coord_indicator.prototype_name)
    for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
        local dx, dy = ieditor:get_dir_coord(v.x, v.y, v.dir)
        if is_valid_ending(dx, dy) then
            local indicator_object = iobject.new(typeobject, dx, dy, v.dir, "indicator")
            objects:set(indicator_object, "INDICATOR")
        end
    end
end

--
local function new_entity(self, datamodel, typeobject)
    if self.coord_indicator then
        iobject.remove(self.coord_indicator)
    end
    self.coord_indicator = iobject.new(typeobject)

    local coord_indicator = self.coord_indicator
    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_batch_mode_begin = true
        iobject.state_update(coord_indicator, "construct")

        local object = objects:coord(coord_indicator.x, coord_indicator.y, EDITOR_CACHE_NAMES)
        if object then
            show_indicator(object, self.coord_indicator)
        end
    else
        datamodel.show_batch_mode_begin = false
        iobject.state_update(coord_indicator, "invalid_construct")
    end
end

local function touch_move(self, datamodel, delta_vec)
    iobject.move(self.coord_indicator, delta_vec)
end

local function touch_end(self, datamodel)
    iobject.adjust(self.coord_indicator)
end

local function confirm(self, datamodel)

end

local function complete(self, datamodel)

end

local function batch_mode_begin(self, datamodel)

end

local function clean(self, datamodel)
    self:revert_changes({"INDICATOR", "TEMPORARY"})
    datamodel.show_construct_complete = false
    datamodel.show_rotate = false
    datamodel.show_confirm = false
    datamodel.show_batch_mode_begin = false
    self.super.clean(self, datamodel)
end

local function create()
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm
    M.complete = complete

    M.clean = clean
    M.batch_mode_begin = batch_mode_begin

    -- M.starting_object
    return M
end
return create