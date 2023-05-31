local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.interface "icamera_controller"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local irecipe = require "gameplay.interface.recipe"
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local imining = require "gameplay.interface.mining"
local math3d = require "math3d"
local iconstant = require "gameplay.interface.constant"
local coord_system = require "global".coord_system
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ALL_DIR = iconstant.ALL_DIR
local igrid_entity = ecs.require "engine.grid_entity"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"
local global = require "global"
local create_sprite = ecs.require "sprite"
local SPRITE_COLOR = import_package "vaststars.prototype".load("sprite_color")
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local ientity = require "gameplay.interface.entity"
local create_pickup_icon = ecs.require "pickup_icon".create
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local gameplay = import_package "vaststars.gameplay"
local iroad = gameplay.interface "road"

-- TODO: duplicate from roadbuilder.lua
local function _get_connections(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local r = {}
    if not typeobject.crossing then
        return r
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local dx, dy, ddir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
        r[#r+1] = {x = x + dx, y = y + dy, dir = ddir}
    end
    return r
end

local function _get_road_entrance_position(typeobject, x, y, dir)
    if not typeobject.crossing then
        return
    end
    local connections = _get_connections(typeobject.name, x, y, dir)
    local conn = connections[1]
    local succ, neighbor_x, neighbor_y = coord_system:move_coord(conn.x, conn.y, conn.dir, 1)
    if not succ then
        return
    end
    return coord_system:get_position_by_coord(neighbor_x, neighbor_y, 1, 1), neighbor_x, neighbor_y, conn.dir
end

local function __rotate_area(w, h, dir)
    if dir == 'N' or dir == 'S' then
        return w, h
    elseif dir == 'E' or dir == 'W' then
        return h, w
    end
end

local function __create_self_sprite(typeobject, x, y, dir, sprite_color)
    local sprite
    local offset_x, offset_y = 0, 0
    if typeobject.supply_area then
        local aw, ah = iprototype.rotate_area(typeobject.supply_area, dir)
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        sprite = create_sprite(x + offset_x, y + offset_y, aw, ah, dir, sprite_color)
    elseif typeobject.power_supply_area then
        local aw, ah = typeobject.power_supply_area:match("(%d+)x(%d+)")
        aw, ah = __rotate_area(aw, ah, dir)
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        sprite = create_sprite(x + offset_x, y + offset_y, aw, ah, dir, sprite_color)
    end
    return sprite
end

local function __new_entity(self, datamodel, typeobject)
    local object = assert(objects:get(self.move_object_id))

    iobject.remove(self.pickup_object)
    local dir = object.dir
    local x, y = iobject.central_coord(typeobject.name, dir, coord_system, 1)
    if not x or not y then
        return
    end
    local building_positon = coord_system:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir))

    local sprite_color
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_INVALID
        end
        datamodel.show_confirm = false
    else
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_VALID
        end
        datamodel.show_confirm = true
    end
    datamodel.show_rotate = (typeobject.rotate_on_build == true)

    -- some assembling machine have default recipe
    local fluid_name = ""
    if typeobject.recipe then
        local recipe_typeobject = iprototype.queryByName(typeobject.recipe)
        if recipe_typeobject then
            fluid_name = irecipe.get_init_fluids(recipe_typeobject) or "" -- maybe no fluid in recipe
        else
            fluid_name = ""
        end
    end

    local object = assert(objects:get(self.move_object_id))
    local e = assert(gameplay_core.get_entity(object.gameplay_eid))

    self.pickup_object = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        srt = {
            t = math3d.ref(math3d.vector(building_positon)),
            r = ROTATORS[dir],
        },
        fluid_name = fluid_name,
        group_id = 0,
    }

    if e.assembling and e.assembling.recipe ~= 0 then
        self.pickup_components[#self.pickup_components + 1] = create_pickup_icon(typeobject, dir, e.assembling.recipe, self.pickup_object.srt)
    end

    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = __create_self_sprite(typeobject, x, y, dir, sprite_color)

    local road_entrance_position, _, _, road_entrance_dir = _get_road_entrance_position(typeobject, x, y, dir)
    if road_entrance_position then
        local srt = {t = road_entrance_position, r = ROTATORS[road_entrance_dir]}
        if datamodel.show_confirm then
            self.road_entrance = create_road_entrance(srt, "valid")
        else
            self.road_entrance = create_road_entrance(srt, "invalid")
        end
    end
end

local function __calc_grid_position(self, typeobject)
    local _, originPosition = coord_system:align(math3d.vector {0, 0, 0}, iprototype.unpackarea(typeobject.area))
    local buildingPosition = coord_system:get_position_by_coord(self.pickup_object.x, self.pickup_object.y, iprototype.unpackarea(typeobject.area))
    return math3d.ref(math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET))
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", coord_system.tile_width, coord_system.tile_height, coord_system.tile_size, {t = __calc_grid_position(self, typeobject)})
        self.grid_entity:show(true)
    end

    local object = assert(objects:get(self.move_object_id))
    ipower:build_power_network(gameplay_core.get_world(), object.gameplay_eid)
