local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local camera = ecs.require "engine.camera"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local DEFAULT_DIR <const> = 'N'
local global = require "global"
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local imining = require "gameplay.interface.mining"
local iconstant = require "gameplay.interface.constant"
local logistic_coord = ecs.require "terrain"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ALL_DIR = iconstant.ALL_DIR
local igrid_entity = ecs.require "engine.grid_entity"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"
local create_selected_boxes = ecs.require "selected_boxes"
local icanvas = ecs.require "engine.canvas"
local datalist = require "datalist"
local fs = require "filesystem"
local road_entrance_marker_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/road_entrance_marker_canvas.cfg")):read "a")
local building_coord = require "global".building_coord_system
local math3d = require "math3d"
local iroadnet_converter = require "roadnet_converter"
local gen_endpoint_mask = ecs.require "editor.endpoint".gen_endpoint_mask
local COLOR_GREEN = math3d.constant("v4", {0.3, 1, 0, 1})
local COLOR_RED = math3d.constant("v4", {1, 0.03, 0, 1})
local terrain = ecs.require "terrain"

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
    return math3d.ref(math3d.add(position, {ox * logistic_coord.tile_size / 2, 0, oy * logistic_coord.tile_size / 2})), ddir
end

local function __align(prototype_name, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local coord, position = logistic_coord:align(camera.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end
    return position, coord[1], coord[2]
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
            t = position,
        },
        fluid_name = "",
    }
    iui.open({"construct_pop.rml"}, self.pickup_object.srt.t)

    local road_entrance_position, road_entrance_dir = _get_road_entrance_position(typeobject, dir, self.pickup_object.srt.t)
    local w, h = iprototype.unpackarea(typeobject.area)
    local selected_boxes_position = logistic_coord:get_position_by_coord(x, y, w, h)
    if road_entrance_position then
        local srt = {t = road_entrance_position, r = ROTATORS[road_entrance_dir]}
        if datamodel.show_confirm then
            self.road_entrance = create_road_entrance(srt, "valid")
            self.selected_boxes = create_selected_boxes("/pkg/vaststars.resources/prefabs/selected-box-no-animation.prefab", selected_boxes_position, COLOR_GREEN, w+1, h+1)
        else
            self.road_entrance = create_road_entrance(srt, "invalid")
            self.selected_boxes = create_selected_boxes("/pkg/vaststars.resources/prefabs/selected-box-no-animation.prefab", selected_boxes_position, COLOR_RED, w+1, h+1)
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

local function __show_road_entrance_marker(self, typeobject, dir)
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
    for coord, mask in pairs(global.roadnet) do
        local x, y = iprototype.unpackcoord(coord)
        local prototype_name, dir = iroadnet_converter.mask_to_prototype_name_dir(mask)
        local dirs = _get_connections_dir(prototype_name, dir)
        for _, d in ipairs(ALL_DIR) do
            if dirs[d] then
                goto continue
            end

            local succ, dx, dy = logistic_coord:move_coord(x, y, d, 1)
            if not succ then
                goto continue
            end

            local bx, by = dx - offset[d][1], dy - offset[d][2]
            if not self:check_construct_detector(typeobject.name, bx, by, d) then
                goto continue
            end

            coords[#coords+1] = {x = dx, y = dy, dir = d, sx = x, sy = y}
            ::continue::
        end
    end

    local pr
    if self.last_position then
        pr = {self.last_position[1], 0, self.last_position[3]}
    else
        pr = {self.pickup_object.srt.t[1], 0, self.pickup_object.srt.t[3]}
    end

    local min_dist
    local min_coord
    for _, c in ipairs(coords) do
        local position = logistic_coord:get_position_by_coord(c.x, c.y, 1, 1)
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
        local position = logistic_coord:get_begin_position_by_coord(coord.x, coord.y, 1, 1)
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

    icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
    icanvas.add_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0, table.unpack(t))
    return min_coord
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", building_coord.tile_width, building_coord.tile_height, logistic_coord.tile_size, {t = {0, 1, 0}})
        self.grid_entity:show(true)

        if self.road_entrance then
            icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
            __show_road_entrance_marker(self, typeobject, self.pickup_object.dir)
            icanvas.show(icanvas.types().ROAD_ENTRANCE_MARKER, true)
        end
    end
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
            local mineral = logistic_coord:get_mineral(x + i, y + j) -- TODO: maybe have multiple minerals in the area
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

