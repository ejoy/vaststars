local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.interface "icamera_controller"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local DEFAULT_DIR <const> = 'N'
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local iconstant = require "gameplay.interface.constant"
local coord_system = ecs.require "terrain"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ALL_DIR = iconstant.ALL_DIR
local igrid_entity = ecs.require "engine.grid_entity"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"
local create_selected_boxes = ecs.require "selected_boxes"
local icanvas = ecs.require "engine.canvas"
local datalist = require "datalist"
local fs = require "filesystem"
local road_entrance_marker_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/road_entrance_marker_canvas.cfg")):read "a")
local math3d = require "math3d"
local iroadnet_converter = require "roadnet_converter"
local COLOR_GREEN = math3d.constant("v4", {0.3, 1, 0, 1})
local COLOR_RED = math3d.constant("v4", {1, 0.03, 0, 1})
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local ichest = require "gameplay.interface.chest"
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local gameplay = import_package "vaststars.gameplay"
local iroad = gameplay.interface "road"
local ROAD_TILE_SCALE_WIDTH <const> = 2
local ROAD_TILE_SCALE_HEIGHT <const> = 2
local SPRITE_COLOR = import_package "vaststars.prototype".load("sprite_color")

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

local function __rotate_connection_direction(position, direction, area)
    local dir = iprototype.rotate_dir(position[3], direction)

    if dir == 'N' then
        return 0, 1, dir
    elseif dir == 'E' then
        return 1, 0, dir
    elseif dir == 'S' then
        return 0, -1, dir
    elseif dir == 'W' then
        return -1, 0, dir
    end
end

local function _get_road_entrance_position(typeobject, dir, position)
    if not typeobject.crossing then
        return
    end

    local conn  = typeobject.crossing.connections[1]
    local ox, oy, ddir = __rotate_connection_direction(conn.position, dir, typeobject.area)
    return math3d.ref(math3d.add(position, {ox * coord_system.tile_size / 2, 0, oy * coord_system.tile_size / 2})), ddir
end

