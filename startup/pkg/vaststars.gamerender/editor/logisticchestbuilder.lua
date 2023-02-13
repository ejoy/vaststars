local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local camera = ecs.require "engine.camera"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local DEFAULT_DIR <const> = 'N'
local irecipe = require "gameplay.interface.recipe"
local global = require "global"
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local iconstant = require "gameplay.interface.constant"
local logistic_coord = ecs.require "terrain"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ALL_DIR = iconstant.ALL_DIR
local igrid_entity = ecs.require "engine.grid_entity"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"
local ichest = require "gameplay.interface.chest"
local gameplay_core = require "gameplay.core"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}

local function __has_type(prototype_name, type)
    local typeobject = assert(iprototype.queryByName("entity", prototype_name))
    return iprototype.has_type(typeobject.type, type)
end

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

local function __table_length(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    if not self.super:check_construct_detector(prototype_name, x, y, dir) then
        return false
    end

    local ids = {}
    for _, dir in ipairs(ALL_DIR) do
        local _, dx, dy = logistic_coord:move_coord(x, y, dir, 1)
        if dx and dy then
            local obj = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
            if obj then
                if __has_type(obj.prototype_name, "logistic_hub") or __has_type(obj.prototype_name, "logistic_chest") then
                    assert(obj.logistic_hub_id)
                    ids[obj.logistic_hub_id] = true
                end
            end
        end
    end

    if __table_length(ids) ~= 1 then
        return false
    end

    return true, next(ids)
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
    local conn = connections[1]
    local succ, neighbor_x, neighbor_y = logistic_coord:move_coord(conn.x, conn.y, conn.dir, 1)
    if not succ then
        return
    end
    return logistic_coord:get_position_by_coord(neighbor_x, neighbor_y, 1, 1), neighbor_x, neighbor_y, conn.dir
end

local function __new_entity(self, datamodel, typeobject)
    iobject.remove(self.pickup_object)
    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir, logistic_coord)
    if not x or not y then
        return
    end

    local valid, logistic_hub_id = self:check_construct_detector(typeobject.name, x, y, dir)

    local state
    if not valid then
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
            t = logistic_coord:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)),
        },
        fluid_name = fluid_name,
        state = state,
        object_state = "none",
        logistic_hub_id = logistic_hub_id,
    }
    iui.open("construct_pop.rml", self.pickup_object.srt.t)

    local road_entrance_position = _get_road_entrance_position(typeobject, x, y, dir)
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
        self.grid_entity = igrid_entity.create("polyline_grid", logistic_coord.tile_width, logistic_coord.tile_height, logistic_coord.tile_size, {t = {0, 1, 0}})
        self.grid_entity:show(true)
    end
end

local function __align(object)
    assert(object)
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    local coord = logistic_coord:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, object.dir))
    if not coord then
        return object
    end
    object.srt.t = logistic_coord:get_position_by_coord(coord[1], coord[2], iprototype.rotate_area(typeobject.area, object.dir))
    return object, coord[1], coord[2]
end

local function touch_move(self, datamodel, delta_vec)
    if not self.pickup_object then
        return
    end
    local pickup_object = self.pickup_object
    iobject.move_delta(pickup_object, delta_vec, logistic_coord)

    local x, y
    self.pickup_object, x, y = __align(self.pickup_object)
    if not x then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        return
    end
    pickup_object.x, pickup_object.y = x, y

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)

    if self.road_entrance then
        local road_entrance_position = _get_road_entrance_position(typeobject, x, y, pickup_object.dir)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[pickup_object.dir], road_entrance_position)

        local t = {}
        for _, dir in ipairs(ALL_DIR) do
            local _, dx, dy = _get_road_entrance_position(typeobject, x, y, dir)
            if dx and dy then
                if global.roadnet[iprototype.packcoord(dx, dy)] then
                    t[#t+1] = dir
                end
            end
        end
        if #t == 1 and t[1] ~= pickup_object.dir then
            self:rotate_pickup_object(datamodel, t[1], delta_vec)
        end
    end

    local valid, logistic_hub_id = self:check_construct_detector(pickup_object.prototype_name, x, y, pickup_object.dir)
    if not valid then
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

    pickup_object.logistic_hub_id = logistic_hub_id

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
    if not x then
        return
    end
    pickup_object.x, pickup_object.y = x, y

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)

    if self.road_entrance then
        local road_entrance_position = _get_road_entrance_position(typeobject, x, y, pickup_object.dir)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[pickup_object.dir], road_entrance_position)
    end

    local valid, logistic_hub_id = self:check_construct_detector(pickup_object.prototype_name, x, y, pickup_object.dir)
    if not valid then
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
    pickup_object.logistic_hub_id = logistic_hub_id

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
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({key = pickup_object.id, targets = {}, x = pickup_object.x, y = pickup_object.y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance}, true)
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end

    do
        global.construct_queue:put(pickup_object.prototype_name, pickup_object.id)
        local typeobject = iprototype.queryByName("item", pickup_object.prototype_name)
        local slot = global.base_chest_cache[typeobject.id] or {amount = 0}
        local count = slot.amount
        local request_count = global.construct_queue:size(pickup_object.prototype_name)
        if count < request_count then
            ichest.base_add_req(gameplay_core.get_world(), pickup_object.prototype_name, 1)
        end
    end

    self.pickup_object = nil
    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    __new_entity(self, datamodel, typeobject)
end

local function complete(self, datamodel, object_id)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY", "POWER_AREA"})
    datamodel.show_rotate = false
    datamodel.show_confirm = false

    self.super.complete(self, object_id)
end

local function rotate_pickup_object(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName("entity", pickup_object.prototype_name)
    local coord = logistic_coord:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end

    local valid, logistic_hub_id = self:check_construct_logistic_hub(pickup_object.prototype_name, pickup_object.x, pickup_object.y, dir)
    if not valid then
        pickup_object.state = _get_state(pickup_object.prototype_name, false)
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        pickup_object.state = _get_state(pickup_object.prototype_name, true)
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    pickup_object.logistic_hub_id = logistic_hub_id
    pickup_object.dir = dir

    local x, y = coord[1], coord[2]
    if not x then
        return
    end
    pickup_object.x, pickup_object.y = x, y

    local road_entrance_position, dx, dy, ddir = _get_road_entrance_position(typeobject, x, y, pickup_object.dir)
    if road_entrance_position then
        self.road_entrance:set_srt(mc.ONE, ROTATORS[pickup_object.dir], road_entrance_position)
    end
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    ieditor:revert_changes({"TEMPORARY", "POWER_AREA"})
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
    M.clean = clean
    M.check_construct_detector = check_construct_detector

    return M
end
return create