local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ALL_DIR <const> = CONSTANT.ALL_DIR
local ROTATORS <const> = CONSTANT.ROTATORS
local ROAD_WIDTH_COUNT <const> = CONSTANT.ROAD_WIDTH_COUNT
local ROAD_HEIGHT_COUNT <const> = CONSTANT.ROAD_HEIGHT_COUNT
local ROAD_WIDTH_SIZE <const> = CONSTANT.ROAD_WIDTH_SIZE
local ROAD_HEIGHT_SIZE <const> = CONSTANT.ROAD_HEIGHT_SIZE
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local GRID_POSITION_OFFSET <const> = CONSTANT.GRID_POSITION_OFFSET

local math3d = require "math3d"
local COLOR_GREEN <const> = math3d.constant("v4", {0.3, 1, 0, 1})
local COLOR_RED <const> = math3d.constant("v4", {1, 0.03, 0, 1})

local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.require "engine.system.camera_controller"
local objects = require "objects"
local iobject = ecs.require "object"
local igrid_entity = ecs.require "engine.grid_entity"
local create_station_indicator = ecs.require "editor.indicators.station_indicator"
local create_selected_boxes = ecs.require "selected_boxes"
local icoord = require "coord"
local gameplay_core = require "gameplay.core"
local iinventory = require "gameplay.interface.inventory"
local srt = require "utility.srt"
local igameplay = ecs.require "gameplay.gameplay_system"
local ibuilding = ecs.require "render_updates.building"
local prefab_slots = require("engine.prefab_parser").slots
local show_message = ecs.require "show_message".show_message
local get_check_coord = ecs.require "editor.builder.common".get_check_coord

local function _get_road_entrance_srt(typeobject, building_srt)
    local slots = prefab_slots(typeobject.model)
    local slot_srt = slots["slot_indicator"].scene

    local mat = math3d.mul(math3d.matrix(building_srt), math3d.matrix(slot_srt))
    local s, r, t = math3d.srt(mat)
    return srt.new {s = s, r = r, t = t}
end

local function _align(w, h, position_type)
    local pos = icamera_controller.get_screen_world_position(position_type)
    local coord, position = icoord.align(pos, w, h)
    if not coord then
        return
    end
    coord[1], coord[2] = icoord.road_coord(coord[1], coord[2])
    position = math3d.vector(icoord.position(coord[1], coord[2], w, h))

    return position, coord[1], coord[2]
end

local function _get_nearby_buldings(x, y, w, h)
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

local function _show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)
    local nearby_buldings = _get_nearby_buldings(x, y, iprototype.rotate_area(typeobject.area, dir))
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    local redraw = {}
    for object_id, object in pairs(nearby_buldings) do
        if not self.selected_boxes[object_id] then
            redraw[object_id] = object
        end
    end

    for object_id, o in pairs(self.selected_boxes) do
        if not nearby_buldings[object_id] then
            o:remove()
            self.selected_boxes[object_id] = nil
        end
    end

    for object_id, object in pairs(redraw) do
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if _is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                local sw, sh = iprototype.rotate_area(typeobject.supply_area, object.dir)
                if _is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                        local sw, sh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
                        if _is_building_intersect(x, y, ow, oh, object.x  - (sw - aw) // 2, object.y - (sh - ah) // 2, sw, sh) then
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

        self.selected_boxes[object_id] = create_selected_boxes(
            {
                "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
            },
            object.srt.t, color, iprototype.rotate_area(otypeobject.area, object.dir)
        )
    end

    for object_id, o in pairs(self.selected_boxes) do
        local object = assert(objects:get(object_id))
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if _is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                local sw, sh = iprototype.rotate_area(typeobject.supply_area, object.dir)
                if _is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                        local sw, sh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
                        if _is_building_intersect(x, y, ow, oh, object.x  - (sw - aw) // 2, object.y - (sh - ah) // 2, sw, sh) then
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
        o:set_color_transition(color, 400)
    end
end

local function _new_entity(self, datamodel, typeobject, x, y, position, dir)
    iobject.remove(self.pickup_object)
    if not self._check_coord(x, y, dir, self.typeobject) then
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    self.pickup_object = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        srt = srt.new {
            t = position,
            r = ROTATORS[dir],
        },
        group_id = 0,
    }

    _show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)

    local srt = _get_road_entrance_srt(typeobject, self.pickup_object.srt)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local self_selected_boxes_position = icoord.position(x, y, w, h)
    if srt then
        if datamodel.show_confirm then
            if not self.road_entrance then
                self.road_entrance = create_station_indicator(srt.t, "valid")
            else
                self.road_entrance:set_state("valid")
            end
            if not self.self_selected_boxes then
                self.self_selected_boxes = create_selected_boxes({
                    "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                    "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab"
                }, self_selected_boxes_position, COLOR_GREEN, w, h)
            end
        else
            if not self.road_entrance then
                self.road_entrance = create_station_indicator(srt.t, "invalid")
            else
                self.road_entrance:set_state("invalid")
            end
            if not self.self_selected_boxes then
                self.self_selected_boxes = create_selected_boxes({
                    "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                    "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab"
                }, self_selected_boxes_position, COLOR_RED, w, h)
            end
        end
    end
