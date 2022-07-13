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
local imining = require "gameplay.interface.mining"
local construct_inventory = global.construct_inventory
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"
local gameplay_core = require "gameplay.core"
local _VASTSTARS_DEBUG_INFINITE_ITEM <const> = world.args.ecs.VASTSTARS_DEBUG_INFINITE_ITEM

--
local function __new_entity(self, datamodel, typeobject)
    iobject.remove(self.pickup_object)

    if not _VASTSTARS_DEBUG_INFINITE_ITEM then
        -- check if item is in the inventory
        local item_typeobject = iprototype.queryByName("item", typeobject.name)
        local item = construct_inventory:get({"TEMPORARY", "CONFIRM"}, item_typeobject.id)
        if not item or item.count <= 0 then
            log.error("Lack of item: " .. typeobject.name)
            return
        end
    end

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

    -- some assembling machine have default recipe
    local fluid_name = ""
    if typeobject.recipe then
        local recipe_typeobject = iprototype.queryByName("recipe", typeobject.recipe)
        if recipe_typeobject then
            fluid_name = irecipe.get_init_fluids(recipe_typeobject) or "" -- maybe no fluid in recipe
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
        state = state,
    }
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    -- self.pickup_object.__object.APPEAR = true
end

local function touch_move(self, datamodel, delta_vec)
    if self.pickup_object then
        iobject.move_delta(self.pickup_object, delta_vec)
    end
end

-- TODO: duplicate from builder.lua
local function _get_mineral_recipe(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    if not iprototype.has_type(typeobject.type, "mining") then
        return
    end
    local found
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local mineral = terrain:get_mineral(x + i, y + j) -- TODO: maybe have multiple minerals in the area
            if mineral then
                found = mineral
            end
        end
    end

    if not found then
        return
    end

    return imining.get_mineral_recipe(prototype_name, found)
end

local function touch_end(self, datamodel)
    local pickup_object = self.pickup_object
    if not pickup_object then
        return
    end

    iobject.align(self.pickup_object)

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        pickup_object.state = "invalid_construct"
        return
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) -- TODO: maybe set recipt according to entity type?

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

    -- TODO: change fluid of object
    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    if iprototype.has_type(typeobject.type, "fluidbox") then
        for _, v in ipairs(ifluid:get_fluidbox(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.fluid_name)) do

        end
    end

    if iprototype.has_type(typeobject.type, "fluidbox") then
        global.fluidflow_id = global.fluidflow_id + 1
        pickup_object.fluidflow_id = global.fluidflow_id
    end

    if iprototype.has_type(typeobject.type, "fluidboxes") then
        self:update_fluidbox(EDITOR_CACHE_NAMES, "CONFIRM", pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.fluid_name)
    end

    pickup_object.state = "confirm"
    objects:set(pickup_object, "CONFIRM")
    pickup_object.PREPARE = true

    local function _clone_item(item)
        local new = {}
        new.prototype = item.prototype
        new.count = item.count
        return new
    end

    if not _VASTSTARS_DEBUG_INFINITE_ITEM then
        -- decrease item count
        local item_typeobject = iprototype.queryByName("item", typeobject.name)
        local item = construct_inventory:modify({"TEMPORARY", "CONFIRM"}, item_typeobject.id, _clone_item) -- TODO: define cache name as constant
        assert(item.count >= 0) -- promised by new_entity
        item.count = item.count - 1
        iui.update("construct.rml", "update_construct_inventory")
    end

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    datamodel.show_construct_complete = true

    self.pickup_object = nil
    __new_entity(self, datamodel, typeobject)
end

local function complete(self, datamodel)
    local gameplay_world = gameplay_core.get_world()
    local e = iworld:get_headquater_entity(gameplay_world)
    if not e then
        log.error("can not find headquater entity")
        return
    end

    local failed = false
    for _, item in construct_inventory:all("TEMPORARY") do
        local old_item = assert(construct_inventory:get({"CONFIRM"}, item.prototype))
        assert(old_item.count >= item.count)
        local decrease = old_item.count - item.count
        print(iprototype.queryById(item.prototype).name, decrease)
        if not gameplay_world:container_pickup(e.chest.container, item.prototype, decrease) then
            log.error("can not pickup item", iprototype.queryById(item.prototype).name, decrease)
            failed = true
        end
    end
    if failed then
        return
    end

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
    local coord = terrain:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, dir) then
        pickup_object.state = "invalid_construct"
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        pickup_object.state = "construct"
        datamodel.show_confirm = true
        datamodel.show_rotate = true
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