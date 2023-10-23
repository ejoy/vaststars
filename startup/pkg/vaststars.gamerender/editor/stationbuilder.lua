local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local ROAD_SIZE <const> = CONSTANT.ROAD_SIZE
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local ALL_DIR <const> = CONSTANT.ALL_DIR
local DIR_MOVE_DELTA <const> = CONSTANT.DIR_MOVE_DELTA
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local SPRITE_COLOR <const> = import_package "vaststars.prototype"("sprite_color")

local function read_datalist(path)
    local fs = require "filesystem"
    local datalist = require "datalist"
    local fastio = require "fastio"
    return datalist.parse(fastio.readall(fs.path(path):localpath():string(), path))
end
local ROAD_ENTRANCE_MARKER_CFG <const> = read_datalist "/pkg/vaststars.resources/config/canvas/road-entrance-marker.cfg"

local math3d = require "math3d"
local COLOR_GREEN <const> = math3d.constant("v4", {0.3, 1, 0, 1})
local COLOR_RED <const> = math3d.constant("v4", {1, 0.03, 0, 1})
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})

local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.require "engine.system.camera_controller"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local igrid_entity = ecs.require "engine.grid_entity"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"
local create_selected_boxes = ecs.require "selected_boxes"
local icanvas = ecs.require "engine.canvas"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local ibuilding = ecs.require "render_updates.building"
local ibackpack = require "gameplay.interface.backpack"
local iterrain = ecs.require "terrain"
local srt = require "utility.srt"

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

local function _get_road_entrance_srt(typeobject, dir, position)
    if not typeobject.crossing then
        return
    end

    local conn  = typeobject.crossing.connections[1]
    local ox, oy, ddir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
    return srt.new({t = math3d.add(position, {ox * terrain.tile_size / 2, 0, oy * terrain.tile_size / 2}), r = ROTATORS[ddir]})
end

