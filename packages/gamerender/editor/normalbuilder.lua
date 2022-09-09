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
local ipower = ecs.require "power"
local imining = require "gameplay.interface.mining"
local inventory = global.inventory
local iui = ecs.import.interface "vaststars.gamerender|iui"
local gameplay_core = require "gameplay.core"

local function _get_state(prototype_name, ok)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    if typeobject.supply_area then
        if ok then
            return ("power_pole_construct_%s"):format(typeobject.supply_area)
        else
            return ("power_pole_invalid_construct_%s"):format(typeobject.supply_area)
        end
    else
        if ok then
            return "construct"
        else
            return "invalid_construct"
        end
    end
end

local function __new_entity(self, datamodel, typeobject)
    -- check if item is in the inventory
    local item_typeobject = iprototype.queryByName("item", typeobject.name)
    local item = inventory:get(item_typeobject.id)
    if item.count <= 0 then
        log.error("Lack of item: " .. typeobject.name) -- TODO: show error message?
        return
    end

    iobject.remove(self.pickup_object)
    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir)
    if not x or not y then
        return
    end

    local state
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        state = _get_state(typeobject.name, false)
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        state = _get_state(typeobject.name, true)
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
        inserter_arrow = iprototype.has_type(typeobject.type, "inserter"), -- TODO: inserter_arrow optimize
    }
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.__object.APPEAR = true
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

local function _update_fluid_name(self, datamodel, object, failed, x, y, dir) -- TODO: optimize x, y, dir
    if not ifluid:need_set_fluid(object.prototype_name) then
        if failed == false then
            object.state = _get_state(object.prototype_name, true)
            datamodel.show_confirm = true
        end
        datamodel.show_rotate = true
        return
    end

    local fluid_types = self:get_neighbor_fluid_types(EDITOR_CACHE_NAMES, object.prototype_name, x or object.x, y or object.y, dir or object.dir)
    if #fluid_types <= 1 then
        object.fluid_name = fluid_types[1] or ""
        if failed == false then
            object.state = _get_state(object.prototype_name, true)
            datamodel.show_confirm = true
        end
        datamodel.show_rotate = true
        return
    else
        object.fluid_name = ""
        object.state = _get_state(object.prototype_name, false)
    end
end

local function touch_move(self, datamodel, delta_vec)
    if self.pickup_object then
        local pickup_object = self.pickup_object
        iobject.move_delta(pickup_object, delta_vec)
        local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
        local coord = terrain:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, pickup_object.dir))
        if not coord then
            pickup_object.state = _get_state(pickup_object.prototype_name, false)
            datamodel.show_confirm = false
            return
        end
        if typeobject.supply_area and typeobject.supply_distance then
            --show power pole line
            local aw, ah = iprototype.unpackarea(typeobject.area)
            local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
            ipower.merge_pole({key = pickup_object.id, x = coord[1], y = coord[2], w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance})
        end
        if not self:check_construct_detector(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir) then
            pickup_object.state = _get_state(pickup_object.prototype_name, false)
            datamodel.show_confirm = false
            return
        end

        pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir) -- TODO: maybe set recipt according to entity type?
        _update_fluid_name(self, datamodel, pickup_object, false, coord[1], coord[2], pickup_object.dir)
    end
end

local function touch_end(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})

    local pickup_object = self.pickup_object
    if not pickup_object then
        return
    end

    iobject.align(self.pickup_object)

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        return
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) -- TODO: maybe set recipt according to entity type?
    _update_fluid_name(self, datamodel, pickup_object, false)
end

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        log.info("can not construct")
        return
    end

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    if iprototype.has_type(typeobject.type, "fluidbox") then
        -- fluid_name of object has been set in touch_end(), so we don't need to set it again
        global.fluidflow_id = global.fluidflow_id + 1
        pickup_object.fluidflow_id = global.fluidflow_id
    end

    if iprototype.has_type(typeobject.type, "fluidboxes") then
        self:update_fluidbox(EDITOR_CACHE_NAMES, "CONFIRM", pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.fluid_name)
    end

    if typeobject.supply_area then
        pickup_object.state = ("power_pole_confirm_%s"):format(typeobject.supply_area)
    else
        pickup_object.state = "confirm"
    end
    objects:set(pickup_object, "CONFIRM")
    pickup_object.PREPARE = true

    local item_typeobject = iprototype.queryByName("item", typeobject.name)
    assert(inventory:decrease(item_typeobject.id, 1)) -- promised by new_entity
    inventory:confirm()
    iui.update("construct.rml", "update_construct_inventory")

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    datamodel.show_construct_complete = true
    --
    if typeobject.supply_area and typeobject.supply_distance then
        local coord = terrain:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, pickup_object.dir))
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower.merge_pole({key = pickup_object.id, x = coord[1], y = coord[2], w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance}, true)
    end
    self.pickup_object = nil
    __new_entity(self, datamodel, typeobject)
end

local function complete(self, datamodel)
    if not inventory:complete() then
        return
    end

    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY", "POWER_AREA"})
    datamodel.show_construct_complete = false
    datamodel.show_rotate = false
    datamodel.show_confirm = false

    self.super.complete(self)
    -- update power network
    ipower.build_power_network(gameplay_core.get_world())
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

    local failed = false
    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        datamodel.show_rotate = true
        failed = true
    else
        pickup_object.state = _get_state(pickup_object.prototype_name, true)
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    pickup_object.dir = dir
    pickup_object.x, pickup_object.y = coord[1], coord[2]
    _update_fluid_name(self, datamodel, pickup_object, failed)
end

local function clean(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})
    inventory:revert()
    datamodel.show_confirm = false
    datamodel.show_rotate = false
    self.super.clean(self, datamodel)
    -- clear temp pole
    ipower.clear_all_temp_pole()
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