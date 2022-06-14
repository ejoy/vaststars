local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local DEFAULT_DIR <const> = 'N'
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local irecipe = require "gameplay.interface.recipe"
local global = require "global"
local iobject = ecs.require "object"

--
local function new_entity(self, datamodel, typeobject)
    iobject.remove(self.pickup_object)

    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir)
    if not x or not y then
        return
    end

    local state
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        state = "invalid_construct"
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        state = "construct"
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    -- 主要处理某些组装机有默认配方的情况
    local fluid_name = ""
    if typeobject.recipe then
        local recipe_typeobject = iprototype.queryByName("recipe", typeobject.recipe)
        if recipe_typeobject then
            fluid_name = irecipe.get_init_fluids(recipe_typeobject) or "" -- 有配方 and 配方中没有流体
        else
            fluid_name = ""
        end
    end

    self.pickup_object = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        fluid_name = fluid_name,
        fluidflow_network_id = 0,
        state = state,
    }
end

local function touch_move(self, datamodel, delta_vec)
    iobject.move_delta(self.pickup_object, delta_vec)
end

local function touch_end(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    iobject.align(self.pickup_object)

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        pickup_object.state = "invalid_construct"
        return
    end

    if not ifluid:need_set_fluid(pickup_object.prototype_name) then
        pickup_object.state = "construct"
        datamodel.show_confirm = true
        datamodel.show_rotate = true
        return
    end

    local fluid_types = self:get_neighbor_fluid_types(EDITOR_CACHE_NAMES, pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)
    if #fluid_types <= 1 then
        pickup_object.fluid_name = fluid_types[1] or ""
        pickup_object.state = "construct"
        datamodel.show_confirm = true
        datamodel.show_rotate = true
        return
    else
        pickup_object.fluid_name = ""
        pickup_object.state = "invalid_construct"
    end
end

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        log.info("can not construct")
        return
    end

    local prototype_name = pickup_object.prototype_name
    local typeobject = iprototype.queryByName("entity", prototype_name)
    if iprototype.has_type(typeobject.type, "fluidbox") then
        if pickup_object.fluid_name == "" then
            global.fluidflow_network_id = global.fluidflow_network_id + 1
            pickup_object.fluidflow_network_id = global.fluidflow_network_id
        end
    end

    if iprototype.has_type(typeobject.type, "fluidbox") or iprototype.has_type(typeobject.type, "fluidboxes") then
        self:update_fluidbox(EDITOR_CACHE_NAMES, "CONFIRM", pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.fluid_name)
    end

    pickup_object.state = "confirm"
    objects:set(pickup_object, "CONFIRM")

    self.pickup_object = nil
    self:new_entity(datamodel, typeobject)

    datamodel.show_construct_complete = true
end

local function complete(self, datamodel)
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_construct_complete = false
    datamodel.show_rotate = false
    datamodel.show_confirm = false

    self.super.complete(self)
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    if not self.super:check_construct_detector(prototype_name, x, y, dir) then
        return false
    end

    if not ifluid:need_set_fluid(prototype_name) then
        return true
    end

    local fluid_types = self:get_neighbor_fluid_types(EDITOR_CACHE_NAMES, prototype_name, x, y, dir)
    if #fluid_types > 1 then
        return false
    end
    return true
end

local function rotate_pickup_object(self, datamodel)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    local dir = iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    local coord = terrain.adjust_position(camera.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end

    pickup_object.dir = dir
    pickup_object.x, pickup_object.y = coord[1], coord[2]
end

local function clean(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false
    datamodel.show_construct_complete = false
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
    M.rotate_pickup_object = rotate_pickup_object

    M.check_construct_detector = check_construct_detector
    M.clean = clean

    return M
end
return create