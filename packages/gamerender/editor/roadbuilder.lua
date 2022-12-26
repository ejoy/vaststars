local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local DEFAULT_DIR <const> = 'N'
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local irecipe = require "gameplay.interface.recipe"
local global = require "global"
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local imining = require "gameplay.interface.mining"
local inventory = global.inventory
local coord_transform = ecs.require "terrain"
local igrid_entity = ecs.require "engine.grid_entity"
local iroadnet = ecs.require "roadnet"

local function _get_state(prototype_name, ok)
    if ok then
        return "construct"
    else
        return "invalid_construct"
    end
end

local function __new_entity(self, datamodel, typeobject)
    iobject.remove(self.pickup_object)
    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir, coord_transform, "align")
    if not x or not y then
        return
    end

    local state
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        state = _get_state(typeobject.name, false)
        datamodel.show_confirm = false
    else
        state = _get_state(typeobject.name, true)
        datamodel.show_confirm = true
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
        srt = {
            t = coord_transform:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)),
        },
        fluid_name = fluid_name,
        state = state,
        object_state = "none",
    }
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", coord_transform.tile_width, coord_transform.tile_height, terrain.tile_size, {t = {0, 8.5, 0}})
        self.grid_entity:show(true)
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

local function touch_move(self, datamodel, delta_vec)
    if not self.pickup_object then
        return
    end
    local pickup_object = self.pickup_object
    iobject.move_delta(pickup_object, delta_vec, coord_transform, "align")

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    local coord = coord_transform:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, pickup_object.dir))
    if not coord then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        return
    end

    if not self:check_construct_detector(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
    else
        datamodel.show_confirm = true
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir) -- TODO: maybe set recipt according to entity type?

    -- update temp pole
    if typeobject.supply_area and typeobject.supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({key = pickup_object.id, targets = {}, x = coord[1], y = coord[2], w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance, smooth_pos = true})
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end
end

local function touch_end(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})

    local pickup_object = self.pickup_object
    if not pickup_object then
        return
    end

    local x, y
    self.pickup_object, x, y = iobject.align(self.pickup_object)
    self.pickup_object.x, self.pickup_object.y = x, y

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
    else
        pickup_object.state = _get_state(pickup_object.prototype_name, true)
        datamodel.show_confirm = true
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) -- TODO: maybe set recipt according to entity type?

    -- update temp pole
    if typeobject.supply_area and typeobject.supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({key = pickup_object.id, targets = {}, x = self.pickup_object.x, y = self.pickup_object.y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance})
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end
end

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local succ = self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)
    if not succ then
        log.info("can not construct")
        return
    end

    local road_type, road_mask = iroadnet.get_road_mask(pickup_object.prototype_name, pickup_object.dir)
    iroadnet.editor_set(pickup_object.x, pickup_object.y, road_type, road_mask, nil)
    iobject.remove(self.pickup_object)

    if self.grid_entity then
        self.grid_entity:remove()
    end
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY", "POWER_AREA"})
    datamodel.show_confirm = false

    self.super.complete(self)

    -- self.pickup_object = nil
    -- __new_entity(self, datamodel, typeobject)
end

local function complete(self, datamodel)
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    local succ = self.super:check_construct_detector(prototype_name, x, y, dir)
    if not succ then
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

local function rotate_pickup_object(self, datamodel, dir, delta_vec)
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
    end

    ieditor:revert_changes({"TEMPORARY"})
    inventory:revert()
    datamodel.show_confirm = false
    datamodel.show_rotate = false
    self.super.clean(self, datamodel)
    -- clear temp pole
    ipower:clear_all_temp_pole()
    ipower_line.update_temp_line(ipower:get_temp_pole())
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