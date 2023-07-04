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
local coord_system = ecs.require "terrain"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ALL_DIR = iconstant.ALL_DIR
local igrid_entity = ecs.require "engine.grid_entity"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"
local global = require "global"
local create_sprite = ecs.require "sprite"
local SPRITE_COLOR = import_package "vaststars.prototype".load("sprite_color")
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local create_pickup_icon = ecs.require "pickup_icon".create
local create_pickup_icon_chimney = ecs.require "pickup_icon_chimney".create
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local ibuilding = ecs.import.interface "vaststars.gamerender|ibuilding"
local create_pickup_selected_box = ecs.require "editor.common.pickup_selected_box"
local create_selected_boxes = ecs.require "selected_boxes"
local vsobject_manager = ecs.require "vsobject_manager"
local gameplay = import_package "vaststars.gameplay"
local igameplay_building = gameplay.interface "building"
local ROAD_TILE_SCALE_WIDTH <const> = 2
local ROAD_TILE_SCALE_HEIGHT <const> = 2

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


local function __get_nearby_buldings(exclude_id, x, y, w, h)
    local r = {}
    local begin_x, begin_y = coord_system:bound_coord(x - ((10 - w) // 2), y - ((10 - h) // 2))
    local end_x, end_y = coord_system:bound_coord(x + ((10 - w) // 2) + w, y + ((10 - h) // 2) + h)
    for x = begin_x, end_x do
        for y = begin_y, end_y do
            local object = objects:coord(x, y)
            if object and object.id ~= exclude_id then
                r[object.id] = object
            end
        end
    end
    return r
end

local function __is_building_intersect(x1, y1, w1, h1, x2, y2, w2, h2)
    local x1_1, y1_1 = x1, y1
    local x1_2, y1_2 = x1 + w1 - 1, y1
    local x1_3, y1_3 = x1, y1 + h1 - 1
    local x1_4, y1_4 = x1 + w1 - 1, y1 + h1 - 1

    if (x1_1 >= x2 and x1_1 <= x2 + w2 - 1 and y1_1 >= y2 and y1_1 <= y2 + h2 - 1) or
        (x1_2 >= x2 and x1_2 <= x2 + w2 - 1 and y1_2 >= y2 and y1_2 <= y2 + h2 - 1) or
        (x1_3 >= x2 and x1_3 <= x2 + w2 - 1 and y1_3 >= y2 and y1_3 <= y2 + h2 - 1) or
        (x1_4 >= x2 and x1_4 <= x2 + w2 - 1 and y1_4 >= y2 and y1_4 <= y2 + h2 - 1) then
        return true
    end

    local x2_1, y2_1 = x2, y2
    local x2_2, y2_2 = x2 + w2 - 1, y2
    local x2_3, y2_3 = x2, y2 + h2 - 1
    local x2_4, y2_4 = x2 + w2 - 1, y2 + h2 - 1

    if (x2_1 >= x1 and x2_1 <= x1 + w1 - 1 and y2_1 >= y1 and y2_1 <= y1 + h1 - 1) or
        (x2_2 >= x1 and x2_2 <= x1 + w1 - 1 and y2_2 >= y1 and y2_2 <= y1 + h1 - 1) or
        (x2_3 >= x1 and x2_3 <= x1 + w1 - 1 and y2_3 >= y1 and y2_3 <= y1 + h1 - 1) or
        (x2_4 >= x1 and x2_4 <= x1 + w1 - 1 and y2_4 >= y1 and y2_4 <= y1 + h1 - 1) then
        return true
    end

    return false
end

local function __show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)
    local nearby_buldings = __get_nearby_buldings(self.move_object_id, x, y, iprototype.unpackarea(typeobject.area))
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    local redraw = {}
    for object_id, object in pairs(nearby_buldings) do
        redraw[object_id] = object
    end

    for object_id in pairs(redraw) do
        if self.selected_boxes[object_id] then
            redraw[object_id] = nil
        end
    end
    for object_id in pairs(self.selected_boxes) do
        if redraw[object_id] then
            self.selected_boxes[object_id]:remove()
            self.selected_boxes[object_id] = nil
        end
    end

    for object_id, object in pairs(redraw) do
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if __is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.unpackarea(typeobject.area)
                local sw, sh = iprototype.unpackarea(typeobject.supply_area)
                if __is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.unpackarea(otypeobject.area)
                        local sw, sh = iprototype.unpackarea(otypeobject.supply_area)
                        if __is_building_intersect(x, y, ow, oh, object.x  - (sw - aw) // 2, object.y - (sh - ah) // 2, sw, sh) then
                            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                        else
                            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                        end
                    end
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            end
        end

        assert(self.selected_boxes[object_id] == nil)
        self.selected_boxes[object_id] = create_selected_boxes(
            {
                "/pkg/vaststars.resources/prefabs/selected-box-no-animation.prefab",
                "/pkg/vaststars.resources/prefabs/selected-box-no-animation-line.prefab",
            },
            object.srt.t, color, iprototype.rotate_area(otypeobject.area, object.dir)
        )
    end

    for object_id, o in pairs(self.selected_boxes) do
        local object = assert(objects:get(object_id))
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if __is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.unpackarea(typeobject.area)
                local sw, sh = iprototype.unpackarea(typeobject.supply_area)
                if __is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.unpackarea(otypeobject.area)
                        local sw, sh = iprototype.unpackarea(otypeobject.supply_area)
                        if __is_building_intersect(x, y, ow, oh, object.x  - (sw - aw) // 2, object.y - (sh - ah) // 2, sw, sh) then
                            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                        else
                            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                        end
                    else
                        color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                    end
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            end
        end
        o:set_color(color)
    end
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
    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "translucent", color = SPRITE_COLOR.MOVE_SELF, emissive_color = SPRITE_COLOR.MOVE_SELF}

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
        self.pickup_components.pickup_icon = create_pickup_icon(typeobject, dir, e.assembling.recipe, self.pickup_object.srt)
    end
    if e.chimney then
        self.pickup_components.pickup_icon_chimney = create_pickup_icon_chimney(dir, self.pickup_object.srt, typeobject)
    end
    self.pickup_components.self_selected_box = create_pickup_selected_box(self.pickup_object.srt.t, typeobject, dir, datamodel.show_confirm and true or false)
    __show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)

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
        if iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
            self.grid_entity = igrid_entity.create("polyline_grid", terrain._width // ROAD_TILE_SCALE_WIDTH, terrain._height // ROAD_TILE_SCALE_HEIGHT, terrain.tile_size * ROAD_TILE_SCALE_WIDTH, {t = __calc_grid_position(self, typeobject)})
        else
            self.grid_entity = igrid_entity.create("polyline_grid", coord_system.tile_width, coord_system.tile_height, coord_system.tile_size, {t = __calc_grid_position(self, typeobject)})
        end
        self.grid_entity:show(true)
    end

    local object = assert(objects:get(self.move_object_id))
    ipower:build_power_network(gameplay_core.get_world(), object.gameplay_eid)
end

-- TODO: duplicate from builder.lua
local function _get_mineral_recipe(prototype_name, x, y, w, h)
    local typeobject = iprototype.queryByName(prototype_name)
    if not iprototype.has_type(typeobject.type, "mining") then
        return
    end
    local succ, mineral = terrain:can_place_on_mineral(x, y, w, h)
    if not succ then
        return
    end
    return imining.get_mineral_recipe(prototype_name, mineral)
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
                if ibuilding.get(dx, dy) then
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
        for _, c in pairs(self.pickup_components) do
            c:on_status_change(datamodel.show_confirm)
        end
        __show_nearby_buildings_selected_boxes(self, x, y, pickup_object.dir, typeobject)
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
        for _, c in pairs(self.pickup_components) do
            c:on_status_change(datamodel.show_confirm)
        end
        __show_nearby_buildings_selected_boxes(self, x, y, pickup_object.dir, typeobject)
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, x, y, w, h)

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
    e.building_changed = true
    local gameworld = gameplay_core.get_world()
    local building = gameplay.interface "building"
    building.move(gameworld, e, self.pickup_object.x, self.pickup_object.y)
    building.rotate(gameworld, e, self.pickup_object.dir)

    iobject.coord(object, self.pickup_object.x, self.pickup_object.y, coord_system)
    object.dir = self.pickup_object.dir
    object.srt.r = ROTATORS[object.dir]
    objects:set(object, "CONSTRUCTED")
    objects:coord_update(object)

    igameplay_building.move(gameplay_core.get_world(), e, object.x, object.y)

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

            if ibuilding.get(dx, dy) then
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

    for _, o in pairs(self.selected_boxes) do
        o:remove()
    end
    self.selected_boxes = {}

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

    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "opaque", color = math3d.null, emissive_color = math3d.null}
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
    M.selected_boxes = {}

    return M
end
return create