end

local function _calc_grid_position(typeobject, x, y, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local _, originPosition = icoord.align(math3d.vector {10, 0, -10}, w, h) -- TODO: remove hardcode
    local x, y = icoord.road_coord(x, y)
    local buildingPosition = icoord.position(x, y, w, h)
    return math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET)
end

local function rotate(self, datamodel, dir)
    local pickup_object = assert(self.pickup_object)

    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    pickup_object.dir = iprototype.dir_tostring(dir)
    pickup_object.srt.r = ROTATORS[pickup_object.dir]

    local srt = _get_road_entrance_srt(typeobject, pickup_object.srt)
    if srt then
        self.road_entrance:set_srt(srt.s, srt.r, srt.t)
    end

    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)
    local position, x, y = _align(w, h, self.position_type)
    if not position then
        return
    end
    pickup_object.x, pickup_object.y = x, y
    pickup_object.srt.t = position

    local self_selected_boxes_position = icoord.position(pickup_object.x, pickup_object.y, w, h)
    self.self_selected_boxes:set_position(self_selected_boxes_position)
    self.self_selected_boxes:set_wh(w, h)
end

local function _calc_dir(adjacent_coords, x, y, dir)
    local t = {}
    for _, v in ipairs(adjacent_coords[dir]) do
        local dx, dy, ddir = v[1], v[2], v[3]
        if ibuilding.get(x + dx, y + dy) then
            t[ddir] = true
        end
    end
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end
    if c == 1 then
        return next(t)
    end
    return nil
end

local function touch_move(self, datamodel, delta_vec)
    local pickup_object = assert(self.pickup_object)
    iobject.move_delta(pickup_object, delta_vec)
    local typeobject = iprototype.queryByName(pickup_object.prototype_name)

    if self.grid_entity then
        self.grid_entity:set_position(_calc_grid_position(typeobject, pickup_object.x, pickup_object.y, pickup_object.dir))
    end

    local srt = _get_road_entrance_srt(typeobject, pickup_object.srt)
    assert(srt)
    self.road_entrance:set_srt(srt.s, srt.r, srt.t)

    local w, h = iprototype.rotate_area(self.typeobject.area, pickup_object.dir)
    local position, x, y = _align(w, h, self.position_type)
    if position then
        local self_selected_boxes_position = icoord.position(x, y, w, h)
        self.self_selected_boxes:set_position(self_selected_boxes_position)
        self.self_selected_boxes:set_wh(w, h)
    end

    _show_nearby_buildings_selected_boxes(self, x, y, pickup_object.dir, typeobject)

    local dx, dy = icoord.road_coord(x, y)
    if x == dx and y == dy and self._check_coord(x, y, pickup_object.dir, self.typeobject) then
        local dir = _calc_dir(self._adjacent_coords, x, y, pickup_object.dir)
        if dir and dir ~= pickup_object.dir then
            self:rotate(datamodel, dir)
        end
    end
end

local function touch_end(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local w, h = iprototype.rotate_area(self.typeobject.area, pickup_object.dir)
    local position, x, y = _align(w, h, self.position_type)
    if not position then
        return
    end
    pickup_object.x, pickup_object.y = x, y
    pickup_object.srt.t = position

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)

    if not self._check_coord(x, y, pickup_object.dir, self.typeobject) then
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
            self.self_selected_boxes:set_color(COLOR_RED)
        end
    else
        datamodel.show_confirm = true

        if self.road_entrance then
            self.road_entrance:set_state("valid")
            self.self_selected_boxes:set_color(COLOR_GREEN)
        end
    end

    local srt= _get_road_entrance_srt(typeobject, self.pickup_object.srt)
    assert(srt)
    self.road_entrance:set_srt(srt.s, srt.r, srt.t)

    local self_selected_boxes_position = icoord.position(pickup_object.x, pickup_object.y, w, h)
    self.self_selected_boxes:set_position(self_selected_boxes_position)
    self.self_selected_boxes:set_wh(w, h)
