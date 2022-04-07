local ecs = ...
local world = ecs.world
local w = world.w

local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local math3d = require "math3d"

local channel_state = require "channel_state"
local terrain = ecs.require "terrain"
local camera = ecs.require "camera"
local general = require "common.general"
local packcoord = general.packcoord
local unpackarea = general.unpackarea
local rotate_area = general.rotate_area
local opposite_dir = general.opposite_dir
local dir_tonumber = general.dir_tonumber
local rotate_dir_times = general.rotate_dir_times
local get_fluidboxes = ecs.require "common.get_fluidboxes"
local vsobject_manager = ecs.require "vsobject_manager"
local create_map = require "common.patchmap"
local gameplay_core = ecs.require "gameplay.core"

local CONSTRUCT_RED_BASIC_COLOR <const> = math3d.ref(math3d.constant("v4", {50.0, 0.0, 0.0, 0.8}))
local CONSTRUCT_GREEN_BASIC_COLOR <const> = math3d.ref(math3d.constant("v4", {0.0, 50.0, 0.0, 0.8}))
local CONSTRUCT_WHITE_BASIC_COLOR <const> = math3d.ref(math3d.constant("v4", {50.0, 50.0, 50.0, 0.8}))
local DISMANTLE_YELLOW_BASIC_COLOR <const> = math3d.ref(math3d.constant("v4", {50.0, 50.0, 0.0, 0.8}))

local CONSTRUCT_BLOCK_RED_BASIC_COLOR <const> = math3d.ref(math3d.constant("v4", {20000, 0.0, 0.0, 1.0}))
local CONSTRUCT_BLOCK_GREEN_BASIC_COLOR <const> = math3d.ref(math3d.constant("v4", {0.0, 20000, 0.0, 1.0}))
local DEFAULT_DIR <const> = 'N'

local M = {}
local pickup_object

local objects = create_map() -- = {[id] = object, ...}
local tile_objects = create_map() -- = {[coord] = {id = xx, fluidbox_dir = {[xx] = true, ...}}, ...}

