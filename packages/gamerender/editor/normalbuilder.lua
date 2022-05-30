local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local vsobject_manager = ecs.require "vsobject_manager"
local math3d = require "math3d"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local DEFAULT_DIR <const> = 'N'
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local irecipe = require "gameplay.interface.recipe"
local global = require "global"

--
local function new_entity(self, datamodel, typeobject)
    if self.pickup_object then
        vsobject_manager:remove(self.pickup_object.id)
    end

    local dir = DEFAULT_DIR
    local coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, dir))
    local x, y = coord[1], coord[2]

    local vsobject_type
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        vsobject_type = "invalid_construct"
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        vsobject_type = "construct"
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    -- 主要处理某些组装机有默认配方的情况
    local fluid_name
    if typeobject.recipe then
        local recipe_typeobject = iprototype:queryByName("recipe", typeobject.recipe)
        if recipe_typeobject then
            fluid_name = irecipe:get_init_fluids(recipe_typeobject)
        else
            fluid_name = ""
        end
    end

    local vsobject = vsobject_manager:create {
        prototype_name = typeobject.name,
        dir = dir,
        position = position,
        type = vsobject_type,
    }

    local object = {
        id = vsobject.id,
        gameplay_eid = 0,
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        teardown = false,
        headquater = typeobject.headquater or false, -- 用于 objects 查找[科技中心]
        fluid_name = fluid_name,
        fluidflow_network_id = 0,
        state = vsobject_type,
    }

    self.pickup_object = object
end

local function touch_move(self, datamodel, delta_vec)
    assert(self.pickup_object)

    local vsobject = assert(vsobject_manager:get(self.pickup_object.id))
    local typeobject = iprototype:queryByName("entity", self.pickup_object.prototype_name)
    local position = math3d.ref(math3d.add(vsobject:get_position(), delta_vec))

    local coord = terrain.adjust_position(math3d.tovalue(position), iprototype:rotate_area(typeobject.area, self.pickup_object.dir))
    if not coord then
        log.error(("can not get coord"))
        return
    end
    self.pickup_object.x, self.pickup_object.y = coord[1], coord[2]

    vsobject:set_position(position)
end

local function touch_end(self, datamodel)
    assert(self.pickup_object)
    local pickup_object = self.pickup_object

    local typeobject = iprototype:queryByName("entity", pickup_object.prototype_name)
    local coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, pickup_object.dir))
    if not coord then
        log.error(("can not get coord"))
        return
    end
    pickup_object.x, pickup_object.y = coord[1], coord[2]

    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    vsobject:set_position(position)

    local vsobject_type
    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        vsobject_type = "invalid_construct"
        vsobject:update {type = vsobject_type}
        return
    end

    if not ifluid:need_set_fluid(typeobject.name) then
        vsobject_type = "construct"
        vsobject:update {type = vsobject_type}
        datamodel.show_confirm = true
        datamodel.show_rotate = true
        return
    end

    local fluid_types = self:get_neighbor_fluid_types(EDITOR_CACHE_NAMES, typeobject.name, pickup_object.x, pickup_object.y, pickup_object.dir)
    if #fluid_types <= 1 then
        pickup_object.fluid_name = fluid_types[1] or ""
        vsobject_type = "construct"
        vsobject:update {type = vsobject_type}
        datamodel.show_confirm = true
        datamodel.show_rotate = true
        return
    else
        pickup_object.fluid_name = ""
        vsobject_type = "invalid_construct"
        vsobject:update {type = vsobject_type}
    end
end

local function confirm(self, datamodel)
    assert(self.pickup_object)
    local pickup_object = self.pickup_object

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        log.info("can not construct")
        return
    end

    local prototype_name = pickup_object.prototype_name
    local typeobject = iprototype:queryByName("entity", prototype_name)
    if iprototype:has_type(typeobject.type, "fluidbox") and pickup_object.fluid_name == "" then
        global.fluidflow_network_id = global.fluidflow_network_id + 1
        pickup_object.fluidflow_network_id = global.fluidflow_network_id
    end

    local vsobject = assert(vsobject_manager:get(self.pickup_object.id))
    self.pickup_object.state = "confirm"
    vsobject:update {type = "confirm"}

    objects:set(pickup_object, "CONFIRM")

    self.pickup_object = nil

    self:new_entity(datamodel, typeobject)

    datamodel.show_construct_complete = true
end

local function complete(self, datamodel)
    assert(self.pickup_object)

    vsobject_manager:remove(self.pickup_object.id)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY"})

    datamodel.show_rotate = false
    datamodel.show_confirm = false

    self.super.complete(self)

    datamodel.show_construct_complete = false
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
    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    local dir = iprototype:rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype:queryByName("entity", pickup_object.prototype_name)
    local coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, dir))
    if not position then
        return
    end

    pickup_object.x, pickup_object.y = coord[1], coord[2]
    pickup_object.dir = dir
    vsobject:set_position(position)
    vsobject:set_dir(pickup_object.dir)
    pickup_object.state = pickup_object.vsobject_type
    vsobject:update {type = pickup_object.vsobject_type}
end

local function clean(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false
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