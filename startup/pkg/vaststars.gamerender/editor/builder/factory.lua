local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local MAP_WIDTH <const> = CONSTANT.MAP_WIDTH
local MAP_HEIGHT <const> = CONSTANT.MAP_HEIGHT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local ROAD_SIZE <const> = CONSTANT.ROAD_SIZE
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local math3d = require "math3d"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local COLOR_GREEN <const> = math3d.constant("v4", {0.3, 1, 0, 1})
local COLOR_RED <const> = math3d.constant("v4", {1, 0.03, 0, 1})
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"

local objects = require "objects"
local ibuilding = ecs.require "render_updates.building"
local imineral = ecs.require "mineral"
local igrid_entity = ecs.require "engine.grid_entity"
local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.require "engine.system.camera_controller"
local icoord = require "coord"
local iobject = ecs.require "object"
local srt = require "utility.srt"
local create_selected_boxes = ecs.require "selected_boxes"
local gameplay_core = require "gameplay.core"
local iinventory = require "gameplay.interface.inventory"
local igameplay = ecs.require "gameplay.gameplay_system"
local inner_building = require "editor.inner_building"
local vsobject_manager = ecs.require "vsobject_manager"
local show_message = ecs.require "show_message"

local function _lefttop_position(pos, dir, host_area, area)
    local hw, hh = (host_area >> 8) - 1, (host_area & 0xFF) - 1
    local w, h = (area >> 8) - 1, (area & 0xFF) - 1

    local x, y = pos[1], pos[2]
    if dir == "N" then
        return x, y
    elseif dir == "E" then
        return hh - y - h, x
    elseif dir == "S" then
        return hw - x - w, hh - y - h
    elseif dir == "W" then
        return y, hw - x - w
    end
    assert(false)
end

