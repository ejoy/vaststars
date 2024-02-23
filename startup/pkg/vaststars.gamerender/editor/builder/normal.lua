local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local GRID_POSITION_OFFSET <const> = CONSTANT.GRID_POSITION_OFFSET
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local math3d = require "math3d"
local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.require "engine.system.camera_controller"
local objects = require "objects"
local iobject = ecs.require "object"
local iminer = require "gameplay.interface.miner"
local igrid_entity = ecs.require "engine.grid_entity"
local isprite = ecs.require "sprite"
local create_sprite = isprite.create
local flush_sprite = isprite.flush
local create_selected_boxes = ecs.require "selected_boxes"
local icoord = require "coord"
local gameplay_core = require "gameplay.core"
local create_fluid_indicators = ecs.require "fluid_indicators".create
local iinventory = require "gameplay.interface.inventory"
local ichest = require "gameplay.interface.chest"
local srt = require "utility.srt"
local imineral = ecs.require "mineral"
local igameplay = ecs.require "gameplay.gameplay_system"
local show_message = ecs.require "show_message".show_message
local igroup = ecs.require "group"
local get_check_coord = ecs.require "editor.builder.common".get_check_coord
local igame_object = ecs.require "engine.game_object"

local function _create_self_sprite(typeobject, x, y, dir, sprite_color)
    local sprite
    local offset_x, offset_y = 0, 0
    if typeobject.supply_area then
        local aw, ah = iprototype.rotate_area(typeobject.supply_area, dir)
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        sprite = create_sprite(x + offset_x, y + offset_y, aw, ah, sprite_color)
    end
    return sprite
end

local function _show_self_selected_boxes(self, position, typeobject, dir, valid)
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
                "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
            },
            position, color, iprototype.rotate_area(typeobject.area, dir)
        )
    else
        self.self_selected_boxes:set_wh(iprototype.rotate_area(typeobject.area, dir))
        self.self_selected_boxes:set_position(position)
        self.self_selected_boxes:set_color_transition(color, 400)
    end
end

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

local function _calc_grid_position(self, typeobject, dir)
    local _, originPosition = icoord.align(math3d.vector {0, 0, 0}, iprototype.rotate_area(typeobject.area, dir))
    local buildingPosition = icoord.position(self.status.x, self.status.y, iprototype.rotate_area(typeobject.area, dir))
    return math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET)
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

local function _get_selected_boxes_color(x1, y1, w1, h1, dir1, typeobject1, x2, y2, w2, h2, dir2, typeobject2)
    if _is_building_intersect(x1, y1, w1, h1, x2, y2, w2, h2) then
        return SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_INTERSECTION
    end

    -- all buildings within the drone's range need to be displayed in a specific color
    if typeobject1.supply_area then
        local aw, ah = iprototype.rotate_area(typeobject1.area, dir1)
        local sw, sh = iprototype.rotate_area(typeobject1.supply_area, dir1)
        if _is_building_intersect(x1 - (sw - aw) // 2, y1 - (sh - ah) // 2, sw, sh, x2, y2, w2, h2) then
            return SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
        end
    end

    return SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
end

local function _show_nearby_buildings_selected_boxes(self, nearby_buldings, typeobject, x, y, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    local new = {}
    for object_id, object in pairs(nearby_buldings) do
        if not self.selected_boxes[object_id] then
            new[object_id] = object
        end
    end

    for object_id, o in pairs(self.selected_boxes) do
        if not nearby_buldings[object_id] then
            o:remove()
            self.selected_boxes[object_id] = nil
        end
    end

    for object_id, object in pairs(new) do
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)
        local color = _get_selected_boxes_color(x, y, w, h, dir, typeobject, object.x, object.y, ow, oh, object.dir, otypeobject)
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
        local color = _get_selected_boxes_color(x, y, w, h, dir, typeobject, object.x, object.y, ow, oh, object.dir, otypeobject)
        o:set_color_transition(color, 400)
    end
end

local function _show_nearby_buildings_sprite(self, nearby_buldings, typeobject)
    if not ichest.has_chest(typeobject.type) then
        return
    end

    local new = {}
    for object_id, object in pairs(nearby_buldings) do
        if not self.sprites[object_id] then
            new[object_id] = object
        end
    end

    for object_id, o in pairs(self.sprites) do
        if not nearby_buldings[object_id] then
            o:remove()
            self.sprites[object_id] = nil
        end
    end

    local sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_OTHER
    for _, object in pairs(new) do
        local otypeobject = iprototype.queryByName(object.prototype_name)
        if otypeobject.supply_area then
            local w, h = iprototype.rotate_area(otypeobject.area, object.dir)
            local ow, oh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
            self.sprites[object.id] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, sprite_color)
        end
    end
