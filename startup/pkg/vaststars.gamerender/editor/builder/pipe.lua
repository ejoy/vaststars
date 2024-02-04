local ecs = ...
local world = ecs.world


local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local ALL_DIR <const> = CONSTANT.ALL_DIR
local ALL_DIR_NUM <const> = CONSTANT.ALL_DIR_NUM
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local CHANGED_FLAG_FLUIDFLOW <const> = CONSTANT.CHANGED_FLAG_FLUIDFLOW
local GRID_POSITION_OFFSET <const> = CONSTANT.GRID_POSITION_OFFSET
local EDITOR_CACHE_NAMES = {"CONFIRM", "CONSTRUCTED"}
local DIRECTION <const> = require "gameplay.interface.constant".DIRECTION

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
local ifluidbox = ecs.require "render_updates.fluidbox"
local iprototype_cache = ecs.require "prototype_cache"
local icamera_controller = ecs.require "engine.system.camera_controller"
local srt = require "utility.srt"
local iinventory = require "gameplay.interface.inventory"
local show_message = ecs.require "show_message".show_message

local function length(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function countNeighboringFluids(x, y)
    local fluids = {}
    for _, dir in ipairs(ALL_DIR) do
        local x, y = iprototype.move_coord(x, y, dir)
        local fluid = ifluidbox.get(x, y, iprototype.reverse_dir(dir))
        if fluid and fluid ~= 0 then
            fluids[fluid] = true
        end
    end
    return length(fluids)
end

local function _builder_init(self, datamodel)
    local indicator = self.indicator

    local valid = false
    local object = objects:coord(indicator.x, indicator.y, EDITOR_CACHE_NAMES)
    valid = (object == nil)

    if countNeighboringFluids(indicator.x, indicator.y) > 1 then
        valid = false
    end

    for _, c in pairs(self.pickup_components) do
        c:on_status_change(valid)
    end
end

local function _calc_grid_position(building_position, typeobject, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local _, originPosition = icoord.align(math3d.vector(0, 0, 0), w, h)
    return math3d.add(math3d.sub(building_position, originPosition), GRID_POSITION_OFFSET)
end

local function getPlacedPrototypeName(x, y, default_prototype_name, default_dir)
    local o = objects:coord(x, y, EDITOR_CACHE_NAMES)
    local prototype_name, dir
    if not o then
        prototype_name, dir = iflow_connector.cleanup(default_prototype_name, default_dir)
    else
        prototype_name, dir = default_prototype_name, default_dir
    end

    for _, d in ipairs(ALL_DIR) do
        local dx, dy = iprototype.move_coord(x, y, d)
        local o = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
        if o and iprototype.is_pipe(o.prototype_name) then
            prototype_name, dir = iflow_connector.set_connection(prototype_name, dir, d, true)
        end
    end
    return prototype_name, dir
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
    local prototype_name, dir = getPlacedPrototypeName(x, y, typeobject.name, dir)

    self.indicator = iobject.new {
        prototype_name = prototype_name,
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
    _builder_init(self, datamodel)
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
    local prototype_name, dir = getPlacedPrototypeName(x, y, self.typeobject.name, DEFAULT_DIR)
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

    local prototype_name, dir = getPlacedPrototypeName(self.indicator.x, self.indicator.y, self.typeobject.name, DEFAULT_DIR)
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

    _builder_init(self, datamodel)
end

local function place(self, datamodel)
    local indicator = self.indicator
    local x, y = indicator.x, indicator.y
    local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    if object then
        return
    end
    if countNeighboringFluids(x, y) > 1 then
        show_message("different fluids do not mix")
        return
    end

    local gameplay_world = gameplay_core.get_world()
    if iinventory.query(gameplay_world, self.typeobject.id) < 1 then
        show_message("item not enough")
        return
    end
    assert(iinventory.pickup(gameplay_world, self.typeobject.id, 1))

    --
    local m = 0
    for _, dir in ipairs(ALL_DIR_NUM) do
        local dx, dy = iprototype.move_coord(x, y, dir)
        local fluid = ifluidbox.get(dx, dy, iprototype.reverse_dir(dir))
        if fluid then
            m = m | (1 << dir)
        end
    end

    local typeobject = iprototype.queryByName("管道1-O型")
    local prototype, dir = iprototype_cache.get("pipe").MaskToPrototypeDir(typeobject.building_category, m)

    object = iobject.new {
        prototype_name = iprototype.queryById(prototype).name,
        dir = iprototype.dir_tostring(dir),
        x = x,
        y = y,
        srt = srt.new {
            t = math3d.vector(icoord.position(x, y, iprototype.rotate_area(typeobject.area, "N"))),
            r = ROTATORS["N"],
        },
        group_id = 0,
    }
    objects:set(object, "CONFIRM")

    local pending = {}
    pending[icoord.pack(object.x, object.y)] = object

    --
    for _, dir in ipairs(ALL_DIR_NUM) do
        local dx, dy = iprototype.move_coord(x, y, dir)
        local fluid = ifluidbox.get(dx, dy, iprototype.reverse_dir(dir))
        if fluid then
            local neighbor = assert(objects:coord(dx, dy, EDITOR_CACHE_NAMES))
            if iprototype.is_pipe(neighbor.prototype_name) then
                local m = iprototype_cache.get("pipe").PrototypeDirToMask(iprototype.queryByName(neighbor.prototype_name).id, DIRECTION[neighbor.dir])
                m = m | (1 << iprototype.reverse_dir(dir))
                local typeobject = iprototype.queryByName(neighbor.prototype_name)
                local prototype, dir = iprototype_cache.get("pipe").MaskToPrototypeDir(typeobject.building_category, m)
                local o = assert(objects:modify(dx, dy, {"CONFIRM", "CONSTRUCTED"}, iobject.clone))
                o.prototype_name = iprototype.queryById(prototype).name
                o.dir = iprototype.dir_tostring(dir)
                pending[icoord.pack(o.x, o.y)] = o
            elseif iprototype.is_pipe_to_ground(neighbor.prototype_name) then
                local m = iprototype_cache.get("pipe_to_ground").PrototypeDirToMask(iprototype.queryByName(neighbor.prototype_name).id, DIRECTION[neighbor.dir])
                m = m | (1 << (iprototype.reverse_dir(dir)*2))
                local typeobject = iprototype.queryByName(neighbor.prototype_name)
                local prototype, dir = iprototype_cache.get("pipe_to_ground").MaskToPrototypeDir(typeobject.building_category, m)
                local o = assert(objects:modify(dx, dy, {"CONFIRM", "CONSTRUCTED"}, iobject.clone))
                o.prototype_name = iprototype.queryById(prototype).name
                o.dir = iprototype.dir_tostring(dir)
                pending[icoord.pack(o.x, o.y)] = o
            end
        end
    end

    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.indicator)
    self.indicator = nil

    for _, object in pairs(pending) do
        local object_id = object.id
        local old = objects:get(object_id, {"CONSTRUCTED"})
        if not old then
            object.gameplay_eid = igameplay.create_entity(object)
        else
            if old.prototype_name ~= object.prototype_name then
                igameplay.destroy_entity(object.gameplay_eid)
                object.gameplay_eid = igameplay.create_entity(object)
            elseif old.dir ~= object.dir then
                igameplay.rotate(object.gameplay_eid, object.dir)
            end
        end
    end
    objects:commit("CONFIRM", "CONSTRUCTED")
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING | CHANGED_FLAG_FLUIDFLOW)

    self:clean(self, datamodel)
    _new_entity(self, datamodel, self.typeobject, x, y, object.srt.t, DEFAULT_DIR)
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