local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.interface "icamera_controller"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local DEFAULT_DIR <const> = 'N'
local irecipe = require "gameplay.interface.recipe"
local iobject = ecs.require "object"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local imining = require "gameplay.interface.mining"
local math3d = require "math3d"
local coord_system = ecs.require "terrain"
local igrid_entity = ecs.require "engine.grid_entity"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local create_sprite = ecs.require "sprite"
local SPRITE_COLOR = import_package "vaststars.prototype".load("sprite_color")
local ichest = require "gameplay.interface.chest"
local create_selected_boxes = ecs.require "selected_boxes"
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

local function __show_self_selected_boxes(self, position, typeobject, dir, valid)
    --
    local color
    if valid then
        color = SPRITE_COLOR.CONSTRUCT_OUTLINE_SELF_VALID
    else
        color = SPRITE_COLOR.CONSTRUCT_OUTLINE_SELF_INVALID
    end
    if not self.self_selected_boxes then
        self.self_selected_boxes = create_selected_boxes(
            {
                "/pkg/vaststars.resources/prefabs/selected-box-no-animation.prefab",
                "/pkg/vaststars.resources/prefabs/selected-box-no-animation-line.prefab",
            },
            position, color, iprototype.rotate_area(typeobject.area, dir)
        )
    else
        self.self_selected_boxes:set_wh(iprototype.rotate_area(typeobject.area, dir))
        self.self_selected_boxes:set_position(position)
        self.self_selected_boxes:set_color_transition(color, 400)
    end
end

local ifluid = require "gameplay.interface.fluid"
local function get_dir_coord(x, y, dir, dx, dy)
    local dir_coord = {
        ['N'] = {x = 0,  y = -1},
        ['E'] = {x = 1,  y = 0},
        ['S'] = {x = 0,  y = 1},
        ['W'] = {x = -1, y = 0},
    }

    local function axis_value(v)
        v = math.max(v, 0)
        v = math.min(v, 255)
        return v
    end

    local c = assert(dir_coord[dir])
    return axis_value(x + c.x * (dx or 1)), axis_value(y + c.y * (dy or 1))
end

local __get_neighbor_fluid_types; do
    local function is_neighbor(x1, y1, dir1, x2, y2, dir2)
        local dx1, dy1 = get_dir_coord(x1, y1, dir1)
        local dx2, dy2 = get_dir_coord(x2, y2, dir2)
        return (dx1 == x2 and dy1 == y2) and (dx2 == x1 and dy2 == y1)
    end

    function __get_neighbor_fluid_types(prototype_name, x, y, dir)
        local fluid_names = {}

        for _, v in ipairs(ifluid:get_fluidbox(prototype_name, x, y, dir, "")) do
            local dx, dy = get_dir_coord(v.x, v.y, v.dir)
            local object = objects:coord(dx, dy)
            if object then
                for _, v1 in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
                    if is_neighbor(v.x, v.y, v.dir, v1.x, v1.y, v1.dir) then
                        fluid_names[v1.fluid_name] = true
                    end
                end
            end
        end

        local array = {}
        for fluid in pairs(fluid_names) do
            array[#array + 1] = fluid
        end
        return array
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

    local MINERAL_WIDTH <const> = 7 -- TODO: remove hard codes
    local MINERAL_HEIGHT <const> = 7
    local mx = x - (MINERAL_WIDTH - w) // 2
    local my = y - (MINERAL_HEIGHT - h) // 2
    local mineral = terrain:get_mineral(mx, my) -- TODO: maybe have multiple minerals in the area
    if mineral then
        found = mineral
    end

    if not found then
        return
    end

    return imining.get_mineral_recipe(prototype_name, found)
end

local function __new_entity(self, datamodel, typeobject, position, x, y, dir)
    iobject.remove(self.pickup_object)

    local sprite_color
    local valid
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_INVALID
        end
        datamodel.show_confirm = false
        valid = false
    else
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_VALID
        end
        datamodel.show_confirm = true
        valid = true
    end
    datamodel.show_rotate = (typeobject.rotate_on_build == true)

    -- some assembling machine have default recipe
    local fluid_name = ""
    if typeobject.recipe then
        local recipe_typeobject = iprototype.queryByName(typeobject.recipe)
        if recipe_typeobject then
            fluid_name = irecipe.get_init_fluids(recipe_typeobject) or "" -- maybe no fluid in recipe
        end
    end

    -- the fluid type of the liquid container should be determined based on the surrounding fluid tanks when placing the fluid tank
    if iprototype.has_type(typeobject.type, "fluidbox") then
        local fluid_types = __get_neighbor_fluid_types(typeobject.name, x, y, dir)
        if #fluid_types > 1 then
            datamodel.show_confirm = false
            valid = false
        else
            fluid_name = fluid_types[1] or ""
        end
    end

    __show_self_selected_boxes(self, position, typeobject, dir, valid)
    local recipe = _get_mineral_recipe(typeobject.name, x, y, dir) -- TODO: maybe set recipt according to entity type?
    if recipe then
        local recipe_typeobject = iprototype.queryByName(recipe)
        if recipe_typeobject then
            fluid_name = irecipe.get_init_fluids(recipe_typeobject) or "" -- maybe no fluid in recipe
        end
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
        fluid_name = fluid_name,
        group_id = 0,
        recipe = recipe,
    }

    if self.sprite then
        self.sprite:remove()
    end

    self.sprite = __create_self_sprite(typeobject, x, y, dir, sprite_color)