end

local function _new_entity(self, datamodel, typeobject, x, y, position, dir)
    local nearby_buldings = _get_nearby_buildings(x, y, iprototype.rotate_area(typeobject.area, dir))
    _show_nearby_buildings_sprite(self, nearby_buldings, typeobject)
    _show_nearby_buildings_selected_boxes(self, nearby_buldings, typeobject, x, y, dir)

    local sprite_color
    if not self.check_coord(x, y, dir, self.typeobject) then
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        end
        datamodel.show_confirm = false
        _show_self_selected_boxes(self, position, typeobject, dir, false)
    else
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        end
        datamodel.show_confirm = true
        _show_self_selected_boxes(self, position, typeobject, dir, true)
    end
    datamodel.show_rotate = (typeobject.rotate_on_build == true)

    self.status = {
        x = x,
        y = y,
        dir = dir,
        srt = srt.new {
            t = math3d.vector(position),
            r = ROTATORS[dir],
        },
    }
    local status = self.status

    local model = typeobject.model:gsub("^(.*%.glb|)(.*%.prefab)$", "%1translucent.prefab")
    self.indicator = igame_object.create {
        prefab = model,
        srt = status.srt,
        color = SPRITE_COLOR.CONSTRUCT_SELF,
        emissive_color = SPRITE_COLOR.CONSTRUCT_SELF_EMISSIVE,
        render_layer = RENDER_LAYER.TRANSLUCENT_BUILDING,
    }

    if typeobject.fluid_indicators ~= false and iprototype.has_types(typeobject.type, "chimney", "fluidbox", "fluidboxes") then
        self.pickup_components.fluid_indicators = create_fluid_indicators(dir, status.srt, typeobject)
    end

    self.sprite = _create_self_sprite(typeobject, x, y, dir, sprite_color)

    flush_sprite()

    self.grid_entity = igrid_entity.create(MAP_WIDTH_COUNT, MAP_HEIGHT_COUNT, TILE_SIZE, TILE_SIZE, {t = _calc_grid_position(self, typeobject, dir)})
end

local function _align(position_type, area, dir)
    local p = icamera_controller.get_screen_world_position(position_type)
    local coord, pos = icoord.align(p, iprototype.rotate_area(area, dir))
    if not coord then
        return
    end
    return coord[1], coord[2], math3d.vector(pos)
end

local function _update(self, datamodel)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    for _, c in pairs(self.pickup_components) do
        c:on_position_change(status.srt, status.dir)
    end

    self.grid_entity:set_position(_calc_grid_position(self, typeobject, status.dir))

    local w, h = iprototype.rotate_area(typeobject.area, status.dir)
    if not self.check_coord(status.x, status.y, status.dir, typeobject) then
        datamodel.show_confirm = false

        if typeobject.supply_area then
            local aw, ah = iprototype.rotate_area(typeobject.supply_area, status.dir)
            local offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
            self.sprite:move(status.x + offset_x, status.y + offset_y, SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID)
        end
        _show_self_selected_boxes(self, status.srt.t, typeobject, status.dir, false)
    else
        datamodel.show_confirm = true

        if typeobject.supply_area then
            local aw, ah = iprototype.rotate_area(typeobject.supply_area, status.dir)
            local offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
            self.sprite:move(status.x + offset_x, status.y + offset_y, SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID)
        end
        _show_self_selected_boxes(self, status.srt.t, typeobject, status.dir, true)
    end

    local nearby_buldings = _get_nearby_buildings(status.x, status.y, iprototype.rotate_area(typeobject.area, status.dir))
    _show_nearby_buildings_sprite(self, nearby_buldings, typeobject)
    _show_nearby_buildings_selected_boxes(self, nearby_buldings, typeobject, status.x, status.y, status.dir)
    for _, c in pairs(self.pickup_components) do
        c:on_status_change(datamodel.show_confirm)
    end
    flush_sprite()