end

-- TODO: duplicate from builder.lua
local function _get_mineral_recipe(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName(prototype_name)
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
    local typeobject = iprototype.queryByName(object.prototype_name)
    local coord, position = coord_system:align(icamera_controller.get_central_position(), iprototype.rotate_area(typeobject.area, object.dir))
    if not coord then
        return object
    end
    object.srt.t = math3d.ref(math3d.vector(position))
    return object, coord[1], coord[2]
end

local function touch_move(self, datamodel, delta_vec)
    if not self.pickup_object then
        return
    end
    local pickup_object = self.pickup_object
    iobject.move_delta(pickup_object, delta_vec, coord_system)

    local x, y
    self.pickup_object, x, y = __align(self.pickup_object)
    local lx, ly = x, y
    if not lx then
        datamodel.show_confirm = false
        return
    end
    pickup_object.x, pickup_object.y = lx, ly

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)

    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.pickup_object.srt, self.pickup_object.dir)
    end

    if self.road_entrance then
        local road_entrance_position, _, _, road_entrance_dir = _get_road_entrance_position(typeobject, lx, ly, pickup_object.dir)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[road_entrance_dir], road_entrance_position)

        local t = {}
        for _, dir in ipairs(ALL_DIR) do
            local _, dx, dy = _get_road_entrance_position(typeobject, lx, ly, dir)
            if dx and dy then
                if iroad.get(gameplay_core.get_world(), dx, dy) then
                    t[#t+1] = dir
                end
            end
        end
        if #t == 1 and t[1] ~= pickup_object.dir then
            self:rotate_pickup_object(datamodel, t[1], delta_vec)
        end
    end

    if self.grid_entity then
        self.grid_entity:send("obj_motion", "set_position", __calc_grid_position(self, typeobject))
    end

    local sprite_color
    local offset_x, offset_y = 0, 0
    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)
    if not self:check_construct_detector(pickup_object.prototype_name, lx, ly, pickup_object.dir) then -- TODO
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
        end
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
            local aw, ah = iprototype.unpackarea(typeobject.supply_area)
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_INVALID
            local aw, ah = typeobject.power_supply_area:match("(%d+)x(%d+)")
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        end
        if self.sprite then
            self.sprite:move(pickup_object.x + offset_x, pickup_object.y + offset_y, sprite_color)
        end
        return
    else
        datamodel.show_confirm = true

        if self.road_entrance then
            self.road_entrance:set_state("valid")
        end
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
            local aw, ah = iprototype.unpackarea(typeobject.supply_area)
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_VALID
            local aw, ah = typeobject.power_supply_area:match("(%d+)x(%d+)")
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        end
        if self.sprite then
            self.sprite:move(pickup_object.x + offset_x, pickup_object.y + offset_y, sprite_color)
        end
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, lx, ly, pickup_object.dir) -- TODO: maybe set recipt according to entity type?

    -- update temp pole
    if typeobject.power_supply_area and typeobject.power_supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.power_supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, position = pickup_object.srt.t, targets = {}, x = lx, y = ly, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.power_supply_distance, smooth_pos = true, power_network_link = typeobject.power_network_link})
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end
end