local function __align(prototype_name, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local coord, position = terrain:align(icamera_controller.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end
    coord[1], coord[2] = coord[1] - (coord[1] % ROAD_SIZE), coord[2] - (coord[2] % ROAD_SIZE)
    position = math3d.vector(terrain:get_position_by_coord(coord[1], coord[2], iprototype.rotate_area(typeobject.area, dir)))

    return position, coord[1], coord[2]
end


local function __get_nearby_buldings(x, y, w, h)
    local r = {}
    local begin_x, begin_y = terrain:bound_coord(x - ((10 - w) // 2), y - ((10 - h) // 2))
    local end_x, end_y = terrain:bound_coord(x + ((10 - w) // 2) + w, y + ((10 - h) // 2) + h)
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
    local nearby_buldings = __get_nearby_buldings(x, y, iprototype.rotate_area(typeobject.area, dir))
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    local redraw = {}
    for object_id, object in pairs(nearby_buldings) do
        redraw[object_id] = object
    end

    for object_id, o in pairs(self.selected_boxes) do
        o:remove()
        self.selected_boxes[object_id] = nil
    end

    for object_id, object in pairs(redraw) do
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if __is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                local sw, sh = iprototype.rotate_area(typeobject.supply_area, object.dir)
                if __is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                        local sw, sh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
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
        if __is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                local sw, sh = iprototype.rotate_area(typeobject.supply_area, object.dir)
                if __is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                        local sw, sh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
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
        o:set_color_transition(color, 400)
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
        srt = srt.new({
            t = position,
            r = ROTATORS[dir],
        }),
        fluid_name = "",
        group_id = 0,
    }

    __show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)

    local srt = _get_road_entrance_srt(typeobject, dir, self.pickup_object.srt.t)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local self_selected_boxes_position = terrain:get_position_by_coord(x, y, w, h)
    if srt then
        if datamodel.show_confirm then
            if not self.road_entrance then
                self.road_entrance = create_road_entrance(srt.t, "valid")
            else
                self.road_entrance:set_state("valid")
            end
            if not self.self_selected_boxes then
                self.self_selected_boxes = create_selected_boxes({
                    "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                    "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab"
                }, self_selected_boxes_position, COLOR_GREEN, w+1, h+1)
            end
        else
            if not self.road_entrance then
                self.road_entrance = create_road_entrance(srt.t, "invalid")
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

local function _get_rect(x, y, icon_w, icon_h)
    local max = math.max(icon_h, icon_w)
    local draw_w = iterrain.tile_size * (icon_w / max)
    local draw_h = iterrain.tile_size * (icon_h / max)
    local draw_x = x + (iterrain.tile_size - draw_w) / 2
    local draw_y = y + (iterrain.tile_size - draw_h) / 2
    return draw_x, draw_y, draw_w, draw_h
end

local ROTATORS <const> = CONSTANT.ROTATORS

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
    for e in gameplay_core.get_world().ecs:select "road:in building:in eid:in" do
        local x, y = e.building.x, e.building.y
        local prototype_name = iprototype.queryById(e.building.prototype).name
        local dirs = _get_connections_dir(prototype_name, e.building.direction)
        for _, d in ipairs(ALL_DIR) do
            if dirs[d] then
                goto continue
            end

            local succ, dx, dy = terrain:move_coord(x, y, d, ROAD_SIZE, ROAD_SIZE)
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
        local position = terrain:get_position_by_coord(c.x, c.y, 1, 1)
        local delta = DIR_MOVE_DELTA[iprototype.reverse_dir(c.dir)]

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
        local position = terrain:get_begin_position_by_coord(coord.x, coord.y, 1, 1)
        local delta = DIR_MOVE_DELTA[iprototype.reverse_dir(coord.dir)]

        position[1] = position[1] + (delta.x * (iterrain.tile_size / 2))
        position[3] = position[3] + (delta.y * (iterrain.tile_size / 2))

        local cfg
        if coord.x == min_coord.x and coord.y == min_coord.y and coord.dir == min_coord.dir then
            cfg = ROAD_ENTRANCE_MARKER_CFG["white"]
        else
            cfg = ROAD_ENTRANCE_MARKER_CFG["green"]
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
        "/pkg/vaststars.resources/materials/canvas/road-entrance-marker.material",
        RENDER_LAYER.ICON_CONTENT,
        table.unpack(markers)
    }

    -- icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
    -- icanvas.add_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0, table.unpack(t))
    return min_coord
end

local function __calc_grid_position(typeobject, x, y, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local _, originPosition = terrain:align(math3d.vector {10, 0, -10}, w, h) -- TODO: remove hardcode
    local buildingPosition = terrain:get_position_by_coord(x - (x % ROAD_SIZE), y - (y % ROAD_SIZE), ROAD_SIZE, ROAD_SIZE)
    return math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET)
end

local function new_entity(self, datamodel, typeobject)
    self.typeobject = typeobject

    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
    __show_road_entrance_marker(self, typeobject)
    icanvas.show(icanvas.types().ROAD_ENTRANCE_MARKER, true)

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create(terrain._width // ROAD_SIZE, terrain._height // ROAD_SIZE, terrain.tile_size * ROAD_SIZE, {t = __calc_grid_position(typeobject, self.pickup_object.x, self.pickup_object.y, self.pickup_object.dir)})
    end
end

local function rotate(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    pickup_object.dir = iprototype.dir_tostring(dir)
    pickup_object.srt.r = ROTATORS[pickup_object.dir]

    local srt = _get_road_entrance_srt(typeobject, pickup_object.dir, pickup_object.srt.t)
    if srt then
        self.road_entrance:set_srt(srt.s, srt.r, srt.t)
    end

    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)
    local self_selected_boxes_position = terrain:get_position_by_coord(pickup_object.x, pickup_object.y, w, h)
    self.self_selected_boxes:set_position(self_selected_boxes_position)
    self.self_selected_boxes:set_wh(w, h)
end

local function touch_move(self, datamodel, delta_vec)
    if self.pickup_object then
        iobject.move_delta(self.pickup_object, delta_vec)
        local typeobject = iprototype.queryByName(self.pickup_object.prototype_name)

        if self.grid_entity then
            self.grid_entity:set_position(__calc_grid_position(typeobject, self.pickup_object.x, self.pickup_object.y, self.pickup_object.dir))
        end

        local srt = _get_road_entrance_srt(typeobject, self.pickup_object.dir, self.pickup_object.srt.t)
        assert(srt)
        self.road_entrance:set_srt(srt.s, srt.r, srt.t)

        local position, x, y = __align(self.pickup_object.prototype_name, self.pickup_object.dir)
        if position then
            local w, h = iprototype.rotate_area(typeobject.area, self.pickup_object.dir)
            local self_selected_boxes_position = terrain:get_position_by_coord(x, y, w, h)
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
                rotate(self, datamodel, c.dir)
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
            self.self_selected_boxes:set_color(COLOR_RED)
        end
    else
        datamodel.show_confirm = true

        if self.road_entrance then
            self.road_entrance:set_state("valid")
            self.self_selected_boxes:set_color(COLOR_GREEN)
        end
    end

    local srt= _get_road_entrance_srt(typeobject, self.pickup_object.dir, self.pickup_object.srt.t)
    assert(srt)
    self.road_entrance:set_srt(srt.s, srt.r, srt.t)

    local w, h = iprototype.rotate_area(typeobject.area, self.pickup_object.dir)
    local self_selected_boxes_position = terrain:get_position_by_coord(pickup_object.x, pickup_object.y, w, h)
    self.self_selected_boxes:set_position(self_selected_boxes_position)
    self.self_selected_boxes:set_wh(w, h)

    -- update temp pole
    if typeobject.supply_area and typeobject.supply_distance then
        local aw, ah = iprototype.rotate_area(typeobject.area, self.pickup_object.dir)
        local sw, sh = iprototype.rotate_area(typeobject.supply_area, pickup_object.dir)
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
    objects:set(pickup_object, "CONFIRM")
    pickup_object.PREPARE = true

    datamodel.show_confirm = false
    datamodel.show_rotate = false
    --
    if typeobject.supply_area and typeobject.supply_distance then
        local aw, ah = iprototype.rotate_area(typeobject.area, pickup_object.dir)
        local sw, sh = iprototype.rotate_area(typeobject.supply_area, pickup_object.dir)
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, targets = {}, x = pickup_object.x, y = pickup_object.y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.supply_distance, power_network_link = typeobject.power_network_link}, true)
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end

    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    icanvas.remove_item(icanvas.types().ROAD_ENTRANCE_MARKER, 0)
    ieditor:revert_changes({"TEMPORARY"})

    self.super.complete(self, pickup_object.id)
    self.pickup_object = nil

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    assert(ibackpack.pickup(gameplay_core.get_world(), typeobject.id, 1))
    local continue_construct = ibackpack.query(gameplay_core.get_world(), typeobject.id) > 0
    if continue_construct then
        new_entity(self, datamodel, typeobject)
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
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    if typeobject.crossing then
        local valid = false
        for _, conn in ipairs(_get_connections(prototype_name, x, y, dir)) do
            local succ, dx, dy = terrain:move_coord(conn.x, conn.y, conn.dir, ROAD_SIZE, ROAD_SIZE)
            if not succ then
                goto continue
            end

            local mask = ibuilding.get(dx//2*2, dy//2*2)
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
            --     local succ, lx, ly = terrain:move_coord(dx, dy, d[1], d[2] * ROAD_SIZE, d[2] * ROAD_SIZE)
            --     if not succ then
            --         goto continue
            --     end

            --     local mask = ibuilding.get(lx//2*2, ly//2*2)
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
    --             local succ, nx, ny = terrain:move_coord(dx, dy, dir, ROAD_SIZE, ROAD_SIZE)
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

    for _, o in pairs(self.selected_boxes) do
        o:remove()
    end
    self.selected_boxes = {}

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
    M.rotate = rotate
    M.clean = clean
    M.check_construct_detector = check_construct_detector

    M.selected_boxes = {}
    return M
end
return create