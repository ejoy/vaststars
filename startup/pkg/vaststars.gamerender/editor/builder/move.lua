local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local ROTATORS <const> = CONSTANT.ROTATORS
local ROAD_WIDTH_COUNT <const> = CONSTANT.ROAD_WIDTH_COUNT
local ROAD_HEIGHT_COUNT <const> = CONSTANT.ROAD_HEIGHT_COUNT
local ROAD_WIDTH_SIZE <const> = CONSTANT.ROAD_WIDTH_SIZE
local ROAD_HEIGHT_SIZE <const> = CONSTANT.ROAD_HEIGHT_SIZE
local ALL_DIR <const> = CONSTANT.ALL_DIR
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local GRID_POSITION_OFFSET <const> = CONSTANT.GRID_POSITION_OFFSET
local COLOR <const> = ecs.require "vaststars.prototype|color"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local SELECTION_BOX_MODEL <const> = ecs.require "vaststars.prototype|selection_box_model"

local math3d = require "math3d"
local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.require "engine.system.camera_controller"
local objects = require "objects"
local iobject = ecs.require "object"
local iminer = require "gameplay.interface.miner"
local igrid_entity = ecs.require "engine.grid_entity"
local mc = import_package "ant.math".constant
local create_station_indicator = ecs.require "editor.indicators.station_indicator"
local itranslucent_plane = ecs.require "translucent_plane"
local create_translucent_plane = itranslucent_plane.create
local flush_translucent_plane = itranslucent_plane.flush
local create_pickup_icon = ecs.require "pickup_icon".create
local create_fluid_indicators = ecs.require "fluid_indicators".create
local icoord = require "coord"
local gameplay_core = require "gameplay.core"
local ibuilding = ecs.require "render_updates.building"
local create_pickup_selection_box = ecs.require "editor.indicators.pickup_selection_box"
local create_selection_box = ecs.require "selection_box"
local vsobject_manager = ecs.require "vsobject_manager"
local igameplay = ecs.require "gameplay.gameplay_system"
local srt = require "utility.srt"
local imineral = ecs.require "mineral"

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
    local succ, neighbor_x, neighbor_y = icoord.move(conn.x, conn.y, conn.dir, 1)
    if not succ then
        return
    end
    return math3d.vector(icoord.position(neighbor_x, neighbor_y, 1, 1)), neighbor_x, neighbor_y, conn.dir
end

local function _create_self_translucent_plane(typeobject, x, y, dir, translucent_plane_color)
    local translucent_plane
    local offset_x, offset_y = 0, 0
    if typeobject.supply_area then
        local aw, ah = iprototype.rotate_area(typeobject.supply_area, dir)
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        translucent_plane = create_translucent_plane(x + offset_x, y + offset_y, aw, ah, translucent_plane_color)
    end
    return translucent_plane
end

local function _get_nearby_buildings(x, y, w, h)
    local r = {}
    local offset_x, offset_y = (10 - w) // 2, (10 - h) // 2
    local begin_x, begin_y = icoord.bound(x - offset_x, y - offset_y)
    local end_x, end_y = icoord.bound(x + offset_x + w, y + offset_y + h)
    for x = begin_x, end_x do
        for y = begin_y, end_y do
            local object = objects:coord(x, y)
            if object then
                r[object.id] = object
            end
        end
    end
    return r
end

local function _is_building_intersect(x1, y1, w1, h1, x2, y2, w2, h2)
    if x1 + w1 <= x2 or x2 + w2 <= x1 then
        return false
    end

    if y1 + h1 <= y2 or y2 + h2 <= y1 then
        return false
    end

    return true
end

