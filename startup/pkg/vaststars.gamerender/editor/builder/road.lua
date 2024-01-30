local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local ROAD_SIZE <const> = CONSTANT.ROAD_SIZE
local MAP_WIDTH <const> = CONSTANT.MAP_WIDTH
local MAP_HEIGHT <const> = CONSTANT.MAP_HEIGHT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local CHANGED_FLAG_ROADNET <const> = CONSTANT.CHANGED_FLAG_ROADNET
local DIRECTION <const> = CONSTANT.DIRECTION
local WORLD_MOVE_DELTA <const> = {
    ['N'] = {x = 0,  y = 1},
    ['E'] = {x = 1,  y = 0},
    ['S'] = {x = 0,  y = -1},
    ['W'] = {x = -1, y = 0},
    [DIRECTION.N] = {x = 0,  y = 1},
    [DIRECTION.E] = {x = 1,  y = 0},
    [DIRECTION.S] = {x = 0,  y = -1},
    [DIRECTION.W] = {x = -1, y = 0},
}

local math3d = require "math3d"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local icoord = require "coord"
local task = ecs.require "task"
local iroadnet_converter = require "roadnet_converter"
local igrid_entity = ecs.require "engine.grid_entity"
local iroadnet = ecs.require "engine.roadnet"
local gameplay_core = require "gameplay.core"
local create_pickup_selected_box = ecs.require "editor.indicators.pickup_selected_box"
local iinstance_object = ecs.require "engine.instance_object"
local ibuilding = ecs.require "render_updates.building"
local icamera_controller = ecs.require "engine.system.camera_controller"
local iroad = ecs.require "vaststars.gamerender|render_updates.road"
local imountain = ecs.require "engine.mountain"
local iinventory = require "gameplay.interface.inventory"
local iom = ecs.require "ant.objcontroller|obj_motion"
local srt = require "utility.srt"
local imineral = ecs.require "mineral"
local playback = ecs.require "ant.animation|playback"
local igame_object = ecs.require "engine.game_object"

local function _is_valid_road_coord(x, y)
    for i = 0, ROAD_SIZE - 1 do
        for j = 0, ROAD_SIZE - 1 do
            local object = objects:coord(x + i, y + j)
            if object then
                return false
            end

            if imineral.get(x + i, y + j) then
                return false
            end

            if imountain:has_mountain(x + i, y + j) then
                return false
            end
        end
    end
    return true
end

local function _update_components_status(self)
    local status = self.status
    local show_confirm = _is_valid_road_coord(status.x, status.y)
    for _, c in pairs(self.pickup_components) do
        c:on_status_change(show_confirm)
    end
end

local function _update_components_position(self)
    local status = self.status
    for _, c in pairs(self.pickup_components) do
        c:on_position_change(status.srt, status.dir)
    end
end

local function _align(position, area, dir)
    local coord = icoord.align(position, iprototype.rotate_area(area, dir))
    if not coord then
        return
    end
    coord[1], coord[2] = icoord.road_coord(coord[1], coord[2])
    local t = math3d.vector(icoord.position(coord[1], coord[2], iprototype.rotate_area(area, dir)))
    return t, coord[1], coord[2]
end

local function _set_road(x, y, mask)
    local prototype_name, dir = iroadnet_converter.mask_to_prototype_name_dir(mask)
    ibuilding.set {
        x = x,
        y = y,
        prototype_name = prototype_name,
        direction = dir,
        road = true,
    }
    local shape, dir = iroadnet_converter.mask_to_shape_dir(mask)
    iroadnet:set("road", x, y, 0xffffffff, shape, dir)
end

local function _get_road(x, y)
    local road = ibuilding.get(x, y)
    if not road then
        return
    end
    return iroadnet_converter.prototype_name_dir_to_mask(road.prototype, road.direction)
end

