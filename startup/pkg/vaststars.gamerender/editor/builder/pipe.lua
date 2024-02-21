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
local EDITOR_CACHE_NAMES = {"CONFIRM", "CONSTRUCTED"}
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
local iflow_connector = require "gameplay.interface.flow_connector"
local objects = require "objects"
local igrid_entity = ecs.require "engine.grid_entity"
local icoord = require "coord"
local igameplay = ecs.require "gameplay.gameplay_system"
local gameplay_core = require "gameplay.core"
local create_pickup_selected_box = ecs.require "editor.indicators.pickup_selected_box"
local iprototype_cache = ecs.require "prototype_cache"
local icamera_controller = ecs.require "engine.system.camera_controller"
local srt = require "utility.srt"
local iinventory = require "gameplay.interface.inventory"
local show_message = ecs.require "show_message".show_message
local get_check_coord = ecs.require "editor.builder.common".get_check_coord
local ifluidbox = ecs.require "render_updates.fluidbox"

local function _update_indicator_status(self)
    local indicator = self.indicator
    local valid = self._check_coord(indicator.x, indicator.y, indicator.dir, self.typeobject)
    for _, c in pairs(self.pickup_components) do
        c:on_status_change(valid)
    end
end

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

local function align(position_type, area, dir)
    local p = icamera_controller.get_screen_world_position(position_type)
    local coord, pos = icoord.align(p, iprototype.rotate_area(area, dir))
    if not coord then
        return
    end
    return coord[1], coord[2], math3d.vector(pos)
end

local function _new_entity(self, datamodel, typeobject, x, y, pos, dir)
    assert(x and y)

    iobject.remove(self.indicator)
    local prototype, dir = _get_placed_pipe(typeobject, x, y)

    self.indicator = iobject.new {
        prototype_name = iprototype.queryById(prototype).name,
        dir = dir,
        x = x,
        y = y,
        srt = srt.new {
            t = pos,
            r = ROTATORS[dir],
        },
        group_id = 0,
    }

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create(MAP_WIDTH_COUNT, MAP_HEIGHT_COUNT, TILE_SIZE, TILE_SIZE, {t = _calc_grid_position(self.indicator.srt.t, typeobject, dir)})
    end

    self.pickup_components[#self.pickup_components + 1] = create_pickup_selected_box(self.indicator.srt.t, typeobject.area, dir, true)

    --
    _update_indicator_status(self)
end
--------------------------------------------------------------------------------------------------

local function touch_move(self, datamodel, delta_vec)
    if not self.indicator then
        return
    end
    iobject.move_delta(self.indicator, delta_vec)

    local indicator = self.indicator
    local typeobject = iprototype.queryByName(indicator.prototype_name)
    local x, y = align(self.position_type, typeobject.area, indicator.dir)
    if not x then
        return
    end
    local prototype, dir = _get_placed_pipe(typeobject, x, y)
    local prototype_name = iprototype.queryById(prototype).name
    if prototype_name ~= self.indicator.prototype_name or dir ~= self.indicator.dir then
        local srt = self.indicator.srt
        local x, y = self.indicator.x, self.indicator.y
        iobject.remove(self.indicator)
        self.indicator = iobject.new {
            prototype_name = prototype_name,
            dir = dir,
            x = x,
            y = y,
            srt = srt,
            group_id = 0,
        }
    end
    if self.grid_entity then
        local typeobject = iprototype.queryByName(self.indicator.prototype_name)
        local w, h = iprototype.rotate_area(typeobject.area, self.indicator.dir)
        local grid_position = icoord.position(self.indicator.x, self.indicator.y, w, h)
        self.grid_entity:set_position(_calc_grid_position(grid_position, typeobject, self.indicator.dir))
    end
    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.indicator.srt, self.indicator.dir)
    end
end

local function touch_end(self, datamodel)
    if not self.indicator then
        return
    end

    local x, y, pos = align(self.position_type, self.typeobject.area, self.indicator.dir)
    if not x then
        return
    end

    self.indicator.srt.t, self.indicator.x, self.indicator.y = pos, x, y

    local prototype, dir = _get_placed_pipe(self.typeobject, self.indicator.x, self.indicator.y)
    local prototype_name = iprototype.queryById(prototype).name
    if prototype_name ~= self.indicator.prototype_name or dir ~= self.indicator.dir then
        local x, y = self.indicator.x, self.indicator.y
        iobject.remove(self.indicator)
        self.indicator = iobject.new {
            prototype_name = prototype_name,
            dir = dir,
            x = x,
            y = y,
            srt = srt.new {
                t = math3d.vector(icoord.position(x, y, iprototype.rotate_area(self.typeobject.area, dir))),
                r = ROTATORS[dir],
            },
            group_id = 0,
        }
    end

    if self.grid_entity then
        local typeobject = iprototype.queryByName(self.indicator.prototype_name)
        local w, h = iprototype.rotate_area(typeobject.area, self.indicator.dir)
        local grid_position = icoord.position(self.indicator.x, self.indicator.y, w, h)
        self.grid_entity:set_position(_calc_grid_position(grid_position, typeobject, self.indicator.dir))
    end

    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.indicator.srt, self.indicator.dir)
    end

    _update_indicator_status(self)
end

local function place(self, datamodel)
    local indicator = self.indicator
    local x, y = indicator.x, indicator.y
    local typeobject = self.typeobject

    local succ, msg = self._check_coord(x, y, indicator.dir, typeobject)
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
    local d = iprototype.dir_tostring(dir)
    local object = iobject.new {
        prototype_name = iprototype.queryById(prototype).name,
        dir = iprototype.dir_tostring(dir),
        x = x,
        y = y,
        srt = srt.new {
            t = math3d.vector(icoord.position(x, y, iprototype.rotate_area(typeobject.area, d))),
            r = ROTATORS[d],
        },
        group_id = 0,
    }
    object.gameplay_eid = igameplay.create_entity(object)
    objects:set(object, "CONSTRUCTED")

    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.indicator)
    self.indicator = nil

    gameplay_core.set_changed(CHANGED_FLAG_BUILDING | CHANGED_FLAG_FLUIDFLOW)

    self:clean(self, datamodel)
    _new_entity(self, datamodel, typeobject, x, y, object.srt.t, DEFAULT_DIR)
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.indicator)
    self.indicator = nil

    for _, c in pairs(self.pickup_components) do
        c:remove()
    end
    self.pickup_components = {}
end

local function new(self, datamodel, typeobject, position_type)
    self.typeobject = typeobject
    self.position_type = position_type
    self._check_coord = get_check_coord(typeobject)

    local x, y, pos = align(self.position_type, self.typeobject.area, DEFAULT_DIR)
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
    m.confirm = place
    m.clean = clean
    m.build = build
    m.pickup_components = {}
    return m
end
return create