local function check_construct_detector(prototype_name, x, y, dir, id)
    local typeobject = gameplay.queryByName("entity", prototype_name)
    local construct_detector = typeobject.construct_detector
    if not construct_detector then
        return true
    end

    local w, h = rotate_area(typeobject.area, dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local tile_object = tile_objects:get(packcoord(x + i, y + j))
            if tile_object then
                if not id then
                    return false
                else
                    if tile_object.id ~= id then
                        return false
                    end
                end
            end
        end
    end
    return true
end

-- object = {id = xx, prototype_name = xx, dir = xx, fluid = xx, x = xx, y = xx}
local function set_tile_object(object)
    local t = {}

    --
    local typeobject = gameplay.queryByName("entity", object.prototype_name)
    local w, h = rotate_area(typeobject.area, object.dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            t[packcoord(object.x + i, object.y + j)] = {id = object.id}
        end
    end

    --
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        t[packcoord(v.x, v.y)].fluidbox_dir = v.fluidbox_dir
    end

    --
    for coord, tile_object in pairs(t) do
        tile_objects:set(coord, tile_object)
    end

    objects:set(object.id, object)
end

local fluidbox_dir_coord = {
    ['N'] = {x = 0,  y = -1},
    ['E'] = {x = 1,  y = 0},
    ['S'] = {x = 0,  y = 1},
    ['W'] = {x = -1, y = 0},
}

local function refresh_pipe(x, y)
    local tile_object = tile_objects:get(packcoord(x, y))
    if not tile_object then
        return
    end

    local object = assert(objects:get(tile_object.id))
    local typeobject = gameplay.queryByName("entity", object.prototype_name)
    if not typeobject.pipe then
        return
    end

    local passable_state = 0
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local c = fluidbox_dir_coord[dir]
            local dx, dy = v.x + c.x, v.y + c.y
            local tile_object = tile_objects:get(packcoord(dx, dy))
            if tile_object and tile_object.fluidbox_dir then
                if tile_object.fluidbox_dir[opposite_dir(dir)] then
                    passable_state = channel_state.set_passable_state(passable_state, dir_tonumber(dir), 1)
                end
            end
        end
    end

    local channel_type, dir = channel_state.to_channel_type_dir(passable_state)
    return object.prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(channel_type)), dir
end

local function refresh_pickup_pipe()
    assert(pickup_object)
    local prototype_name, dir = refresh_pipe(pickup_object.x, pickup_object.y)
    if prototype_name then
        local vsobject = assert(vsobject_manager:get(pickup_object.id))
        vsobject:update {prototype_name = prototype_name}
        vsobject:set_dir(dir)

        pickup_object.prototype_name = prototype_name
        pickup_object.dir = dir
    end
end

local function refresh_pipe_connection()
    for _, v in ipairs(get_fluidboxes(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local c = fluidbox_dir_coord[dir]
            local dx, dy = v.x + c.x, v.y + c.y

            local prototype_name, dir = refresh_pipe(dx, dy)
            if prototype_name then
                local tile_object = assert(tile_objects:get(packcoord(dx, dy)))
                local object = assert(objects:get(tile_object.id))

                local vsobject = assert(vsobject_manager:get(tile_object.id))
                vsobject:update {prototype_name = prototype_name}
                vsobject:set_dir(dir)

                set_tile_object {
                    id = object.id,
                    prototype_name = prototype_name,
                    dir = dir,
                    fluid = object.fluid,
                    x = object.x,
                    y = object.y,
                }
            end
        end
    end
end

local function revert_temporary()
    -- 还原由于拖动而变更的水管形状
    tile_objects:revert_temporary()
    for id, object in pairs(objects:revert_temporary()) do
        if id ~= pickup_object.id then
            local vsobject = assert(vsobject_manager:get(object.id))
            local old_object = assert(objects:get(id))
            vsobject:update {prototype_name = old_object.prototype_name}
            vsobject:set_dir(old_object.dir)
        end
    end
end

local function show_new_object(prototype_name, dir)
    local typeobject = gameplay.queryByName("entity", prototype_name)
    local coord = terrain.adjust_position(camera.get_central_position(), typeobject.area)
    local color, block_color, need_set_tile_object
    if not check_construct_detector(prototype_name, coord[1], coord[2], DEFAULT_DIR) then
        color = CONSTRUCT_RED_BASIC_COLOR
        block_color = CONSTRUCT_BLOCK_RED_BASIC_COLOR
    else
        color = CONSTRUCT_GREEN_BASIC_COLOR
        block_color = CONSTRUCT_BLOCK_GREEN_BASIC_COLOR
        need_set_tile_object = true
    end

    local vsobject = vsobject_manager:create {
        prototype_name = prototype_name,
        dir = dir,
        x = coord[1],
        y = coord[2],
        state = "opaque",
        color = color,
        block_color = block_color,
    }
    pickup_object = {
        id = vsobject.id,
        prototype_name = prototype_name,
        dir = dir,
        fluid = {},
        x = coord[1],
        y = coord[2],
    }

    if need_set_tile_object then
        set_tile_object(pickup_object)
    end
    return pickup_object
end

function M:new_pickup_object(prototype_name)
    if pickup_object then
        if pickup_object.prototype_name == prototype_name then
            return
        end

        revert_temporary()
        vsobject_manager:remove(pickup_object.id)
    end

    pickup_object = show_new_object(prototype_name, DEFAULT_DIR)
end

function M:confirm()
    if not pickup_object then
        return
    end

    if not check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.id) then
        print("can not construct")
        return
    end

    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    vsobject:update {state = "translucent", color = CONSTRUCT_WHITE_BASIC_COLOR, show_block = false}
    tile_objects:commit_temporary()
    objects:commit_temporary()

    pickup_object = show_new_object(pickup_object.prototype_name, pickup_object.dir)

    -- 显示"开始施工"
    world:pub {"ui_message", "show_construct_complete", true}
end

function M:adjust_pickup_object()
    if not pickup_object then
        return
    end

    revert_temporary()

    --
    local typeobject = gameplay.queryByName("entity", pickup_object.prototype_name)
    local coord, position = terrain.adjust_position(camera.get_central_position(), typeobject.area)
    pickup_object.x, pickup_object.y = coord[1], coord[2]

    local color, block_color
    if not check_construct_detector(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir) then
        color = CONSTRUCT_RED_BASIC_COLOR
        block_color = CONSTRUCT_BLOCK_RED_BASIC_COLOR
        refresh_pickup_pipe()
    else
        color = CONSTRUCT_GREEN_BASIC_COLOR
        block_color = CONSTRUCT_BLOCK_GREEN_BASIC_COLOR

        set_tile_object(pickup_object)
        refresh_pickup_pipe()
        refresh_pipe_connection()
    end

    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    vsobject:set_position(position)
    vsobject:update {color = color, block_color = block_color}
end

function M:rotate_pickup_object()
    if not pickup_object then
        return
    end

    revert_temporary()

    --
    pickup_object.dir = rotate_dir_times(pickup_object.dir, -1)

    --
    local color, block_color
    if not check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        color = CONSTRUCT_RED_BASIC_COLOR
        block_color = CONSTRUCT_BLOCK_RED_BASIC_COLOR
        refresh_pickup_pipe()
    else
        color = CONSTRUCT_GREEN_BASIC_COLOR
        block_color = CONSTRUCT_BLOCK_GREEN_BASIC_COLOR

        set_tile_object(pickup_object)
        refresh_pickup_pipe()
        refresh_pipe_connection()
    end

    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    vsobject:set_dir(pickup_object.dir)
    vsobject:update {color = color, block_color = block_color}
end

function M:complete()
    if pickup_object then
        vsobject_manager:remove(pickup_object.id)
        pickup_object = nil
    end

    local needbuild = false
    tile_objects:commit_confirm()
    for _, object in pairs(objects:commit_confirm()) do
        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {state = "opaque"}
        gameplay_core.create_entity(object)
        needbuild = true
    end

    if needbuild then
        gameplay_core.build()
    end
end

function M:reset()
    objects = create_map()
    tile_objects = create_map()
end

function M:get_vsobject(x, y)
    local tile_object = tile_objects:get(packcoord(x, y))
    assert(tile_object)
    local vsobject = vsobject_manager:get(tile_object.id)
    assert(vsobject)
    return vsobject
end

return M