local function _get_placed_road_prototype_name(x, y, default_prototype_name, default_dir)
    if not _is_valid_road_coord(x, y) then
        return default_prototype_name, default_dir
    end

    local mask = _get_road(x, y) or 0
    for _, dir in ipairs(CONSTANT.ALL_DIR_NUM) do
        local dx, dy = iprototype.move_coord(x, y, dir, ROAD_SIZE, ROAD_SIZE)
        local m = _get_road(dx, dy)
        if m and not iroad.check(mask, dir) then
            mask = iroad.open(mask, dir)
        end
    end

    return iroadnet_converter.mask_to_prototype_name_dir(mask)
end

local function _new_entity(self, datamodel, typeobject, x, y)
    local prototype_name, dir = _get_placed_road_prototype_name(x, y, typeobject.name, DEFAULT_DIR)
    self.status = {
        x = x,
        y = y,
        dir = dir,
        srt = srt.new {
            t = math3d.vector(icoord.position(x, y, iprototype.rotate_area(typeobject.area, dir))),
            r = ROTATORS[dir],
        },
        prototype_name = prototype_name,
    }

    local status = self.status

    if self.indicator then
        self.indicator:remove()
    end
    self.indicator = igame_object.create {
        prefab = typeobject.model,
        group_id = 0,
        srt = status.srt,
    }

    if not self.pickup_components.grid_entity then
        local position = _align(status.srt.t, iprototype.packarea(8 * ROAD_SIZE, 8 * ROAD_SIZE), dir)
        position = math3d.add(position, GRID_POSITION_OFFSET)
        local offset = math3d.sub(status.srt.t, position)
        self.pickup_components.grid_entity = igrid_entity.create(
            MAP_WIDTH // ROAD_SIZE,
            MAP_HEIGHT // ROAD_SIZE,
            TILE_SIZE * ROAD_SIZE,
            {t = status.srt.t},
            offset,
            nil,
            self.position_type
        )
    end
    if not self.pickup_components.selected_box then
        self.pickup_components.selected_box = create_pickup_selected_box(status.srt.t, typeobject.area, dir, true)
    end
    if not self.pickup_components.next_box then
        local dx, dy = iprototype.move_coord(x, y, self.forward_dir, ROAD_SIZE)
        self.pickup_components.next_box = iinstance_object.create(world:create_instance {
            prefab = "/pkg/vaststars.resources/glbs/road/road_indicator.glb|mesh.prefab",
            on_ready = function (instance)
                local root <close> = world:entity(instance.tag['*'][1])
                iom.set_position(root, math3d.vector(icoord.position(dx, dy, iprototype.rotate_area(typeobject.area, dir))))
                iom.set_rotation(root, ROTATORS[self.forward_dir])

                for _, eid in ipairs(instance.tag["*"]) do
                    local e <close> = world:entity(eid, "animation?in")
                    if e.animation then
                        playback.set_play(e, "Armature.002Action", true)
                        playback.set_loop(e, "Armature.002Action", true)
                    end
                end
            end,
            on_message = function (instance, msg, ...)
                if msg == "on_position_change" then
                    local building_srt = ...
                    local position = building_srt.t
                    local delta = WORLD_MOVE_DELTA[self.forward_dir]
                    local x, z = math3d.index(position, 1) + delta.x * TILE_SIZE * ROAD_SIZE, math3d.index(position, 3) + delta.y * TILE_SIZE * ROAD_SIZE

                    local root <close> = world:entity(instance.tag['*'][1])
                    iom.set_position(root, math3d.vector(x, math3d.index(position, 2), z))
                    iom.set_rotation(root, ROTATORS[self.forward_dir])
                end
            end
        }, {"on_position_change", "on_status_change", "set_forward_dir"})
    end

    datamodel.show_rotate = true
    --
    _update_components_position(self)
    _update_components_status(self)