local function rotate_pickup_object(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    pickup_object.dir = dir

    local road_entrance_position, ddir = _get_road_entrance_position(typeobject, dir, self.pickup_object.srt.t)
    if road_entrance_position then
        self.road_entrance:set_srt(mc.ONE, ROTATORS[ddir], road_entrance_position)
    end

    local w, h = iprototype.unpackarea(typeobject.area)
    local selected_boxes_position = logistic_coord:get_position_by_coord(pickup_object.x, pickup_object.y, w, h)
    self.selected_boxes:set_position(selected_boxes_position)
end

local function touch_move(self, datamodel, delta_vec)
    if self.pickup_object then
        iobject.move_delta(self.pickup_object, delta_vec, logistic_coord)

        local typeobject = iprototype.queryByName(self.pickup_object.prototype_name)

        local road_entrance_position, road_entrance_dir = _get_road_entrance_position(typeobject, self.pickup_object.dir, self.pickup_object.srt.t)
        assert(road_entrance_position)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[road_entrance_dir], road_entrance_position)

        local position, x, y = __align(self.pickup_object.prototype_name, self.pickup_object.dir)
        if position then
            local w, h = iprototype.unpackarea(typeobject.area)
            local selected_boxes_position = logistic_coord:get_position_by_coord(x, y, w, h)
            self.selected_boxes:set_position(selected_boxes_position)
        end

        self.last_position = {self.pickup_object.srt.t[1], self.pickup_object.srt.t[2], self.pickup_object.srt.t[3]}
        icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
        local c = __show_road_entrance_marker(self, typeobject, self.pickup_object.dir)
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
    pickup_object.srt.t = position

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)

    if not self:check_construct_detector(pickup_object.prototype_name, x, y, pickup_object.dir) then
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
            self.selected_boxes:set_color(COLOR_RED)
        end
    else
        if self.road_entrance then
            self.road_entrance:set_state("valid")
            self.selected_boxes:set_color(COLOR_GREEN)
        end
    end

    local road_entrance_position, road_entrance_dir = _get_road_entrance_position(typeobject, self.pickup_object.dir, self.pickup_object.srt.t)
    self.road_entrance:set_srt(mc.ONE, ROTATORS[road_entrance_dir], road_entrance_position)

    local w, h = iprototype.unpackarea(typeobject.area)
    local selected_boxes_position = logistic_coord:get_position_by_coord(pickup_object.x, pickup_object.y, w, h)
    self.selected_boxes:set_position(selected_boxes_position)

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) -- TODO: maybe set recipt according to entity type?

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
        return
    end

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    pickup_object.state = "confirm"
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

    self:complete(pickup_object.id)

    self.pickup_object = nil
    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
        self.selected_boxes:remove()
        self.selected_boxes = nil
    end
    __new_entity(self, datamodel, typeobject)
end

local iroadnet = ecs.require "roadnet"
local function complete(self, object_id)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
    ieditor:revert_changes({"TEMPORARY"})

    for _, coord in ipairs(gen_endpoint_mask(objects:get(object_id, {"CONFIRM"}))) do
        local x, y = iprototype.unpackcoord(coord)
        local shape, dir = iroadnet_converter.mask_to_shape_dir(global.roadnet[coord])
        iroadnet:editor_set("road", "normal", x, y, shape, dir)
    end

    iroadnet:editor_build()
    self.super.complete(self, object_id)
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
            local succ, dx, dy = logistic_coord:move_coord(conn.x, conn.y, conn.dir, 1)
            if not succ then
                goto continue
            end

            if not global.roadnet[iprototype.packcoord(dx, dy)] then
                valid = false
                break
            end

            local prototype_name = iroadnet_converter.mask_to_prototype_name_dir(global.roadnet[iprototype.packcoord(dx, dy)])
            if not __is_station_placeable(prototype_name) then
                valid = false
                break
            end

            local left = iprototype.rotate_dir_times(conn.dir, -1)
            local right = iprototype.rotate_dir_times(conn.dir, 1)

            local succ, lx, ly = logistic_coord:move_coord(dx, dy, left, 1)
            if not succ then
                goto continue
            end
            if not global.roadnet[iprototype.packcoord(lx, ly)] then
                valid = false
                break
            end

            prototype_name = iroadnet_converter.mask_to_prototype_name_dir(global.roadnet[iprototype.packcoord(lx, ly)])
            if not __is_straight_road(prototype_name) then
                valid = false
                break
            end

            local succ, rx, ry = logistic_coord:move_coord(dx, dy, right, 1)
            if not succ then
                goto continue
            end
            if not global.roadnet[iprototype.packcoord(rx, ry)] then
                valid = false
                break
            end

            prototype_name = iroadnet_converter.mask_to_prototype_name_dir(global.roadnet[iprototype.packcoord(rx, ry)])
            if not __is_straight_road(prototype_name) then
                valid = false
                break
            end

            valid = true
            break
            ::continue::
        end

        if not valid then
            return false
        end
    end

    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local dx, dy = x + i, y + j
            local c = {}
            for _, dir in ipairs(ALL_DIR) do
                local succ, nx, ny = logistic_coord:move_coord(dx, dy, dir, 1)
                if not succ then
                    goto continue
                end

                local coord = iprototype.packcoord(nx, ny)
                if global.roadnet[coord] then
                    c[dir] = true
                end
                ::continue::
            end

            for dir in pairs(c) do
                if c[iprototype.rotate_dir_times(dir, 1)] or c[iprototype.rotate_dir_times(dir, -1)] then
                    return false
                end
            end
        end
    end

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

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
        self.selected_boxes:remove()
        self.selected_boxes = nil
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