local function _check_coord(x, y, w, h, check_x, check_y, check_w, check_h)
    local sx_min, sx_max = check_x, check_x + check_w - 1
    local sy_min, sy_max = check_y, check_y + check_h - 1

    for i = 0, w - 1 do
        for j = 0, h - 1 do
            -- check road in the specified range
            if i >= sx_min and i <= sx_max and
               j >= sy_min and j <= sy_max then
                if not ibuilding.get((x + i)//2*2, (y + j)//2*2) then
                    return false, "needs to be placed above the road"
                end
            else
                local object = objects:coord(x + i, y + j)
                -- building
                if object then
                    return false, "cannot place here"
                end

                -- road
                if ibuilding.get((x + i)//2*2, (y + j)//2*2) then
                    return false, "cannot place here"
                end

                -- mineral
                if imineral.get(x + i, y + j) then
                    return false, "cannot place here"
                end
            end
        end
    end
    return true
end


local function _align(w, h, position_type)
    local pos = icamera_controller.get_screen_world_position(position_type)
    local coord, position = icoord.align(pos, w, h)
    if not coord then
        return
    end
    coord[1], coord[2] = coord[1] - (coord[1] % ROAD_SIZE), coord[2] - (coord[2] % ROAD_SIZE)
    position = math3d.vector(icoord.position(coord[1], coord[2], w, h))
    return position, coord[1], coord[2]
end

local function _calc_grid_position(x, y, w, h)
    local _, origin_pos = icoord.align(math3d.vector {10, 0, -10}, w, h) -- TODO: remove hardcode
    local building_pos = icoord.position(x - (x % ROAD_SIZE), y - (y % ROAD_SIZE), ROAD_SIZE, ROAD_SIZE)
    return math3d.add(math3d.sub(building_pos, origin_pos), GRID_POSITION_OFFSET)
end

local function _new_entity(self, datamodel, typeobject, x, y, position, dir)
    iobject.remove(self.pickup_object)

    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local self_selected_boxes_position = icoord.position(x, y, w, h)
    local check_x, check_y = _lefttop_position(self.typeobject.check_pos, dir, typeobject.area, typeobject.check_area)
    local check_w, check_h = iprototype.rotate_area(typeobject.check_area, dir)
    local valid = _check_coord(x, y, w, h, check_x, check_y, check_w, check_h)
    datamodel.show_confirm = valid
    datamodel.show_rotate = true

    local color = valid and COLOR_GREEN or COLOR_RED
    self.self_selected_boxes = create_selected_boxes({
        "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
        "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab"
    }, self_selected_boxes_position, color, w+1, h+1)

    self.pickup_object = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        srt = srt.new {
            t = position,
            r = ROTATORS[dir],
        },
        fluid_name = "",
        group_id = 0,
    }
end

local function _update_state(self, datamodel)
    assert(self.pickup_object)
    assert(self.grid_entity)

    local pickup_object = self.pickup_object
    local w, h = iprototype.rotate_area(self.typeobject.area, pickup_object.dir)

    self.grid_entity:set_position(_calc_grid_position(pickup_object.x, pickup_object.y, w, h))

    local position, x, y = _align(w, h, self.position_type)
    if position then
        self.self_selected_boxes:set_position(icoord.position(x, y, w, h))
        self.self_selected_boxes:set_wh(w, h)
    end

    local check_x, check_y = _lefttop_position(self.typeobject.check_pos, pickup_object.dir, self.typeobject.area, self.typeobject.check_area)
    local check_w, check_h = iprototype.rotate_area(self.typeobject.check_area, pickup_object.dir)
    local valid = _check_coord(x, y, w, h, check_x, check_y, check_w, check_h)

    datamodel.show_confirm = valid
    self.self_selected_boxes:set_color(valid and COLOR_GREEN or COLOR_RED)
end

---
local function touch_move(self, datamodel, delta_vec)
    local pickup_object = assert(self.pickup_object)
    iobject.move_delta(pickup_object, delta_vec)

    _update_state(self, datamodel)
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

    _update_state(self, datamodel)
end

local function rotate(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)
    pickup_object.dir = iprototype.dir_tostring(dir)
    pickup_object.srt.r = ROTATORS[pickup_object.dir]

    local w, h = iprototype.rotate_area(self.typeobject.area, pickup_object.dir)
    local position, x, y = _align(w, h, self.position_type)
    if not position then
        return
    end
    pickup_object.x, pickup_object.y = x, y
    pickup_object.srt.t = position

    _update_state(self, datamodel)
end

local function build(self, v)
    local typeobject = iprototype.queryByName(v.prototype_name)
    for _, b in ipairs(typeobject.inner_building) do
        local prototype_name = b[4]
        local typeobject_inner = iprototype.queryByName(prototype_name)

        local dx, dy = _lefttop_position(b, v.dir, typeobject.area, typeobject_inner.area)
        local x, y = v.x + dx, v.y + dy
        local dir = iprototype.rotate_dir(b[3], v.dir)

        local gameplay_eid = igameplay.create_entity({dir = iprototype.dir_tostring(dir), x = x, y = y, prototype_name = prototype_name})

        local w, h = iprototype.rotate_area(typeobject_inner.area, v.dir)
        inner_building:set(gameplay_eid, x, y, w, h)
    end

    return igameplay.create_entity(v)
end

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local w, h = iprototype.rotate_area(self.typeobject.area, pickup_object.dir)
    local check_x, check_y = _lefttop_position(self.typeobject.check_pos, pickup_object.dir, self.typeobject.area, self.typeobject.check_area)
    local check_w, check_h = iprototype.rotate_area(self.typeobject.check_area, pickup_object.dir)
    local succ, errmsg = _check_coord(pickup_object.x, pickup_object.y, w, h, check_x, check_y, check_w, check_h)
    if not succ then
        show_message(errmsg)
        return
    end

    local gameplay_world = gameplay_core.get_world()
    if iinventory.query(gameplay_world, self.typeobject.id) < 1 then
        print("can not place, not enough " .. self.typeobject.name) --TODO: show error message
        return
    end
    assert(iinventory.pickup(gameplay_world, self.typeobject.id, 1))
    datamodel.show_confirm = false
    datamodel.show_rotate = false

    objects:set(pickup_object, "CONSTRUCTED")
    pickup_object.gameplay_eid = build(self, {dir = pickup_object.dir, x = pickup_object.x, y = pickup_object.y, prototype_name = pickup_object.prototype_name, amount = self.typeobject.amount})

    pickup_object.PREPARE = true
    self.pickup_object = nil
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)
    self.self_selected_boxes:remove()

    _new_entity(self, datamodel, self.typeobject, pickup_object.x, pickup_object.y, pickup_object.srt.t, pickup_object.dir)
end

local function clean(self, datamodel)
    datamodel.show_confirm = false
    datamodel.show_rotate = false

    iobject.remove(self.pickup_object)
    self.grid_entity:remove()

    self.self_selected_boxes:remove()
end

