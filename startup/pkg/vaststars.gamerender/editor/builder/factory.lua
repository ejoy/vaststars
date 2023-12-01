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

local math3d = require "math3d"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local COLOR_GREEN <const> = math3d.constant("v4", {0.3, 1, 0, 1})
local COLOR_RED <const> = math3d.constant("v4", {1, 0.03, 0, 1})

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

local function _cover_position(pos, dir, area)
    local w, h = area >> 8, area & 0xFF
    local x, y = pos[1], pos[2]
    w = w - 1
    h = h - 1
    if dir == "N" then
        return x, y
    elseif dir == "E" then
        return y, x
    elseif dir == "S" then
        return x, y
    elseif dir == "W" then
        return y, x
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
                    return false
                end
            else
                local object = objects:coord(x + i, y + j)
                -- building
                if object then
                    return false
                end

                -- road
                if ibuilding.get((x + i)//2*2, (y + j)//2*2) then
                    return false
                end

                -- mineral
                if imineral.get(x + i, y + j) then
                    return false
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
    local check_x, check_y = _cover_position(self.typeobject.check_pos, dir, self.typeobject.area)
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

    local check_x, check_y = _cover_position(self.typeobject.check_pos, pickup_object.dir, self.typeobject.area)
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

local function confirm(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    local w, h = iprototype.rotate_area(self.typeobject.area, pickup_object.dir)
    local check_x, check_y = _cover_position(self.typeobject.check_pos, pickup_object.dir, self.typeobject.area)
    local check_w, check_h = iprototype.rotate_area(self.typeobject.check_area, pickup_object.dir)

    local succ = _check_coord(pickup_object.x, pickup_object.y, w, h, check_x, check_y, check_w, check_h)
    if not succ then
        log.info("can not construct") --TODO: show error message
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
    pickup_object.gameplay_eid = igameplay.create_entity({dir = pickup_object.dir, x = pickup_object.x, y = pickup_object.y, prototype_name = pickup_object.prototype_name, amount = self.typeobject.amount})
    for _, b in ipairs(self.typeobject.inner_building) do
        local dx, dy = _cover_position(b, pickup_object.dir, self.typeobject.area)
        local x, y = pickup_object.x + dx, pickup_object.y + dy
        local prototype_name = b[3]
        local typeobject_inner = iprototype.queryByName(prototype_name)
        local w, h = iprototype.rotate_area(typeobject_inner.area, pickup_object.dir)
        local gameplay_eid = igameplay.create_entity({dir = pickup_object.dir, x = x, y = y, prototype_name = prototype_name})

        inner_building:set(x, y, w, h, gameplay_eid)
    end

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

local function build(self, v)
    igameplay.create_entity(v)

    local typeobject = iprototype.queryByName(v.prototype_name)
    for _, b in ipairs(typeobject.inner_building) do
        local dx, dy = _cover_position(b, v.dir, typeobject.area)
        local x, y = v.x + dx, v.y + dy
        local prototype_name = b[3]
        local typeobject_inner = iprototype.queryByName(prototype_name)
        local w, h = iprototype.rotate_area(typeobject_inner.area, v.dir)
        local gameplay_eid = igameplay.create_entity({dir = v.dir, x = x, y = y, prototype_name = prototype_name})

        inner_building:set(x, y, w, h, gameplay_eid)
    end
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
    return m
end
return create