local function touch_end(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})

    touch_move(self, datamodel, {0, 0, 0})
end

local function confirm(self, datamodel)
    ---
    local object = assert(objects:get(self.move_object_id))
    local e = gameplay_core.get_entity(object.gameplay_eid)
    e.building.x = self.pickup_object.x
    e.building.y = self.pickup_object.y
    ientity:set_direction(gameplay_core.get_world(), e, self.pickup_object.dir)
    e.building_changed = true

    iobject.coord(object, self.pickup_object.x, self.pickup_object.y, coord_system)
    object.dir = self.pickup_object.dir
    object.srt.r = ROTATORS[object.dir]
    objects:set(object, "CONSTRUCTED")
    objects:coord_update(object)

    igameplay.build_world()

    local building = global.buildings[object.id]
    if building then
        for _, v in pairs(building) do
            v:on_position_change(object.srt, object.dir)
        end
    end

    -- TODO: duplicate code with editor/builder.lua
    local typeobject = iprototype.queryByName(object.prototype_name)
    if typeobject.power_supply_area and typeobject.power_supply_distance then
        ipower:build_power_network(gameplay_core.get_world())
        ipower_line.update_line(ipower:get_pole_lines())
    else
        local gw = gameplay_core.get_world()
        local e = gameplay_core.get_entity(object.gameplay_eid)
        if e.capacitance then
            local typeobject = iprototype.queryById(e.building.prototype)
            local aw, ah = iprototype.unpackarea(typeobject.area)
            local capacitance = {}
            capacitance[#capacitance + 1] = {
                targets = {},
                power_network_link_target = 0,
                eid = e.eid,
                x = e.building.x,
                y = e.building.y,
                w = aw,
                h = ah,
            }
            ipower:set_network_id(gw, capacitance)
        end
    end

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false

    return false
end

local function complete(self, object_id)
    assert(false)
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    local succ = self.super:check_construct_detector(prototype_name, x, y, dir, self.move_object_id)
    if not succ then
        return false
    end

    local typeobject = iprototype.queryByName(prototype_name)
    if typeobject.crossing then
        local valid = false
        for _, conn in ipairs(_get_connections(prototype_name, x, y, dir)) do
            local succ, dx, dy = coord_system:move_coord(conn.x, conn.y, conn.dir, 1)
            if not succ then
                goto continue
            end

            if iroad.get(gameplay_core.get_world(), dx, dy) then
                valid = true
                break
            end
            ::continue::
        end

        if not valid then
            return false
        end
    end

    return true
end

local function rotate_pickup_object(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)
    pickup_object.dir = dir
    pickup_object.srt.r = ROTATORS[dir]

    local x, y
    self.pickup_object, x, y = __align(self.pickup_object)
    local lx, ly = x, y
    if not lx then
        datamodel.show_confirm = false
        return
    end
    pickup_object.x, pickup_object.y = lx, ly

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.pickup_object.srt, self.pickup_object.dir)
    end
    local coord = coord_system:align(icamera_controller.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    local sprite_color
    if not self:check_construct_detector(typeobject.name, pickup_object.x, pickup_object.y, dir) then
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_INVALID
        end
        datamodel.show_confirm = false
    else
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_VALID
        end
        datamodel.show_confirm = true
    end

    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = __create_self_sprite(typeobject, x, y, dir, sprite_color)

    local road_entrance_position, dx, dy, ddir = _get_road_entrance_position(typeobject, x, y, pickup_object.dir)
    if road_entrance_position then
        self.road_entrance:set_srt(mc.ONE, ROTATORS[ddir], road_entrance_position)
    end
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false

    for _, c in pairs(self.pickup_components) do
        c:remove()
    end

    self.super.clean(self, datamodel)
    -- clear temp pole
    ipower:clear_all_temp_pole()
    ipower_line.update_temp_line(ipower:get_temp_pole())

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
end

local function create(move_object_id)
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
    M.move_object_id = move_object_id
    M.pickup_components = {}

    return M
end
return create