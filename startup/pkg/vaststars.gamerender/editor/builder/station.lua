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
local COLOR <const> = ecs.require "vaststars.prototype|color"
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local GRID_POSITION_OFFSET <const> = CONSTANT.GRID_POSITION_OFFSET
local BUILDING_EFK_SCALE <const> = CONSTANT.BUILDING_EFK_SCALE
local SELECTION_BOX_MODEL <const> = ecs.require "vaststars.prototype|selection_box_model"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local math3d = require "math3d"
local COLOR_GREEN <const> = math3d.constant("v4", {0.3, 1, 0, 1})
local COLOR_RED <const> = math3d.constant("v4", {1, 0.03, 0, 1})

local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.require "engine.system.camera_controller"
local objects = require "objects"
local iobject = ecs.require "object"
local igrid_entity = ecs.require "engine.grid_entity"
local create_station_indicator = ecs.require "editor.indicators.station_indicator"
local create_selection_box = ecs.require "selection_box"
local icoord = require "coord"
local gameplay_core = require "gameplay.core"
local iinventory = require "gameplay.interface.inventory"
local srt = require "utility.srt"
local igameplay = ecs.require "gameplay.gameplay_system"
local ibuilding = ecs.require "render_updates.building"
local prefab_slots = require("engine.prefab_parser").slots
local show_message = ecs.require "show_message".show_message
local get_check_coord = ecs.require "editor.builder.common".get_check_coord
local igame_object = ecs.require "engine.game_object"
local iefk = ecs.require "engine.system.efk"
local vsobject_manager = ecs.require "vsobject_manager"

local function _get_road_entrance_srt(typeobject, building_srt)
    local slots = prefab_slots(typeobject.model)
    local slot_srt = slots["slot_indicator"].scene

    local mat = math3d.mul(math3d.matrix(building_srt), math3d.matrix(slot_srt))
    local s, r, t = math3d.srt(mat)
    return srt.new {s = s, r = r, t = t}
end

local function _align(position, area, dir)
    local w, h = iprototype.rotate_area(area, dir)
    local coord = icoord.align(position, w, h)
    if not coord then
        return
    end
    coord[1], coord[2] = icoord.road_coord(coord[1], coord[2])
    local t = math3d.vector(icoord.position(coord[1], coord[2], w, h))
    return t, coord[1], coord[2]
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
    local nearby_buldings = _get_nearby_buildings(x, y, iprototype.rotate_area(typeobject.area, dir))
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

local function _new_entity(self, datamodel, typeobject, x, y, dir)
    local status = assert(self.status)

    if not self.check_coord(x, y, dir, self.typeobject) then
        datamodel.show_confirm = false
        datamodel.show_rotate = true
    else
        datamodel.show_confirm = true
        datamodel.show_rotate = true
    end

    _show_nearby_buildings_selection_box(self, x, y, dir, typeobject)

    local srt = _get_road_entrance_srt(typeobject, status.srt)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local self_selection_box_position = icoord.position(x, y, w, h)
    if srt then
        if datamodel.show_confirm then
            if not self.road_entrance then
                self.road_entrance = create_station_indicator(srt.t, "valid")
            else
                self.road_entrance:set_state("valid")
            end
            if not self.self_selection_box then
                self.self_selection_box = create_selection_box(SELECTION_BOX_MODEL, self_selection_box_position, COLOR_GREEN, w, h)
            end
        else
            if not self.road_entrance then
                self.road_entrance = create_station_indicator(srt.t, "invalid")
            else
                self.road_entrance:set_state("invalid")
            end
            if not self.self_selection_box then
                self.self_selection_box = create_selection_box(SELECTION_BOX_MODEL, self_selection_box_position, COLOR_RED, w, h)
            end
        end
    end
end

local function rotate(self, datamodel, dir)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    dir = dir or iprototype.rotate_dir_times(status.dir, -1)

    status.dir = iprototype.dir_tostring(dir)
    status.srt.r = ROTATORS[status.dir]

    indicator:send("obj_motion", "set_rotation", math3d.live(status.srt.r))

    local srt = _get_road_entrance_srt(typeobject, status.srt)
    if srt then
        self.road_entrance:set_srt(srt.s, srt.r, srt.t)
    end

    local x, y
    local position = icamera_controller.get_screen_world_position(self.position_type)
    position, x, y = _align(position, typeobject.area, status.dir)
    if not position then
        return
    end

    if not self.check_coord(x, y, status.dir, typeobject) then
        datamodel.show_confirm = false
        if self.road_entrance then
            self.road_entrance:set_state("invalid")
            self.self_selection_box:set_color(COLOR_RED)
        end
    else
        datamodel.show_confirm = true
        if self.road_entrance then
            self.road_entrance:set_state("valid")
            self.self_selection_box:set_color(COLOR_GREEN)
        end
    end

    status.x, status.y = x, y
    status.srt.t = position

    local srt= assert(_get_road_entrance_srt(typeobject, status.srt))
    self.road_entrance:set_srt(srt.s, srt.r, srt.t)

    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local self_selection_box_position = icoord.position(status.x, status.y, w, h)
    self.self_selection_box:set_position(self_selection_box_position)
    self.self_selection_box:set_wh(w, h)
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

