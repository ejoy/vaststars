local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local CHANGED_FLAG_FLUIDFLOW <const> = CONSTANT.CHANGED_FLAG_FLUIDFLOW
local GRID_POSITION_OFFSET <const> = CONSTANT.GRID_POSITION_OFFSET
local DIRECTION <const> = CONSTANT.DIRECTION
local PIPE_DIRECTION <const> = {
    N = DIRECTION.N,
    E = DIRECTION.E,
    S = DIRECTION.S,
    W = DIRECTION.W,
}

local math3d = require "math3d"
local iprototype = require "gameplay.interface.prototype"
local iobject = ecs.require "object"
local objects = require "objects"
local igrid_entity = ecs.require "engine.grid_entity"
local icoord = require "coord"
local igameplay = ecs.require "gameplay.gameplay_system"
local gameplay_core = require "gameplay.core"
local create_pickup_selection_box = ecs.require "editor.indicators.pickup_selection_box"
local iprototype_cache = ecs.require "prototype_cache"
local icamera_controller = ecs.require "engine.system.camera_controller"
local srt = require "utility.srt"
local iinventory = require "gameplay.interface.inventory"
local show_message = ecs.require "show_message".show_message
local get_check_coord = ecs.require "editor.builder.common".get_check_coord
local ifluidbox = ecs.require "render_updates.fluidbox"
local igame_object = ecs.require "engine.game_object"

local function _calc_grid_position(building_position, typeobject, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local _, originPosition = icoord.align(math3d.vector(0, 0, 0), w, h)
    return math3d.add(math3d.sub(building_position, originPosition), GRID_POSITION_OFFSET)
end

local function _get_placed_pipe(typeobject, x, y)
    local mask = 0
    for _, d in pairs(PIPE_DIRECTION) do
        local dx, dy = iprototype.move_coord(x, y, d)
        local fluid = ifluidbox.get(dx, dy, iprototype.reverse_dir(d))
        if fluid then
            mask = mask | (1 << d)
        end
    end
    return iprototype_cache.get("pipe").MaskToPrototypeDir(typeobject.building_category, mask)
end

local function _align(position_type, area, dir)
    local p = icamera_controller.get_screen_world_position(position_type)
    local coord, pos = icoord.align(p, iprototype.rotate_area(area, dir))
    if not coord then
        return
    end
    return coord[1], coord[2], math3d.vector(pos)
end

local function _update_indicator(indicator, status)
    indicator:update {prefab = iprototype.queryById(status.prototype).model}
    indicator:send("obj_motion", "set_rotation", math3d.live(status.srt.r))
end

local function _update_status(status, typeobject, x, y)
    local prototype, new_dir = _get_placed_pipe(typeobject, x, y)
    if prototype ~= status.prototype or new_dir ~= status.dir then
        status.prototype = prototype
        status.dir = new_dir
        status.srt.r = ROTATORS[new_dir]
        return true
    end
end

local function _update_grid_entity(grid_entity, status, typeobject, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local grid_position = icoord.position(status.x, status.y, w, h)
    grid_entity:set_position(_calc_grid_position(grid_position, typeobject, dir))
end

local function _update_pickup_components(check_coord, pickup_components, status, typeobject)
    local valid = check_coord(status.x, status.y, status.dir, typeobject)
    for _, c in pairs(pickup_components) do
        c:on_position_change(status.srt, status.dir)
        c:on_status_change(valid)
    end
end

local function touch_move(self, datamodel, delta_vec)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    local x, y = _align(self.position_type, typeobject.area, status.dir)
    if not x then
        return
    end
    status.x, status.y = x, y
    status.srt.t = math3d.add(status.srt.t, delta_vec)
    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    if _update_status(status, typeobject, x, y) then
        _update_indicator(indicator, status)
    end
    _update_grid_entity(self.grid_entity, status, typeobject, status.dir)
    _update_pickup_components(self.check_coord, self.pickup_components, status, typeobject)
end

local function touch_end(self, datamodel)
    local indicator = assert(self.indicator)
    local status = assert(self.status)
    local typeobject = assert(self.typeobject)

    local x, y, pos = _align(self.position_type, typeobject.area, status.dir)
    if not x then
        return
    end
    status.x, status.y, status.srt.t = x, y, pos
    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    if _update_status(status, typeobject, x, y) then
        _update_indicator(indicator, status)
    end
    _update_grid_entity(self.grid_entity, status, typeobject, status.dir)
    _update_pickup_components(self.check_coord, self.pickup_components, status, typeobject)
end

local function place(self, datamodel)
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

    local prototype, dir = iprototype_cache.get("pipe").MaskToPrototypeDir(typeobject.building_category, 0)
    local object = iobject.new {
        prototype_name = iprototype.queryById(prototype).name,
        dir = iprototype.dir_tostring(dir),
        x = status.x,
        y = status.y,
        srt = srt.new(status.srt),
        group_id = 0,
    }
    object.gameplay_eid = igameplay.create_entity(object)
    objects:set(object, "CONSTRUCTED")

    gameplay_core.set_changed(CHANGED_FLAG_BUILDING | CHANGED_FLAG_FLUIDFLOW)
end

local function clean(self, datamodel)
    self.grid_entity:remove()
    self.indicator:remove()
    for _, c in pairs(self.pickup_components) do
        c:remove()
    end
end

local function new(self, datamodel, typeobject, position_type)
    self.typeobject = typeobject
    self.position_type = position_type
    self.check_coord = get_check_coord(typeobject)

    local x, y, pos = _align(self.position_type, self.typeobject.area, DEFAULT_DIR)
    local prototype, dir = _get_placed_pipe(typeobject, x, y)
    self.status = {
        prototype = prototype,
        dir = dir,
        x = x,
        y = y,
        srt = srt.new {
            t = pos,
            r = ROTATORS[dir],
        },
    }
    local status = self.status

    self.indicator = igame_object.create {
        prefab = typeobject.model,
        srt = status.srt,
    }

    self.grid_entity = igrid_entity.create(MAP_WIDTH_COUNT, MAP_HEIGHT_COUNT, TILE_SIZE, TILE_SIZE, {t = _calc_grid_position(status.srt.t, typeobject, dir)})

    local valid = self.check_coord(status.x, status.y, status.dir, self.typeobject)

    self.pickup_components = {}
    self.pickup_components[#self.pickup_components + 1] = create_pickup_selection_box(status.srt.t, typeobject.area, dir, valid)
end

local function build(self, v)
    igameplay.create_entity(v)
end

local function create()
    local m = {}
    m.new = new
    m.touch_move = touch_move
    m.touch_end = touch_end
    m.confirm = place
    m.clean = clean
    m.build = build
    return m
end
return create