end

local function touch_move(self, datamodel, delta_vec)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    local x, y = _align(self.position_type, typeobject.area, status.dir)
    if not x then
        datamodel.show_confirm = false
        return
    end
    status.x, status.y = x, y

    status.srt.t = math3d.add(status.srt.t, delta_vec)
    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    _update(self, datamodel)
end

local function touch_end(self, datamodel)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    local x, y, pos = _align(self.position_type, typeobject.area, status.dir)
    if not x then
        datamodel.show_confirm = false
        return
    end
    status.x, status.y, status.srt.t = x, y, pos
    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    _update(self, datamodel)
end

local function confirm(self, datamodel)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    local succ, msg = self.check_coord(status.x, status.y, status.dir, typeobject)
    if not succ then
        show_message(msg)
        return
    end

    local gameplay_world = gameplay_core.get_world()
    if iinventory.query(gameplay_world, typeobject.id) < 1 then
        show_message("item not enough")
        return
    end
    assert(iinventory.pickup(gameplay_world, typeobject.id, 1))

    local w, h = iprototype.rotate_area(typeobject.area, status.dir)
    local object = iobject.new {
        prototype_name = typeobject.name,
        dir = status.dir,
        x = status.x,
        y = status.y,
        srt = srt.new(self.status.srt),
        group_id = igroup.id(status.x, status.y),
        render_layer = RENDER_LAYER.BUILDING,
    }
    object.gameplay_eid = igameplay.create_entity {
        prototype_name = typeobject.name,
        dir = status.dir,
        x = status.x,
        y = status.y,
        recipe = _get_mineral_recipe(typeobject.name, status.x, status.y, w, h),
    }
    object.PREPARE = true

    objects:set(object, "CONSTRUCTED")
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

    datamodel.show_confirm = false
end

local function rotate(self, datamodel, dir, delta_vec)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    dir = dir or iprototype.rotate_dir_times(status.dir, -1)
    status.dir = iprototype.dir_tostring(dir)
    status.srt.r = ROTATORS[status.dir]

    indicator:send("obj_motion", "set_rotation", math3d.live(status.srt.r))

    local x, y, pos = _align(self.position_type, typeobject.area, status.dir)
    if not x then
        datamodel.show_confirm = false
        return
    end
    status.srt.t, status.x, status.y = pos, x, y
    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    for _, c in pairs(self.pickup_components) do
        c:on_position_change(status.srt, status.dir)
    end
    local sprite_color
    local valid
    if not self.check_coord(status.x, status.y, status.dir, typeobject) then
        valid = false
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        end
        datamodel.show_confirm = false
    else
        valid = true
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        end
        datamodel.show_confirm = true
    end

    _show_self_selected_boxes(self, status.srt.t, typeobject, status.dir, valid)

    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = _create_self_sprite(typeobject, x, y, status.dir, sprite_color)
    flush_sprite()
end

local function clean(self, datamodel)
    self.grid_entity:remove()

    for _, sprite in pairs(self.sprites) do
        sprite:remove()
    end

    if self.sprite then
        self.sprite:remove()
    end
    flush_sprite()

    for _, o in pairs(self.selected_boxes) do
        o:remove()
    end

    for _, c in pairs(self.pickup_components) do
        c:remove()
    end

    self.self_selected_boxes:remove()

    datamodel.show_confirm = false
    datamodel.show_rotate = false

    self.indicator:remove()
end

local function new(self, datamodel, typeobject, position_type)
    self.check_coord = get_check_coord(typeobject)

    self.typeobject = typeobject
    self.position_type = position_type

    local x, y, pos = _align(self.position_type, self.typeobject.area, DEFAULT_DIR)
    _new_entity(self, datamodel, typeobject, x, y, pos, DEFAULT_DIR)
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
    m.sprites = {}
    m.self_selected_boxes = nil
    m.selected_boxes = {}
    m.pickup_components = {}
    m.status = {}
    return m
end
return create