local function _touch_end(self, datamodel)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    local x, y
    local position = icamera_controller.get_screen_world_position(self.position_type)
    position, x, y = _align(position, typeobject.area, status.dir)
    if not position then
        return
    end
    status.x, status.y = x, y
    status.srt.t = position

    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    local srt= assert(_get_road_entrance_srt(typeobject, status.srt))
    self.road_entrance:set_srt(srt.s, srt.r, srt.t)

    local w, h = iprototype.rotate_area(typeobject.area, status.dir)
    local self_selection_box_position = icoord.position(status.x, status.y, w, h)
    self.self_selection_box:set_position(self_selection_box_position)
    self.self_selection_box:set_wh(w, h)
end

local function touch_move(self, datamodel, delta_vec)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    status.srt.t = math3d.add(status.srt.t, delta_vec)
    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    self.grid_entity:on_position_change(status.srt, status.dir)

    local srt = _get_road_entrance_srt(typeobject, status.srt)
    assert(srt)
    self.road_entrance:set_srt(srt.s, srt.r, srt.t)

    local x, y
    local position = icamera_controller.get_screen_world_position(self.position_type)
    position, x, y = _align(position, typeobject.area, status.dir)

    local w, h = iprototype.rotate_area(typeobject.area, status.dir)
    local self_selection_box_position = icoord.position(x, y, w, h)
    self.self_selection_box:set_position(self_selection_box_position)
    self.self_selection_box:set_wh(w, h)

    _show_nearby_buildings_selection_box(self, x, y, status.dir, typeobject)

    local dx, dy = icoord.road_coord(x, y)
    if x == dx and y == dy then
        local dir = _calc_dir(self.adjacent_coords, x, y, status.dir)
        if dir and dir ~= status.dir then
            self:rotate(datamodel, dir)
        end
    end
end

local function touch_end(self, datamodel)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    _touch_end(self, datamodel)
    if not self.check_coord(status.x, status.y, status.dir, typeobject) then
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
            self.self_selection_box:set_color(COLOR_RED)
        end
    else
        datamodel.show_confirm = true

        if self.road_entrance then
            self.road_entrance:set_state("valid")
            self.self_selection_box:set_color(COLOR_GREEN)
        end
    end
end

local function confirm(self, datamodel)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    local succ, errmsg = self.check_coord(status.x, status.y, status.dir, typeobject)
    if not succ then
        show_message(errmsg)
        return
    end

    local gameplay_world = gameplay_core.get_world()
    if iinventory.query(gameplay_world, typeobject.id) < 1 then
        show_message("item not enough")
        return
    end
    assert(iinventory.pickup(gameplay_world, typeobject.id, 1))

    indicator:modifier({name = "confirm"}, true)

    local w, h = iprototype.unpackarea(typeobject.area) -- Note: No need to rotate based on direction here
    local scale = assert(BUILDING_EFK_SCALE[w.."x"..h])
    iefk.play("/pkg/vaststars.resources/effects/building-animat.efk", {s = scale, t = status.srt.t})

    datamodel.show_confirm = false
    datamodel.show_rotate = false

    local object = iobject.new {
        prototype_name = typeobject.name,
        dir = status.dir,
        x = status.x,
        y = status.y,
        srt = srt.new(status.srt),
    }
    object.gameplay_eid = igameplay.create_entity(object)
    objects:set(object, "CONSTRUCTED")
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

    _new_entity(self, datamodel, typeobject, status.x, status.y, status.dir)
end

local function clean(self, datamodel)
    self.grid_entity:remove()

    for _, o in pairs(self.selection_box) do
        o:remove()
    end
    self.selection_box = {}

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    if self.indicator then
        self.indicator:remove()
    end

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
        self.self_selection_box:remove()
        self.self_selection_box = nil
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
                table.insert(t, {x, y, iprototype.dir_tostring(iprototype.rotate_dir(typeobject.road_adjacent_dir, 'N'))})
            end
        end
        -- right
        for x = w, w, ROAD_WIDTH_COUNT do
            for y = 0, h - 1, ROAD_HEIGHT_COUNT do
                table.insert(t, {x, y, iprototype.dir_tostring(iprototype.rotate_dir(typeobject.road_adjacent_dir, 'E'))})
            end
        end
        -- bottom
        for x = 0, w - 1, ROAD_WIDTH_COUNT do
            for y = h, h, ROAD_HEIGHT_COUNT do
                table.insert(t, {x, y, iprototype.dir_tostring(iprototype.rotate_dir(typeobject.road_adjacent_dir, 'S'))})
            end
        end
        -- left
        for x = -2, -2, -ROAD_WIDTH_COUNT do
            for y = 0, h - 1, ROAD_HEIGHT_COUNT do
                table.insert(t, {x, y, iprototype.dir_tostring(iprototype.rotate_dir(typeobject.road_adjacent_dir, 'W'))})
            end
        end

        r[dir] = t
    end
    return r
