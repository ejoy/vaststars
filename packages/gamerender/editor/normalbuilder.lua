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
local ipower_line = ecs.require "power_line"
local imining = require "gameplay.interface.mining"
local inventory = global.inventory
local math3d = require "math3d"
local iconstant = require "gameplay.interface.constant"
local coord_transform = require "global".coord_transform_building
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ALL_DIR = iconstant.ALL_DIR
local igrid_entity = ecs.require "engine.grid_entity"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"

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

local function _building_to_logisitic(x, y)
    local nposition = assert(coord_transform:get_begin_position_by_coord(x, y))
    nposition[1] = nposition[1] + 5
    nposition[3] = nposition[3] - 5
    local ncoord = terrain:get_coord_by_position(math3d.vector(nposition)) -- building layer to logisitc layer
    if not ncoord then
        return
    end
    return ncoord[1], ncoord[2]
end

-- TODO: duplicate from roadbuilder.lua
local function _get_connections(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local r = {}
    if not typeobject.crossing then
        return r
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local dx, dy, ddir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
        r[#r+1] = {x = x + dx, y = y + dy, dir = ddir, roadside = conn.roadside}
    end
    return r
end

local function _get_road_entrance_position(typeobject, x, y, dir)
    if not typeobject.crossing then
        return
    end
    local connections = _get_connections(typeobject.name, x, y, dir)
    assert(#connections == 1) -- only one roadside
    local conn = connections[1]
    local succ, neighbor_x, neighbor_y = terrain:move_coord(conn.x, conn.y, conn.dir, 1)
    if not succ then
        return
    end
    return terrain:get_position_by_coord(neighbor_x, neighbor_y, 1, 1), neighbor_x, neighbor_y, conn.dir
end

local function __new_entity(self, datamodel, typeobject)
    iobject.remove(self.pickup_object)
    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir, coord_transform, "align", 1)
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
        srt = {
            t = coord_transform:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir, 1, 1)),
        },
        fluid_name = fluid_name,
        state = state,
        object_state = "none",
    }
    iui.open("construct_pop.rml", self.pickup_object.srt.t)

    if iprototype.is_road(typeobject.name) then
        return
    end

    local dx, dy = _building_to_logisitic(x, y)
    local road_entrance_position = _get_road_entrance_position(typeobject, dx, dy, dir)
    if road_entrance_position then
        local srt = {t = road_entrance_position}
        if datamodel.show_confirm then
            self.road_entrance = create_road_entrance(srt, "valid")
        else
            self.road_entrance = create_road_entrance(srt, "invalid")
        end
    end
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", coord_transform.tile_width, coord_transform.tile_height, terrain.tile_size, {t = {0, 1, 0}})
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

local function __align(object)
    assert(object)
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    local coord = coord_transform:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, object.dir, 1, 1))
    if not coord then
        return object
    end
    object.srt.t = coord_transform:get_position_by_coord(coord[1], coord[2], iprototype.rotate_area(typeobject.area, object.dir, 1, 1))
    return object, coord[1], coord[2]
end

local function touch_move(self, datamodel, delta_vec)
    if not self.pickup_object then
        return
    end
    local pickup_object = self.pickup_object
    iobject.move_delta(pickup_object, delta_vec, coord_transform, "align", 1)

    local x, y
    self.pickup_object, x, y = __align(self.pickup_object)
    if not x then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        return
    end

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)

    if self.road_entrance then
        local dx, dy = _building_to_logisitic(x, y)
        local road_entrance_position = _get_road_entrance_position(typeobject, dx, dy, pickup_object.dir)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[pickup_object.dir], road_entrance_position)

        local t = {}
        for _, dir in ipairs(ALL_DIR) do
            local _, dx, dy = _get_road_entrance_position(typeobject, x, y, dir)
            if dx and dy then
                local road = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
                if road and iprototype.is_road(road.prototype_name) then
                    t[#t+1] = dir
                end
            end
        end
        if #t == 1 and t[1] ~= pickup_object.dir then
            self:rotate_pickup_object(datamodel, t[1], delta_vec)
        end
    end

    if not self:check_construct_detector(pickup_object.prototype_name, x, y, pickup_object.dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
        end
        return
    else
        if self.road_entrance then
            self.road_entrance:set_state("valid")
        end
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, x, y, pickup_object.dir) -- TODO: maybe set recipt according to entity type?

    -- update temp pole
    if typeobject.supply_area and typeobject.supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({key = pickup_object.id, targets = {}, x = x, y = y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance, smooth_pos = true})
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
    self.pickup_object, x, y = __align(self.pickup_object)
    x, y = _building_to_logisitic(x, y)
    if not x then
        return
    end
    pickup_object.x, pickup_object.y = x, y

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)

    if self.road_entrance then
        local road_entrance_position = _get_road_entrance_position(typeobject, x, y, pickup_object.dir)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[pickup_object.dir], road_entrance_position)
    end

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        if self.road_entrance then
            self.road_entrance:set_state("invalid")
        end
        return
    else
        pickup_object.state = _get_state(pickup_object.prototype_name, true)
        datamodel.show_confirm = true
        if self.road_entrance then
            self.road_entrance:set_state("valid")
        end
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

local iflow_connector = require "gameplay.interface.flow_connector"
local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local succ = self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)
    if not succ then
        log.info("can not construct")
        return
    end

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    if typeobject.supply_area then
        pickup_object.state = ("power_pole_confirm_%s"):format(typeobject.supply_area)
    else
        pickup_object.state = "confirm"
    end
    objects:set(pickup_object, "CONFIRM")
    pickup_object.PREPARE = true
    pickup_object.object_state = "confirm"

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    --
    if typeobject.supply_area and typeobject.supply_distance then
        local coord = coord_transform:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, pickup_object.dir, 1, 1))
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({key = pickup_object.id, targets = {}, x = coord[1], y = coord[2], w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance}, true)
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end

    global.construct_queue:put(pickup_object.prototype_name, pickup_object.id)

    self.pickup_object = nil
    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    __new_entity(self, datamodel, typeobject)
end

local function complete(self, datamodel, object_id)
    if not inventory:complete() then
        return
    end

    if self.grid_entity then
        self.grid_entity:remove()
    end
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY", "POWER_AREA"})
    datamodel.show_rotate = false
    datamodel.show_confirm = false

    self.super.complete(self, object_id)

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
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
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    local coord = coord_transform:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, dir, 1, 1))
    if not coord then
        return
    end

    if not self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, dir) then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        pickup_object.state = _get_state(pickup_object.prototype_name, true)
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    pickup_object.dir = dir

    local x, y = _building_to_logisitic(coord[1], coord[2])
    if not x then
        return
    end
    pickup_object.x, pickup_object.y = x, y

    local road_entrance_position, dx, dy, ddir = _get_road_entrance_position(typeobject, x, y, pickup_object.dir)
    if road_entrance_position then
        self.road_entrance:set_srt(mc.ONE, ROTATORS[pickup_object.dir], road_entrance_position)

        local obj = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
        if obj and iprototype.is_road(obj.prototype_name) then
            obj = assert(objects:modify(dx, dy, EDITOR_CACHE_NAMES, iobject.clone))
            obj.prototype_name, obj.dir = iflow_connector.covers_roadside(obj.prototype_name, obj.dir, iprototype.reverse_dir(ddir), true)
        end
    end
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

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end

    iui.close("construct_pop.rml")
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