local function _show_nearby_buildings_selection_box(self, x, y, dir, typeobject)
    local nearby_buldings = _get_nearby_buildings(self.move_object_id, x, y, iprototype.rotate_area(typeobject.area, dir))
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    local redraw = {}
    for object_id, object in pairs(nearby_buldings) do
        if not self.selection_box[object_id] then
            redraw[object_id] = object
        end
    end

    for object_id, o in pairs(self.selection_box) do
        if not nearby_buldings[object_id] then
            o:remove()
            self.selection_box[object_id] = nil
        end
    end

    for object_id, object in pairs(redraw) do
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if _is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                local sw, sh = iprototype.rotate_area(typeobject.supply_area, object.dir)
                if _is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                        local sw, sh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
                        if _is_building_intersect(x, y, ow, oh, object.x  - (sw - aw) // 2, object.y - (sh - ah) // 2, sw, sh) then
                            color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                        else
                            color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                        end
                    else
                        color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                    end
                else
                    color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            end
        end

        self.selection_box[object_id] = create_selection_box(
            SELECTION_BOX_MODEL,
            object.srt.t, color, iprototype.rotate_area(otypeobject.area, object.dir)
        )
    end

    for object_id, o in pairs(self.selection_box) do
        local object = assert(objects:get(object_id))
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if _is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                local sw, sh = iprototype.rotate_area(typeobject.supply_area, object.dir)
                if _is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                        local sw, sh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
                        if _is_building_intersect(x, y, ow, oh, object.x  - (sw - aw) // 2, object.y - (sh - ah) // 2, sw, sh) then
                            color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                        else
                            color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                        end
                    else
                        color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                    end
                else
                    color = COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            end
        end
        o:set_color_transition(color, 400)
    end
end

local function _get_area_coords(x, y, w, h)
    local r = {}
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            r[icoord.pack(x + i, y + j)] = true
        end
    end
    return r
end

local function _new_entity(self, datamodel, typeobject)
    local object = assert(objects:get(self.move_object_id))

    iobject.remove(self.pickup_object)
    local dir = object.dir
    local typeobject = iprototype.queryByName(typeobject.name)
    local coord = icoord.align(icamera_controller.get_screen_world_position("CENTER"), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end
    local x, y = coord[1], coord[2]
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local building_positon = icoord.position(x, y, w, h)

    local translucent_plane_color
    if not self.check_coord(x, y, dir, self.typeobject, _get_area_coords(object.x, object.y, w, h)) then
        if typeobject.supply_area then
            translucent_plane_color = COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        end
        datamodel.show_confirm = false
    else
        if typeobject.supply_area then
            translucent_plane_color = COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        end
        datamodel.show_confirm = true
    end
    datamodel.show_rotate = (typeobject.rotate_on_build == true)

    local object = assert(objects:get(self.move_object_id))
    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "translucent", color = COLOR.MOVE_SELF, emissive_color = COLOR.MOVE_SELF, render_layer = RENDER_LAYER.TRANSLUCENT_BUILDING}

    local e = assert(gameplay_core.get_entity(object.gameplay_eid))

    self.pickup_object = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        srt = srt.new {
            t = math3d.vector(building_positon),
            r = ROTATORS[dir],
        },
        group_id = 0,
    }

    if e.assembling and e.assembling.recipe ~= 0 then
        self.pickup_components.pickup_icon = create_pickup_icon(typeobject, dir, object.gameplay_eid, self.pickup_object.srt)
    end
    if e.chimney then
        self.pickup_components.fluid_indicators = create_fluid_indicators(dir, self.pickup_object.srt, typeobject)
    end
    self.pickup_components.self_selection_box = create_pickup_selection_box(self.pickup_object.srt.t, typeobject.area, dir, datamodel.show_confirm and true or false)
    _show_nearby_buildings_selection_box(self, x, y, dir, typeobject)

    if self.translucent_plane then
        self.translucent_plane:remove()
    end
    self.translucent_plane = _create_self_translucent_plane(typeobject, x, y, dir, translucent_plane_color)

    local road_entrance_position, _, _, road_entrance_dir = _get_road_entrance_position(typeobject, x, y, dir)
    if road_entrance_position then
        local srt = {t = road_entrance_position, r = ROTATORS[road_entrance_dir]}
        if datamodel.show_confirm then
            self.road_entrance = create_station_indicator(srt.t, "valid")
        else
            self.road_entrance = create_station_indicator(srt.t, "invalid")
        end
    end
end

local function __calc_grid_position(self, typeobject, dir)
    local _, originPosition = icoord.align(math3d.vector {0, 0, 0}, iprototype.rotate_area(typeobject.area, dir))
    local buildingPosition = icoord.position(self.pickup_object.x, self.pickup_object.y, iprototype.rotate_area(typeobject.area, dir))
    return math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET)
