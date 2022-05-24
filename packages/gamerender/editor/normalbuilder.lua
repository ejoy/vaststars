local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local vsobject_manager = ecs.require "vsobject_manager"
local global = require "global"
local math3d = require "math3d"
local gameplay_core = require "gameplay.core"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"

local objects = global.objects
local tile_objects = global.tile_objects

local DEFAULT_DIR <const> = 'N'

local function show_set_fluidbox(datamodel, fluid_name)
    datamodel.cur_selected_fluid = fluid_name
    datamodel.cur_fluid_category = ifluid:get_fluid_category(fluid_name)
    datamodel.show_set_fluidbox = true
end

local function hide_set_fluidbox(datamodel)
    datamodel.cur_selected_fluid = ""
    datamodel.cur_fluid_category = ""
    datamodel.show_set_fluidbox = false
end

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
    else
        vsobject_type = "construct"
    end

    local vsobject = vsobject_manager:create {
        prototype_name = typeobject.name,
        dir = dir,
        position = position,
        type = vsobject_type,
    }

    local object = {
        id = vsobject.id,
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        teardown = false,
        headquater = typeobject.headquater or false, -- 用于 objects 查找[科技中心]
        manual_set_fluid = false, -- 没有手动设置液体的情况下, 会自动将液体设置为附近流体系统的液体
        -- fluid_name,
    }

    if not ifluid:need_set_fluid(typeobject.name) then
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    else
        local fluid_types = self:get_neighbor_fluid_types(self.ALL_CACHE, typeobject.name, x, y, dir)
        if #fluid_types == 1 then
            object.fluid_name = fluid_types[1]
            show_set_fluidbox(datamodel, object.fluid_name)
        end
    end

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
    else
        vsobject_type = "construct"
    end

    if not ifluid:need_set_fluid(typeobject.name) then
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    else
        local fluid_types = self:get_neighbor_fluid_types(self.ALL_CACHE, typeobject.name, pickup_object.x, pickup_object.y, pickup_object.dir)
        if not pickup_object.manual_set_fluid then
            if #fluid_types == 1 then
                pickup_object.fluid_name = fluid_types[1]
            else
                pickup_object.fluid_name = ""
            end
            show_set_fluidbox(datamodel, pickup_object.fluid_name)
        else
            if #fluid_types == 1 and pickup_object.fluid_name ~= fluid_types[1] then
                vsobject_type = "invalid_construct"
            end
        end
    end

    vsobject:update {type = vsobject_type}
end

local function confirm(self, datamodel)
    assert(self.pickup_object)
    local pickup_object = self.pickup_object

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        log.info("can not construct")
        return
    end

    if ifluid:need_set_fluid(pickup_object.prototype_name) and pickup_object.fluid_name == "" then
        log.info("can not construct")
        return
    end

    hide_set_fluidbox(datamodel)

    local vsobject = assert(vsobject_manager:get(self.pickup_object.id))
    vsobject:update {type = "confirm"}

    ieditor:set_object(self.pickup_object, "CONFIRM")

    local prototype_name = self.pickup_object.prototype_name
    self.pickup_object = nil

    local typeobject = iprototype:queryByName("entity", prototype_name)
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
    datamodel.show_set_fluidbox = false

    local needbuild = false
    for _, object in objects:all("CONFIRM") do
        object.vsobject_type = "constructed"

        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {type = "constructed"}

        object.gameplay_eid = gameplay_core.create_entity(object)
        needbuild = true
    end
    objects:commit("CONFIRM", "CONSTRUCTED")
    tile_objects:commit("CONFIRM", "CONSTRUCTED")

    if needbuild then
        gameplay_core.build()
    end

    datamodel.show_construct_complete = false
end

local function set_fluid(self, datamodel, fluid_name)
    assert(self.pickup_object)
    local pickup_object = self.pickup_object
    pickup_object.fluid_name = fluid_name
    pickup_object.manual_set_fluid = true

    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    local fluid_types = self:get_neighbor_fluid_types(self.ALL_CACHE, pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)

    local vsobject_type
    if #fluid_types > 1 then
        vsobject_type = "invalid_construct"
    else
        if pickup_object.fluid_name ~= "" and #fluid_types == 1 and fluid_types[1] ~= pickup_object.fluid_name then
            vsobject_type = "invalid_construct"
        else
            vsobject_type = "construct"
        end
    end

    vsobject:update {type = vsobject_type}

    if vsobject_type ~= "invalid_construct" then
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    if not self.super:check_construct_detector(prototype_name, x, y, dir) then
        return false
    end

    if not ifluid:need_set_fluid(prototype_name) then
        return true
    end

    local fluid_types = self:get_neighbor_fluid_types(self.ALL_CACHE, prototype_name, x, y, dir)
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
    M.set_fluid = set_fluid
    M.rotate_pickup_object = rotate_pickup_object

    M.check_construct_detector = check_construct_detector
    M.clean = clean

    return M
end
return create