end

local function complete(object_id)
    assert(object_id)
    local object = objects:get(object_id, {"CONFIRM"})
    local old = objects:get(object_id, {"CONSTRUCTED"})
    if not old then
        object.gameplay_eid = igameplay.create_entity(object)
    else
        if old.prototype_name ~= object.prototype_name then
            igameplay.destroy_entity(object.gameplay_eid)
            object.gameplay_eid = igameplay.create_entity(object)
        elseif old.dir ~= object.dir then
            igameplay.rotate(object.gameplay_eid, object.dir)
        end
    end

    objects:remove(object_id, "CONFIRM")
    objects:set(object, "CONSTRUCTED")
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)
end

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local succ = self._check_coord(pickup_object.x, pickup_object.y, pickup_object.dir, self.typeobject)
    if not succ then
        log.info("can not construct") --TODO: show error message
        return
    end

    local gameplay_world = gameplay_core.get_world()
    if iinventory.query(gameplay_world, self.typeobject.id) < 1 then
        show_message("item not enough")
        return
    end
    assert(iinventory.pickup(gameplay_world, self.typeobject.id, 1))

    objects:set(pickup_object, "CONFIRM")
    pickup_object.PREPARE = true

    datamodel.show_confirm = false
    datamodel.show_rotate = false

    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    complete(pickup_object.id)

    local position, dir = pickup_object.srt.t, pickup_object.dir
    self.pickup_object = nil

    _new_entity(self, datamodel, self.typeobject, pickup_object.x, pickup_object.y, position, dir)
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    for _, o in pairs(self.selected_boxes) do
        o:remove()
    end
    self.selected_boxes = {}

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    if self.pickup_object then
        iobject.remove(self.pickup_object)
    end

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
        self.self_selected_boxes:remove()
        self.self_selected_boxes = nil
    end
end

-- 
local function _get_adjacent_coords(typeobject)
    local r = {}
    for _, dir in ipairs(ALL_DIR) do
        local t = {}
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        assert(w % 2 == 0 and h % 2 == 0)

        -- top
        for x = 0, w - 1, ROAD_WIDTH_COUNT do
            for y = -2, -2, -ROAD_HEIGHT_COUNT do
                table.insert(t, {x, y, iprototype.dir_tostring(iprototype.rotate_dir(typeobject.road_dir, 'N'))})
            end
        end
        -- right
        for x = w, w, ROAD_WIDTH_COUNT do
            for y = 0, h - 1, ROAD_HEIGHT_COUNT do
                table.insert(t, {x, y, iprototype.dir_tostring(iprototype.rotate_dir(typeobject.road_dir, 'E'))})
            end
        end
        -- bottom
        for x = 0, w - 1, ROAD_WIDTH_COUNT do
            for y = h, h, ROAD_HEIGHT_COUNT do
                table.insert(t, {x, y, iprototype.dir_tostring(iprototype.rotate_dir(typeobject.road_dir, 'S'))})
            end
        end
        -- left
        for x = -2, -2, -ROAD_WIDTH_COUNT do
            for y = 0, h - 1, ROAD_HEIGHT_COUNT do
                table.insert(t, {x, y, iprototype.dir_tostring(iprototype.rotate_dir(typeobject.road_dir, 'W'))})
            end
        end

        r[dir] = t
    end
    return r
end

local function new(self, datamodel, typeobject, position_type)
    self._check_coord = get_check_coord(typeobject)
    self._adjacent_coords = _get_adjacent_coords(typeobject)

    self.typeobject = typeobject
    self.position_type = position_type

    local dir = DEFAULT_DIR
    local w, h = iprototype.rotate_area(self.typeobject.area, dir)
    local position, x, y = _align(w, h, position_type)
    if not x or not y then
        return
    end

    _new_entity(self, datamodel, typeobject, x, y, position, dir)

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create(MAP_WIDTH_COUNT // ROAD_WIDTH_COUNT, MAP_HEIGHT_COUNT // ROAD_HEIGHT_COUNT, ROAD_WIDTH_SIZE, ROAD_HEIGHT_SIZE, {t = _calc_grid_position(typeobject, self.pickup_object.x, self.pickup_object.y, self.pickup_object.dir)})
    end
end

local function build(self, v)
    igameplay.create_entity(v)
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
    m.selected_boxes = {}
    return m
end
return create