end

-- TODO: duplicate from builder.lua
local function _get_mineral_recipe(prototype_name, x, y, w, h)
    local typeobject = iprototype.queryByName(prototype_name)
    if not iprototype.has_type(typeobject.type, "mining") then
        return
    end
    local succ, mineral = imineral.can_place(x, y, w, h)
    if not succ then
        return
    end
    return iminer.get_mineral_recipe(prototype_name, mineral)
end

local function __align(object)
    assert(object)
    local typeobject = iprototype.queryByName(object.prototype_name)
    local coord, position = icoord.align(icamera_controller.get_screen_world_position("CENTER"), iprototype.rotate_area(typeobject.area, object.dir))
    if not coord then
        return object
    end

    if iprototype.has_types(typeobject.type, "station") then
        coord[1], coord[2] = icoord.road_coord(coord[1], coord[2])
        position = math3d.vector(icoord.position(coord[1], coord[2], iprototype.rotate_area(typeobject.area, object.dir)))
    end

    object.srt.t = math3d.vector(position)
    return object, coord[1], coord[2]
end

local function touch_move(self, datamodel, delta_vec)
    if not self.pickup_object then
        return
    end
    local pickup_object = self.pickup_object
    iobject.move_delta(pickup_object, delta_vec)

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
            self:rotate(datamodel, t[1], delta_vec)
        end
    end

    if self.grid_entity then
        self.grid_entity:set_position(__calc_grid_position(self, typeobject, pickup_object.dir))
    end

    local translucent_plane_color
    local offset_x, offset_y = 0, 0
    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)
    local object = assert(objects:get(self.move_object_id))

    if not self.check_coord(lx, ly, pickup_object.dir, self.typeobject, _get_area_coords(object.x, object.y, w, h)) then
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
        end
        if typeobject.supply_area then
            translucent_plane_color = COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
            local aw, ah = iprototype.rotate_area(typeobject.supply_area, pickup_object.dir)
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        end
        if self.translucent_plane then
            self.translucent_plane:move(pickup_object.x + offset_x, pickup_object.y + offset_y, translucent_plane_color)
            flush_translucent_plane()
        end
        for _, c in pairs(self.pickup_components) do
            c:on_status_change(datamodel.show_confirm)
        end
        _show_nearby_buildings_selection_box(self, x, y, pickup_object.dir, typeobject)
        return
    else
        datamodel.show_confirm = true

        if self.road_entrance then
            self.road_entrance:set_state("valid")
        end
        if typeobject.supply_area then
            translucent_plane_color = COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
            local aw, ah = iprototype.rotate_area(typeobject.supply_area, pickup_object.dir)
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        end
        if self.translucent_plane then
            self.translucent_plane:move(pickup_object.x + offset_x, pickup_object.y + offset_y, translucent_plane_color)
            flush_translucent_plane()
        end
        for _, c in pairs(self.pickup_components) do
            c:on_status_change(datamodel.show_confirm)
        end
        _show_nearby_buildings_selection_box(self, x, y, pickup_object.dir, typeobject)
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, x, y, w, h)
end

local function touch_end(self, datamodel)
    touch_move(self, datamodel, {0, 0, 0})
end

local function _get_game_object(object_id)
    local vsobject = assert(vsobject_manager:get(object_id))
    return vsobject.game_object
end