end

local function __calc_grid_position(self, typeobject)
    local _, originPosition = coord_system:align(math3d.vector {0, 0, 0}, iprototype.unpackarea(typeobject.area))
    local buildingPosition = coord_system:get_position_by_coord(self.pickup_object.x, self.pickup_object.y, iprototype.unpackarea(typeobject.area))
    return math3d.ref(math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET))
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
        o:set_color(color)
    end
end

local function new_entity(self, datamodel, typeobject)
    if typeobject.power_supply_area and typeobject.power_supply_distance and not typeobject.supply_area then
        local sprite_color = SPRITE_COLOR.POWER_SUPPLY_AREA
        for _, object in objects:all() do
            local otypeobject = iprototype.queryByName(object.prototype_name)
            if otypeobject.power_supply_area then
                local w, h = iprototype.unpackarea(otypeobject.area)
                local ow, oh = otypeobject.power_supply_area:match("(%d+)x(%d+)")
                ow, oh = tonumber(ow), tonumber(oh)
                ow, oh = __rotate_area(ow, oh, object.dir)
                if not self.sprites[object.id] then
                    self.sprites[object.id] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, sprite_color)
                end
            end
        end
    end

    if iprototype.has_chest(typeobject.name) then
        local sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_OTHER
        for _, object in objects:all() do
            local otypeobject = iprototype.queryByName(object.prototype_name)
            if otypeobject.supply_area then
                local w, h = iprototype.unpackarea(otypeobject.area)
                local ow, oh = iprototype.unpackarea(otypeobject.supply_area)
                ow, oh = tonumber(ow), tonumber(oh)
                ow, oh = __rotate_area(ow, oh, object.dir)
                if not self.sprites[object.id] then
                    self.sprites[object.id] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, sprite_color)
                end
            end
        end
    end

    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir, coord_system, 1)
    if not x or not y then
        return
    end

    local position = coord_system:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir))

    __show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)

    __new_entity(self, datamodel, typeobject, position, x, y, dir)
    self.pickup_object.APPEAR = true

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", coord_system.tile_width, coord_system.tile_height, coord_system.tile_size, {t = __calc_grid_position(self, typeobject)})
        self.grid_entity:show(true)
    end
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

    if self.grid_entity then
        self.grid_entity:send("obj_motion", "set_position", __calc_grid_position(self, typeobject))
    end

    -- update temp pole
    if typeobject.power_supply_area and typeobject.power_supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.power_supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, position = pickup_object.srt.t, targets = {}, x = lx, y = ly, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.power_supply_distance, smooth_pos = true, power_network_link = typeobject.power_network_link})
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end

    if self.last_x == lx and self.last_y == ly then
        return
    end
    self.last_x, self.last_y = lx, ly

    local sprite_color
    local valid
    local offset_x, offset_y = 0, 0
    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)
    if not self:check_construct_detector(pickup_object.prototype_name, lx, ly, pickup_object.dir) then -- TODO
        datamodel.show_confirm = false
        valid = false

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
        __show_self_selected_boxes(self, pickup_object.srt.t, typeobject, pickup_object.dir, valid)
        __show_nearby_buildings_selected_boxes(self, x, y, pickup_object.dir, typeobject)
        return
    else
        datamodel.show_confirm = true
        valid = true

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
        __show_self_selected_boxes(self, pickup_object.srt.t, typeobject, pickup_object.dir, valid)
        __show_nearby_buildings_selected_boxes(self, x, y, pickup_object.dir, typeobject)
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, lx, ly, pickup_object.dir) -- TODO: maybe set recipt according to entity type?
    if pickup_object.recipe then
        local recipe_typeobject = iprototype.queryByName(pickup_object.recipe)
        if recipe_typeobject then
            pickup_object.fluid_name = irecipe.get_init_fluids(recipe_typeobject) or "" -- maybe no fluid in recipe
        end
    end

    -- the fluid type of the liquid container should be determined based on the surrounding fluid tanks when placing the fluid tank
    if iprototype.has_type(typeobject.type, "fluidbox") then
        local fluid_types = __get_neighbor_fluid_types(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)
        if #fluid_types > 1 then
            datamodel.show_confirm = false
            valid = false
        else
            pickup_object.fluid_name = fluid_types[1] or ""
        end
    end