local function __align(prototype_name, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local coord, position = coord_system:align(icamera_controller.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end
    coord[1], coord[2] = coord[1] - (coord[1] % ROAD_TILE_SCALE_WIDTH), coord[2] - (coord[2] % ROAD_TILE_SCALE_HEIGHT)
    position = math3d.ref(math3d.vector(coord_system:get_position_by_coord(coord[1], coord[2], iprototype.rotate_area(typeobject.area, dir))))

    return position, coord[1], coord[2]
end


local function __get_nearby_buldings(x, y, w, h)
    local r = {}
    local begin_x, begin_y = coord_system:bound_coord(x - ((10 - w) // 2), y - ((10 - h) // 2))
    local end_x, end_y = coord_system:bound_coord(x + ((10 - w) // 2) + w, y + ((10 - h) // 2) + h)
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
    local nearby_buldings = __get_nearby_buldings(x, y, iprototype.unpackarea(typeobject.area))
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    local redraw = {}
    for object_id, object in pairs(nearby_buldings) do
        redraw[object_id] = object
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
                if iprototype.has_type(typeobject.type, "station") then
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
            if iprototype.has_type(typeobject.type, "station") then
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
        o:set_color(color)
    end
end

local function __new_entity(self, datamodel, typeobject)
    iobject.remove(self.pickup_object)
    local dir = DEFAULT_DIR
    local position, x, y = __align(typeobject.name, dir)
    if not x or not y then
        return
    end

    if not self:check_construct_detector(typeobject.name, x, y, dir) then
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
        srt = {
            t = math3d.ref(math3d.vector(position)),
            r = ROTATORS[dir],
        },
        fluid_name = "",
        group_id = 0,
    }

    __show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)

    local road_entrance_position, road_entrance_dir = _get_road_entrance_position(typeobject, dir, self.pickup_object.srt.t)
    local w, h = iprototype.unpackarea(typeobject.area)
    local self_selected_boxes_position = coord_system:get_position_by_coord(x, y, w, h)
    if road_entrance_position then
        local srt = {t = road_entrance_position, r = ROTATORS[road_entrance_dir]}
        if datamodel.show_confirm then
            if not self.road_entrance then
                self.road_entrance = create_road_entrance(srt, "valid")
            else
                self.road_entrance:set_state("valid")
            end
            if not self.self_selected_boxes then
                self.self_selected_boxes = create_selected_boxes({
                    "/pkg/vaststars.resources/prefabs/selected-box-no-animation.prefab",
                    "/pkg/vaststars.resources/prefabs/selected-box-no-animation-line.prefab"
                }, self_selected_boxes_position, COLOR_GREEN, w+1, h+1)
            end
        else
            if not self.road_entrance then
                self.road_entrance = create_road_entrance(srt, "invalid")
            else
                self.road_entrance:set_state("invalid")
            end
            if not self.self_selected_boxes then
                self.self_selected_boxes = create_selected_boxes({
                    "/pkg/vaststars.resources/prefabs/selected-box-no-animation.prefab",
                    "/pkg/vaststars.resources/prefabs/selected-box-no-animation-line.prefab"
                }, self_selected_boxes_position, COLOR_RED, w, h)
            end
        end
    end
end

local function _get_connections_dir(prototype_name, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local r = {}
    if not typeobject.crossing then
        return r
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local _, _, ddir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
        r[ddir] = true
    end
    return r
end

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local iterrain = ecs.require "terrain"
local dir_move_delta = {
    ['N'] = {x = 0,  y = 1},
    ['E'] = {x = 1,  y = 0},
    ['S'] = {x = 0,  y = -1},
    ['W'] = {x = -1, y = 0},
}

local function _get_rect(x, y, icon_w, icon_h)
    local max = math.max(icon_h, icon_w)
    local draw_w = iterrain.tile_size * (icon_w / max)
    local draw_h = iterrain.tile_size * (icon_h / max)
    local draw_x = x + (iterrain.tile_size - draw_w) / 2
    local draw_y = y + (iterrain.tile_size - draw_h) / 2
    return draw_x, draw_y, draw_w, draw_h
end

local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS

local function __show_road_entrance_marker(self, typeobject)
    local function _get_road_entrance_offset(typeobject, dir)
        if not typeobject.crossing then
            return
        end
        local conn = assert(typeobject.crossing.connections[1])
        local dx, dy = iprototype.rotate_connection(conn.position, dir, typeobject.area)
        return dx, dy
    end

    local offset = {}
    for _, d in ipairs(ALL_DIR) do
        local dx, dy = _get_road_entrance_offset(typeobject, d)
        offset[d] = {dx, dy}
    end

    local coords = {}
    for coord, mask in pairs(iroad.all(gameplay_core.get_world())) do
        local x, y = iprototype.unpackcoord(coord)
        local prototype_name, dir = iroadnet_converter.mask_to_prototype_name_dir(mask)
        local dirs = _get_connections_dir(prototype_name, dir)
        for _, d in ipairs(ALL_DIR) do
            if dirs[d] then
                goto continue
            end

            local succ, dx, dy = coord_system:move_coord(x, y, d, ROAD_TILE_SCALE_WIDTH, ROAD_TILE_SCALE_HEIGHT)
            if not succ then
                goto continue
            end

            local bx, by = dx - offset[d][1], dy - offset[d][2]
            -- if not self:check_construct_detector(typeobject.name, bx, by, d) then
            --     goto continue
            -- end

            coords[#coords+1] = {x = dx, y = dy, dir = d, sx = x, sy = y}
            ::continue::
        end
    end

    local pr
    if self.last_position then
        pr = {math3d.index(self.last_position, 1), 0, math3d.index(self.last_position, 3)}
    else
        pr = {math3d.index(self.pickup_object.srt.t, 1), 0, math3d.index(self.pickup_object.srt.t, 3)}
    end

    local min_dist
    local min_coord
    for _, c in ipairs(coords) do
        local position = coord_system:get_position_by_coord(c.x, c.y, 1, 1)
        local delta = dir_move_delta[iprototype.reverse_dir(c.dir)]

        position[1] = position[1] + (delta.x * (iterrain.tile_size / 2))
        position[3] = position[3] + (delta.y * (iterrain.tile_size / 2))

        local dist = math.abs(position[1] - pr[1]) + math.abs(position[3] - pr[3])
        if not min_dist then
            min_dist = dist
            min_coord = c
        else
            if dist < min_dist then
                min_dist = dist
                min_coord = c
            end
        end
    end

    local markers = {}
    for _, coord in ipairs(coords) do
        local position = coord_system:get_begin_position_by_coord(coord.x, coord.y, 1, 1)
        local delta = dir_move_delta[iprototype.reverse_dir(coord.dir)]

        position[1] = position[1] + (delta.x * (iterrain.tile_size / 2))
        position[3] = position[3] + (delta.y * (iterrain.tile_size / 2))

        local cfg
        if coord.x == min_coord.x and coord.y == min_coord.y and coord.dir == min_coord.dir then
            cfg = road_entrance_marker_canvas_cfg["white"]
        else
            cfg = road_entrance_marker_canvas_cfg["green"]
        end

        local x, y, w, h = _get_rect(position[1], position[3] - iterrain.tile_size, cfg.width, cfg.height)
        markers[#markers+1] = {
            texture = {
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = {r = ROTATORS[coord.dir]},
        }
    end

    local t = {
        "/pkg/vaststars.resources/materials/road_entrance_marker_canvas.material",
        RENDER_LAYER.ICON_CONTENT,
        table.unpack(markers)
    }

    -- icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
    -- icanvas.add_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0, table.unpack(t))
    return min_coord
end

local function __calc_grid_position(typeobject, x, y)
    local w, h = iprototype.unpackarea(typeobject.area)
    local _, originPosition = coord_system:align(math3d.vector {10, 0, -10}, w, h) -- TODO: remove hardcode
    local buildingPosition = coord_system:get_position_by_coord(x - (x % ROAD_TILE_SCALE_WIDTH), y - (y % ROAD_TILE_SCALE_HEIGHT), ROAD_TILE_SCALE_WIDTH, ROAD_TILE_SCALE_HEIGHT)
    return math3d.ref(math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET))
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
    __show_road_entrance_marker(self, typeobject)
    icanvas.show(icanvas.types().ROAD_ENTRANCE_MARKER, true)

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", terrain._width // ROAD_TILE_SCALE_WIDTH, terrain._height // ROAD_TILE_SCALE_HEIGHT, terrain.tile_size * ROAD_TILE_SCALE_WIDTH, {t = __calc_grid_position(typeobject, self.pickup_object.x, self.pickup_object.y)})
        self.grid_entity:show(true)
    end
end

local function rotate_pickup_object(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    pickup_object.dir = dir
    pickup_object.srt.r = ROTATORS[dir]

    local road_entrance_position, ddir = _get_road_entrance_position(typeobject, dir, self.pickup_object.srt.t)
    if road_entrance_position then
        self.road_entrance:set_srt(mc.ONE, ROTATORS[ddir], road_entrance_position)
    end

    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local self_selected_boxes_position = coord_system:get_position_by_coord(pickup_object.x, pickup_object.y, w, h)
    self.self_selected_boxes:set_position(self_selected_boxes_position)
    self.self_selected_boxes:set_wh(w, h)
end

local function touch_move(self, datamodel, delta_vec)
    if self.pickup_object then
        iobject.move_delta(self.pickup_object, delta_vec, coord_system)
        local typeobject = iprototype.queryByName(self.pickup_object.prototype_name)

        if self.grid_entity then
            self.grid_entity:send("obj_motion", "set_position", __calc_grid_position(typeobject, self.pickup_object.x, self.pickup_object.y))
        end

        local road_entrance_position, road_entrance_dir = _get_road_entrance_position(typeobject, self.pickup_object.dir, self.pickup_object.srt.t)
        assert(road_entrance_position)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[road_entrance_dir], road_entrance_position)

        local position, x, y = __align(self.pickup_object.prototype_name, self.pickup_object.dir)
        if position then
            local w, h = iprototype.rotate_area(typeobject.area, self.pickup_object.dir)
            local self_selected_boxes_position = coord_system:get_position_by_coord(x, y, w, h)
            self.self_selected_boxes:set_position(self_selected_boxes_position)
            self.self_selected_boxes:set_wh(w, h)
        end

        __show_nearby_buildings_selected_boxes(self, x, y, self.pickup_object.dir, typeobject)

        self.last_position = self.pickup_object.srt.t
        icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
        local c = __show_road_entrance_marker(self, typeobject)
        if c then
            icanvas.show(icanvas.types().ROAD_ENTRANCE_MARKER, true)
            if c.dir ~= self.pickup_object.dir then
                rotate_pickup_object(self, datamodel, c.dir)
            end
            if not datamodel.show_confirm then
                return
            end
        end
    end
end

local function touch_end(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})

    local pickup_object = self.pickup_object
    if not pickup_object then
        return
    end

    local position, x, y = __align(self.pickup_object.prototype_name, self.pickup_object.dir)
    if not position then
        return
    end
    pickup_object.x, pickup_object.y = x, y
    pickup_object.srt.t = math3d.ref(math3d.vector(position))

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)

    if not self:check_construct_detector(pickup_object.prototype_name, x, y, pickup_object.dir) then
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

    local road_entrance_position, road_entrance_dir = _get_road_entrance_position(typeobject, self.pickup_object.dir, self.pickup_object.srt.t)
    self.road_entrance:set_srt(mc.ONE, ROTATORS[road_entrance_dir], road_entrance_position)

    local w, h = iprototype.rotate_area(typeobject.area, self.pickup_object.dir)
    local self_selected_boxes_position = coord_system:get_position_by_coord(pickup_object.x, pickup_object.y, w, h)
    self.self_selected_boxes:set_position(self_selected_boxes_position)
    self.self_selected_boxes:set_wh(w, h)

    -- update temp pole
    if typeobject.supply_area and typeobject.supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, targets = {}, x = self.pickup_object.x, y = self.pickup_object.y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance, power_network_link = typeobject.power_network_link})
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end
end

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local succ = self:check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)
    if not succ then
        log.info("can not construct")
        return true
    end

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    objects:set(pickup_object, "CONFIRM")
    pickup_object.PREPARE = true

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    --
    if typeobject.supply_area and typeobject.supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, targets = {}, x = pickup_object.x, y = pickup_object.y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance, power_network_link = typeobject.power_network_link}, true)
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end

    return self:complete(pickup_object.id, datamodel)