local function confirm(self, datamodel)
    ---
    local object = assert(objects:get(self.move_object_id))
    local e = gameplay_core.get_entity(object.gameplay_eid)
    e.building_changed = true
    igameplay.move(object.gameplay_eid, self.pickup_object.x, self.pickup_object.y)
    igameplay.rotate(object.gameplay_eid, self.pickup_object.dir)
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

    iobject.coord(object, self.pickup_object.x, self.pickup_object.y)
    object.dir = self.pickup_object.dir
    object.srt.r = ROTATORS[object.dir]
    objects:set(object, "CONSTRUCTED")
    objects:coord_update(object)

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    if self.translucent_plane then
        self.translucent_plane:remove()
        self.translucent_plane = nil
        flush_translucent_plane()
    end
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    datamodel.show_confirm = false
    datamodel.show_rotate = false
end

local function rotate(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)
    pickup_object.dir = iprototype.dir_tostring(dir)
    pickup_object.srt.r = ROTATORS[pickup_object.dir]

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
    local coord = icoord.align(icamera_controller.get_screen_world_position("CENTER"), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)

    local translucent_plane_color
    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)
    local object = assert(objects:get(self.move_object_id))

    if not self.check_coord(pickup_object.x, pickup_object.y, pickup_object.dir, self.typeobject, _get_area_coords(object.x, object.y, w, h)) then
        if typeobject.supply_area then
            translucent_plane_color = COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        end
        datamodel.show_confirm = false
    else
        if typeobject.supply_area then
            translucent_plane_color = COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        end
        datamodel.show_confirm = true
    end

    if self.translucent_plane then
        self.translucent_plane:remove()
    end
    self.translucent_plane = _create_self_translucent_plane(typeobject, x, y, pickup_object.dir, translucent_plane_color)
    flush_translucent_plane()

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

    datamodel.show_confirm = false
    datamodel.show_rotate = false

    for _, o in pairs(self.selection_box) do
        o:remove()
    end
    self.selection_box = {}

    for _, c in pairs(self.pickup_components) do
        c:remove()
    end

    if self.pickup_object then
        iobject.remove(self.pickup_object)
    end

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    if self.translucent_plane then
        self.translucent_plane:remove()
        self.translucent_plane = nil
        flush_translucent_plane()
    end

    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "opaque", color = "null", emissive_color = "null", render_layer = RENDER_LAYER.BUILDING}
end

local function _get_check_coord(typeobject)
    local funcs = {}
    for _, v in ipairs(typeobject.check_coord) do
        funcs[#funcs+1] = ecs.require(("editor.rules.check_coord.%s"):format(v))
    end
    return function(...)
        for _, v in ipairs(funcs) do
            local succ, reason = v(...)
            if not succ then
                return succ, reason
            end
        end
        return true
    end
end

local function new(self, move_object_id, datamodel, typeobject)
    self.move_object_id = move_object_id
    self.typeobject = typeobject
    self.check_coord = _get_check_coord(typeobject)

    _new_entity(self, datamodel, typeobject)

    if not self.grid_entity then
        if iprototype.has_types(typeobject.type, "station") then
            self.grid_entity = igrid_entity.create(MAP_WIDTH_COUNT // ROAD_WIDTH_COUNT, MAP_HEIGHT_COUNT // ROAD_HEIGHT_COUNT, ROAD_WIDTH_SIZE, ROAD_HEIGHT_SIZE, {t = __calc_grid_position(self, typeobject, self.pickup_object.dir)})
        else
            self.grid_entity = igrid_entity.create(MAP_WIDTH_COUNT, MAP_HEIGHT_COUNT, TILE_SIZE, TILE_SIZE, {t = __calc_grid_position(self, typeobject, self.pickup_object.dir)})
        end
    end
end

local function build(self, v)
    error("not implement")
end

local function create()
    local m = {}
    m.new = new
    m.touch_move = touch_move
    m.touch_end = touch_end
    m.confirm = confirm
    m.rotate = rotate
    m.clean = clean
    m.build = build
    m.pickup_components = {}
    m.selection_box = {}
    m.continue_construct = false
    m.CONFIRM_EXIT = true
    return m
end
return create