end

local function _create_grid_entity(status, position_type, dir)
    local position = _align(status.srt.t, iprototype.packarea(8 * ROAD_WIDTH_COUNT, 8 * ROAD_HEIGHT_COUNT), dir)
    position = math3d.add(position, GRID_POSITION_OFFSET)
    local offset = math3d.sub(status.srt.t, position)
    return igrid_entity.create(
        MAP_WIDTH_COUNT // ROAD_WIDTH_COUNT,
        MAP_HEIGHT_COUNT // ROAD_HEIGHT_COUNT,
        ROAD_WIDTH_SIZE,
        ROAD_HEIGHT_SIZE,
        {t = position},
        offset,
        nil,
        position_type
    )
end

local function new(self, datamodel, typeobject, position_type, continuity)
    self.typeobject = typeobject
    self.position_type = position_type
    self.continuity = continuity
    self.check_coord = get_check_coord(typeobject)
    self.adjacent_coords = _get_adjacent_coords(typeobject)

    local dir = DEFAULT_DIR
    local x, y
    local position = icamera_controller.get_screen_world_position(self.position_type)
    position, x, y = _align(position, typeobject.area, dir)
    if not position then
        return
    end

    self.status = {
        x = x,
        y = y,
        dir = dir,
        srt = srt.new {
            t = position,
            r = ROTATORS[dir],
        },
    }

    local status = self.status
    self.indicator = igame_object.create {
        prefab = typeobject.model,
        srt = status.srt,
    }
    self.grid_entity = _create_grid_entity(status, position_type, dir)

    _new_entity(self, datamodel, typeobject, x, y, dir)
end

local function build(self, v)
    igameplay.create_entity(v)
end

local function set_continuity(self, continuity)
    self.continuity = continuity
end

local build_t = {}
build_t.new = new
build_t.touch_move = touch_move
build_t.touch_end = touch_end
build_t.confirm = confirm
build_t.rotate = rotate
build_t.clean = clean
build_t.build = build
build_t.set_continuity = set_continuity
local build_mt = {__index = build_t}

local move_t = {}
move_t.touch_move = touch_move
move_t.touch_end = touch_end
move_t.confirm = confirm
move_t.rotate = rotate
move_t.clean = clean

local function _get_exclude_coords(x, y, w, h)
    local r = {}
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            r[icoord.pack(x + i, y + j)] = true
        end
    end
    return r
end

function move_t:new(move_object_id, datamodel, typeobject)
    new(self, datamodel, typeobject, "CENTER", false)

    self.move_object_id = move_object_id
    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "translucent", color = COLOR.MOVE_SELF, emissive_color = COLOR.MOVE_SELF, render_layer = RENDER_LAYER.TRANSLUCENT_BUILDING}
end
function move_t:confirm(datamodel)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    local succ, errmsg = self.check_coord(status.x, status.y, status.dir, typeobject, _get_exclude_coords(status.x, status.y, iprototype.unpackarea(typeobject.area)))
    if not succ then
        show_message(errmsg)
        return
    end

    local object = assert(objects:get(self.move_object_id))
    local e = gameplay_core.get_entity(object.gameplay_eid)
    e.building_changed = true
    igameplay.move(object.gameplay_eid, self.status.x, self.status.y)
    igameplay.rotate(object.gameplay_eid, self.status.dir)
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

    iobject.coord(object, self.status.x, self.status.y)
    object.dir = self.status.dir
    object.srt.r = ROTATORS[object.dir]
    objects:set(object, "CONSTRUCTED")
    objects:coord_update(object)
end
function move_t:touch_end(datamodel)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    _touch_end(self, datamodel)
    if not self.check_coord(status.x, status.y, status.dir, typeobject, _get_exclude_coords(status.x, status.y, iprototype.unpackarea(typeobject.area))) then
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
            self.self_selection_box:set_color(COLOR_RED)
        end
    else
        datamodel.show_confirm = true

        if self.road_entrance then
            self.road_entrance:set_state("valid")
            self.self_selection_box:set_color(COLOR_GREEN)
        end
    end
end
function move_t:clean(datamodel)
    clean(self, datamodel)
    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "opaque", color = "null", emissive_color = "null", render_layer = RENDER_LAYER.BUILDING}
end
local move_mt = {__index = move_t}

local function create(t)
    local v = {continuity = true, selection_box = {}, status = {}}
    if t == "build" then
        return setmetatable(v, build_mt)
    elseif t == "move" then
        return setmetatable(v, move_mt)
    else
        assert(false)
    end
end
return create