local function new(self, datamodel, typeobject, position_type)
    self.position_type = position_type
    self.typeobject = typeobject

    local dir = DEFAULT_DIR
    local w, h = iprototype.rotate_area(self.typeobject.area, dir)
    local position, x, y = _align(w, h, self.position_type)
    if not x or not y then
        return
    end

    _new_entity(self, datamodel, self.typeobject, x, y, position, dir)
    self.pickup_object.APPEAR = true
    self.grid_entity = igrid_entity.create(MAP_WIDTH // ROAD_SIZE, MAP_HEIGHT // ROAD_SIZE, TILE_SIZE * ROAD_SIZE, {t = _calc_grid_position(x, y, w, h)})
end

local build_t = {}
build_t.new = new
build_t.touch_move = touch_move
build_t.touch_end = touch_end
build_t.confirm = confirm
build_t.rotate = rotate
build_t.clean = clean
build_t.build = build
local build_mt = {__index = build_t}

local move_t = {CONFIRM_EXIT = true}
move_t.touch_move = touch_move
move_t.touch_end = touch_end
move_t.confirm = confirm
move_t.rotate = rotate
move_t.clean = clean

function move_t:new(move_object_id, datamodel, typeobject)
    self.position_type = "CENTER"
    self.typeobject = typeobject

    local dir = DEFAULT_DIR
    local w, h = iprototype.rotate_area(self.typeobject.area, dir)
    local position, x, y = _align(w, h, self.position_type)
    if not x or not y then
        return
    end

    _new_entity(self, datamodel, self.typeobject, x, y, position, dir)
    self.pickup_object.APPEAR = true
    self.grid_entity = igrid_entity.create(MAP_WIDTH // ROAD_SIZE, MAP_HEIGHT // ROAD_SIZE, TILE_SIZE * ROAD_SIZE, {t = _calc_grid_position(x, y, w, h)})

    self.move_object_id = move_object_id
    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "translucent", color = SPRITE_COLOR.MOVE_SELF, emissive_color = SPRITE_COLOR.MOVE_SELF, render_layer = RENDER_LAYER.TRANSLUCENT_BUILDING}
end

local function _get_inner_building_config(inner_buildings, area, dx, dy, dir)
    for _, inner_building in ipairs(inner_buildings) do
        local typeobject = iprototype.queryByName(inner_building[4])
        local x, y = _lefttop_position(inner_building, dir, area, typeobject.area)
        if x == dx and y == dy then
            return inner_building
        end
    end
    assert(false)
end

function move_t:confirm(datamodel)
    local pickup_object = assert(self.pickup_object)
    local w, h = iprototype.rotate_area(self.typeobject.area, pickup_object.dir)
    local check_x, check_y = _lefttop_position(self.typeobject.check_pos, pickup_object.dir, self.typeobject.area, self.typeobject.check_area)
    local check_w, check_h = iprototype.rotate_area(self.typeobject.check_area, pickup_object.dir)
    local succ, errmsg = _check_coord(pickup_object.x, pickup_object.y, w, h, check_x, check_y, check_w, check_h)
    if not succ then
        show_message(errmsg)
        return
    end

    local object = assert(objects:get(self.move_object_id))
    local e = gameplay_core.get_entity(object.gameplay_eid)

    local typeobject = iprototype.queryById(e.building.prototype)
    local w, h = iprototype.unpackarea(typeobject.area)
    for gameplay_eid in inner_building:get(e.building.x, e.building.y, w, h) do
        local ce = gameplay_core.get_entity(gameplay_eid)

        local cfg = _get_inner_building_config(typeobject.inner_building, typeobject.area, ce.building.x - e.building.x, ce.building.y - e.building.y, iprototype.dir_tostring(e.building.direction))
        local dx, dy = _lefttop_position(cfg, pickup_object.dir, typeobject.area, iprototype.queryById(ce.building.prototype).area)
        local dir = iprototype.rotate_dir(e.building.direction, pickup_object.dir)

        ce.building_changed = true
        igameplay.move(gameplay_eid, self.pickup_object.x + dx, self.pickup_object.y + dy)
        igameplay.rotate(gameplay_eid, iprototype.dir_tostring(dir))

        local cw, ch = iprototype.unpackarea(iprototype.queryById(ce.building.prototype).area)
        inner_building:reset(gameplay_eid, self.pickup_object.x + dx, self.pickup_object.y + dy, cw, ch)
    end

    e.building_changed = true
    igameplay.move(object.gameplay_eid, self.pickup_object.x, self.pickup_object.y)
    igameplay.rotate(object.gameplay_eid, self.pickup_object.dir)

    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

    object.x = self.pickup_object.x
    object.y = self.pickup_object.y
    object.srt.t = self.pickup_object.srt.t
    object.dir = self.pickup_object.dir
    object.srt.r = ROTATORS[object.dir]
    objects:set(object, "CONSTRUCTED")
    objects:coord_update(object)
end
function move_t:clean(datamodel)
    clean(self, datamodel)
    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "opaque", color = "null", emissive_color = "null", render_layer = RENDER_LAYER.BUILDING}
end
local move_mt = {__index = move_t}

local function create(t)
    if t == "build" then
        return setmetatable({}, build_mt)
    elseif t == "move" then
        return setmetatable({}, move_mt)
    else
        assert(false)
    end
end
return create