end

local function touch_end(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})

    touch_move(self, datamodel, {0, 0, 0})
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
    if typeobject.power_supply_area and typeobject.power_supply_distance then
        local aw, ah = iprototype.unpackarea(typeobject.area)
        local sw, sh = typeobject.power_supply_area:match("(%d+)x(%d+)")
        ipower:merge_pole({power_network_link_target = 0, key = pickup_object.id, targets = {}, x = pickup_object.x, y = pickup_object.y, w = aw, h = ah, sw = tonumber(sw), sh = tonumber(sh), sd = typeobject.power_supply_distance, power_network_link = typeobject.power_network_link}, true)
        ipower_line.update_temp_line(ipower:get_temp_pole())
    end

    return self:complete(pickup_object.id, datamodel)
end

local function complete(self, object_id, datamodel)
    self.pickup_object = nil
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

local function check_construct_detector(self, prototype_name, x, y, dir)
    local succ = self.super:check_construct_detector(prototype_name, x, y, dir)
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
    local sprite_color
    local valid
    if not self:check_construct_detector(typeobject.name, pickup_object.x, pickup_object.y, dir) then
        valid = false
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_INVALID
        end
        datamodel.show_confirm = false
    else
        valid = true
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        elseif typeobject.power_supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_POWER_VALID
        end
        datamodel.show_confirm = true
    end

    __show_self_selected_boxes(self, pickup_object.srt.t, typeobject, pickup_object.dir, valid)

    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = __create_self_sprite(typeobject, x, y, dir, sprite_color)
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    for _, sprite in pairs(self.sprites) do
        sprite:remove()
    end
    self.sprites = {}

    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end

    for _, o in pairs(self.selected_boxes) do
        o:remove()
    end
    self.selected_boxes = {}

    if self.self_selected_boxes then
        self.self_selected_boxes:remove()
        self.self_selected_boxes = nil
    end

    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false
    self.super.clean(self, datamodel)
    -- clear temp pole
    ipower:clear_all_temp_pole()
    ipower_line.update_temp_line(ipower:get_temp_pole())
end

local function create(item)
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm
    M.rotate_pickup_object = rotate_pickup_object
    M.clean = clean
    M.check_construct_detector = check_construct_detector
    M.complete = complete
    M.sprites = {}
    M.self_selected_boxes = nil
    M.selected_boxes = {}
    M.last_x, M.last_y = -1, -1
    M.item = item

    return M
end
return create