end

local iroadnet = ecs.require "roadnet"
local function complete(self, object_id, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
    ieditor:revert_changes({"TEMPORARY"})

    igameplay.build_world()
    iroadnet:editor_build()
    self.super.complete(self, object_id)

    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    assert(ichest.inventory_pickup(gameplay_core.get_world(), typeobject.id, 1))

    local continue_construct = ichest.get_inventory_item_count(gameplay_core.get_world(), typeobject.id) > 0
    if not continue_construct then
        return false
    else
        new_entity(self, datamodel, typeobject)
        return true
    end
end

local function __is_station_placeable(prototype_name)
    local typeobject = iprototype.queryByName(prototype_name)
    if not typeobject then
        return false
    end

    return (typeobject.track == "I")
end

local function __is_straight_road(prototype_name)
    local typeobject = iprototype.queryByName(prototype_name)
    if not typeobject then
        return false
    end

    return (typeobject.track == "I" or typeobject.track == "L" or typeobject.track == "U")
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    local succ = self.super:check_construct_detector(prototype_name, x, y, dir)
    if not succ then
        return false
    end

    local typeobject = iprototype.queryByName(prototype_name)
    local w, h = iprototype.unpackarea(typeobject.area)

    if typeobject.crossing then
        local valid = false
        for _, conn in ipairs(_get_connections(prototype_name, x, y, dir)) do
            local succ, dx, dy = coord_system:move_coord(conn.x, conn.y, conn.dir, ROAD_TILE_SCALE_WIDTH, ROAD_TILE_SCALE_HEIGHT)
            if not succ then
                goto continue
            end

            local mask = iroad.get(gameplay_core.get_world(), dx//2*2, dy//2*2)
            if not mask then
                return false
            end

            -- local prototype_name = iroadnet_converter.mask_to_prototype_name_dir(mask)
            -- if not __is_station_placeable(prototype_name) then
            --     return false
            -- end

            -- local deltas = {
            --     {iprototype.rotate_dir_times(conn.dir, -1), 1},
            --     {iprototype.rotate_dir_times(conn.dir, -1), 2},
            --     {iprototype.rotate_dir_times(conn.dir, 1) , 1},
            --     {iprototype.rotate_dir_times(conn.dir, 1) , 2},
            -- }

            -- for _, d in ipairs(deltas) do
            --     local succ, lx, ly = coord_system:move_coord(dx, dy, d[1], d[2] * ROAD_TILE_SCALE_WIDTH, d[2] * ROAD_TILE_SCALE_HEIGHT)
            --     if not succ then
            --         goto continue
            --     end

            --     local mask = iroad.get(gameplay_core.get_world(), lx//2*2, ly//2*2)
            --     if not mask then
            --         return false
            --     end

            --     prototype_name = iroadnet_converter.mask_to_prototype_name_dir(mask)
            --     if not __is_straight_road(prototype_name) then
            --         return false
            --     end
            -- end

            valid = true
            break
            ::continue::
        end

        if not valid then
            return false
        end
    end

    -- for i = 0, w - 1 do
    --     for j = 0, h - 1 do
    --         local dx, dy = x + i, y + j
    --         local c = {}
    --         for _, dir in ipairs(ALL_DIR) do
    --             local succ, nx, ny = coord_system:move_coord(dx, dy, dir, ROAD_TILE_SCALE_WIDTH, ROAD_TILE_SCALE_HEIGHT)
    --             if not succ then
    --                 goto continue
    --             end

    --             local mask = iroad.get(gameplay_core.get_world(), nx//2*2, ny//2*2)
    --             if mask then
    --                 c[dir] = true
    --             end
    --             ::continue::
    --         end

    --         for dir in pairs(c) do
    --             if c[iprototype.rotate_dir_times(dir, 1)] or c[iprototype.rotate_dir_times(dir, -1)] then
    --                 return false
    --             end
    --         end
    --     end
    -- end

    return true
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false
    self.super.clean(self, datamodel)
    -- clear temp pole
    ipower:clear_all_temp_pole()
    ipower_line.update_temp_line(ipower:get_temp_pole())

    icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
        self.self_selected_boxes:remove()
        self.self_selected_boxes = nil
    end
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

    M.selected_boxes = {}
    return M
end
return create