end
--------------------------------------------------------------------------------------------------
local function touch_move(self, datamodel, delta_vec)
    local indicator = assert(self.indicator)
    local typeobject = assert(self.typeobject)
    local status = assert(self.status)

    indicator:send("obj_motion", "set_position", math3d.live(math3d.add(status.srt.t, delta_vec)))

    local pos = icamera_controller.get_screen_world_position(self.position_type)
    local _, x, y = _align(pos, self.typeobject.area, status.dir)
    local prototype_name, dir = _get_placed_road_prototype_name(x, y, typeobject.name, DEFAULT_DIR)
    if prototype_name ~= status.prototype_name or dir ~= status.dir then
        status.x, status.y, status.dir = x, y, dir

        if self.indicator then
            self.indicator:remove()
        end
        self.indicator = igame_object.create {
            prefab = iprototype.queryByName(prototype_name).model,
            group_id = 0,
            srt = status.srt,
        }
    end
    _update_components_position(self)
end

local function touch_end(self, datamodel)
    local indicator = assert(self.indicator)
    local status = assert(self.status)

    local typeobject = iprototype.queryByName(status.prototype_name)
    local pos = icamera_controller.get_screen_world_position(self.position_type)
    status.srt.t, status.x, status.y = _align(pos, typeobject.area, status.dir)

    indicator:send("obj_motion", "set_position", math3d.live(status.srt.t))

    local prototype_name, dir = _get_placed_road_prototype_name(status.x, status.y, self.typeobject.name, DEFAULT_DIR)
    if prototype_name ~= status.prototype_name or dir ~= status.dir then
        status.srt.r = ROTATORS[dir]

        if self.indicator then
            self.indicator:remove()
        end
        self.indicator = igame_object.create {
            prefab = iprototype.queryByName(prototype_name).model,
            group_id = 0,
            srt = status.srt,
        }
    end

    _update_components_position(self)
    _update_components_status(self)
    return false
end

local function place(self, datamodel)
    local typeobject = assert(self.typeobject)
    local status = assert(self.status)

    if not _is_valid_road_coord(status.x, status.y) then
        return
    end
    icoord.assert_road_coord(status.x, status.y)

    local mask = _get_road(status.x, status.y)
    if not mask then
        local gameplay_world = gameplay_core.get_world()
        if iinventory.query(gameplay_world, self.typeobject.id) < 1 then
            return
        end
        assert(iinventory.pickup(gameplay_world, self.typeobject.id, 1))

        mask = 0
    end

    _set_road(status.x, status.y, mask)
    gameplay_core.set_changed(CHANGED_FLAG_ROADNET)

    local dx, dy = iprototype.move_coord(status.x, status.y, self.forward_dir, ROAD_SIZE)
    icamera_controller.focus_on_position("RIGHT_CENTER", math3d.vector(icoord.position(dx, dy, ROAD_SIZE, ROAD_SIZE)), function ()
        if self.destroy then
            return
        end
        _new_entity(self, datamodel, self.typeobject, dx, dy)
    end)

    iinventory.pickup(gameplay_core.get_world(), typeobject.id, 1)
    task.update_progress("is_road_connected")
end

local function clean(self, datamodel)
    self.destroy = true
    if self.indicator then
        self.indicator:remove()
    end
    self.indicator = nil

    for _, c in pairs(self.pickup_components) do
        c:remove()
    end
    self.pickup_components = {}

    datamodel.show_rotate = false
end

local function rotate(self)
    local status = assert(self.status)
    self.forward_dir = iprototype.rotate_dir_times(self.forward_dir, -1)
    for _, c in pairs(self.pickup_components) do
        if c.set_forward_dir then
            c:set_forward_dir(self.forward_dir)
            c:on_position_change(status.srt, status.dir)
        end
    end
end

local function new(self, datamodel, typeobject, position_type)
    self.typeobject = typeobject
    self.position_type = position_type

    local coord = assert(icoord.position2coord(icamera_controller.get_screen_world_position(position_type)))
    local x, y = icoord.road_coord(coord[1], coord[2])
    _new_entity(self, datamodel, typeobject, x, y)
end

local function build(self, v)
    error("not implement")
end

local function create()
    local m = {}
    m.new = new
    m.touch_move = touch_move
    m.touch_end = touch_end
    m.rotate = rotate
    m.confirm = place
    m.clean = clean
    m.build = build
    m.destroy = false
    m.pickup_components = {}
    m.typeobject = nil
    m.forward_dir = DEFAULT_DIR
    m.status = {}
    return m
end
return create