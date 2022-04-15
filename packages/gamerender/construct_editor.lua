local ecs = ...
local world = ecs.world

local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local math3d = require "math3d"

local flow_shape = require "gameplay.utility.flow_shape"
local terrain = ecs.require "terrain"
local camera = ecs.require "camera"
local general = require "gameplay.utility.general"
local packcoord = general.packcoord
local rotate_area = general.rotate_area
local opposite_dir = general.opposite_dir
local dir_tonumber = general.dir_tonumber
local rotate_dir_times = general.rotate_dir_times
local get_fluidboxes = ecs.require "gameplay.utility.get_fluidboxes"
local has_fluidboxes = ecs.require "gameplay.utility.has_fluidboxes"
local vsobject_manager = ecs.require "vsobject_manager"
local create_cache = require "utility.multiple_cache"
local gameplay_core = ecs.require "gameplay.core"

local DEFAULT_DIR <const> = 'N'

local M = {}
local pickup_object

local cache_names = {"TEMPORARY", "CONFIRM", "EXISTING"}
local objects_index_field = {"id", "teardown"}
local tile_objects_index_field = {"coord", "id"}

local objects = create_cache(cache_names, table.unpack(objects_index_field)) -- = {[id] = object, ...}
local tile_objects = create_cache(cache_names, table.unpack(tile_objects_index_field)) -- = {[coord] = {id = xx, fluidbox_dir = {[xx] = true, ...}}, ...}

local get_fluidbox_coord; do
    local fluidbox_dir_coord = {
        ['N'] = {x = 0,  y = -1},
        ['E'] = {x = 1,  y = 0},
        ['S'] = {x = 0,  y = 1},
        ['W'] = {x = -1, y = 0},
    }
    function get_fluidbox_coord(x, y, dir)
        local c = assert(fluidbox_dir_coord[dir])
        return x + c.x, y + c.y
    end
end

local function get_neighbor_fluid_types(prototype_name, x, y, dir)
    local fluid_types = {}
    for _, v in ipairs(get_fluidboxes(prototype_name, x, y, dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local dx, dy = get_fluidbox_coord(v.x, v.y, dir)
            local tile_object = tile_objects:get(cache_names, packcoord(dx, dy))
            if tile_object and tile_object.fluidbox_dir then
                if tile_object.fluidbox_dir[opposite_dir(dir)] then
                    local object = assert(objects:get(cache_names, tile_object.id))
                    local fluid = object.fluid[1]
                    if fluid then
                        fluid_types[fluid] = true
                    end
                end
            end
        end
    end

    local array = {}
    for fluid in pairs(fluid_types) do
        array[#array + 1] = fluid
    end
    return array
end

local function check_construct_detector(prototype_name, x, y, dir, id)
    local typeobject = gameplay.queryByName("entity", prototype_name)
    local construct_detector = typeobject.construct_detector
    if not construct_detector then
        return true
    end

    local w, h = rotate_area(typeobject.area, dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local tile_object = tile_objects:get(cache_names, packcoord(x + i, y + j))
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

    local fluid_types = get_neighbor_fluid_types(prototype_name, x, y, dir)
    if #fluid_types > 1 then
        return false
    end

    return true
end

local function clone_object(object)
    return {
        id = object.id,
        vsobject_type = object.vsobject_type,
        prototype_name = object.prototype_name,
        dir = object.dir,
        fluid = object.fluid,
        x = object.x,
        y = object.y,
        teardown = object.teardown,
    }
end

-- object = {id = xx, prototype_name = xx, dir = xx, fluid = xx, x = xx, y = xx}
local function set_tile_object(object)
    local t = {}

    --
    local typeobject = gameplay.queryByName("entity", object.prototype_name)
    local w, h = rotate_area(typeobject.area, object.dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local coord = packcoord(object.x + i, object.y + j)
            t[coord] = {id = object.id, coord = coord}
        end
    end

    --
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        t[packcoord(v.x, v.y)].fluidbox_dir = v.fluidbox_dir
    end

    --
    for _, tile_object in pairs(t) do
        tile_objects:set("TEMPORARY", tile_object)
    end

    objects:set("TEMPORARY", object)
end

local function refresh_pipe(x, y)
    local tile_object = tile_objects:get(cache_names, packcoord(x, y))
    if not tile_object then
        return
    end

    local object = assert(objects:get(cache_names, tile_object.id))
    local typeobject = gameplay.queryByName("entity", object.prototype_name)
    if not typeobject.pipe then
        return
    end

    local state = 0
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local dx, dy = get_fluidbox_coord(v.x, v.y, dir)
            local tile_object = tile_objects:get(cache_names, packcoord(dx, dy))
            if tile_object and tile_object.fluidbox_dir then
                if tile_object.fluidbox_dir[opposite_dir(dir)] then
                    state = flow_shape.set_state(state, dir_tonumber(dir), 1)
                end
            end
        end
    end

    local ntype, dir = flow_shape.to_type_dir(state)
    return object.prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(ntype)), dir
end

local function refresh_pickup_pipe()
    assert(pickup_object)
    local typeobject = gameplay.queryByName("entity", pickup_object.prototype_name)
    if not typeobject.pipe then
        return
    end

    local prototype_name, dir = refresh_pipe(pickup_object.x, pickup_object.y)
    if prototype_name then
        local vsobject = assert(vsobject_manager:get(pickup_object.id))
        vsobject:update {prototype_name = prototype_name}
        vsobject:set_dir(dir)

        pickup_object.prototype_name = prototype_name
        pickup_object.dir = dir
    end
end

local function refresh_pipe_connection(object)
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local dx, dy = get_fluidbox_coord(v.x, v.y, dir)
            local prototype_name, dir = refresh_pipe(dx, dy)
            if prototype_name then
                local tile_object = assert(tile_objects:get(cache_names, packcoord(dx, dy)))

                local vsobject = assert(vsobject_manager:get(tile_object.id))
                vsobject:update {prototype_name = prototype_name}
                vsobject:set_dir(dir)

                local object = clone_object(assert(objects:get(cache_names, tile_object.id)))
                object.prototype_name = prototype_name
                object.dir = dir

                set_tile_object(object)
            end
        end
    end
end

local function revert_changes(revert_cache_names)
    local t = {}
    for _, cache_name in ipairs(revert_cache_names) do
        for id, object in objects:all(cache_name) do
            t[id] = object
        end
        objects:revert({cache_name})
        tile_objects:revert({cache_name})
    end

    local pickup_object_id
    if pickup_object then
        pickup_object_id = pickup_object.id
    end

    for id, object in pairs(t) do
        if id ~= pickup_object_id then
            local old_object = objects:get(cache_names, id)
            if old_object then
                local vsobject = assert(vsobject_manager:get(object.id))
                vsobject:update {prototype_name = old_object.prototype_name, type = old_object.vsobject_type}
                vsobject:set_dir(old_object.dir)
            else
                -- 通常是删除已"确定建造"的建筑
                local vsobject = vsobject_manager:get(object.id) --TODO 找不到 object
                if vsobject then
                    vsobject:remove()
                end
            end
        end
    end
end

local function new_pickup_object(prototype_name, dir, coord)
    local vsobject_type, need_set_tile_object
    if not check_construct_detector(prototype_name, coord[1], coord[2], dir) then
        vsobject_type = "invalid_construct"
        need_set_tile_object = false
    else
        vsobject_type = "construct"
        need_set_tile_object = true
    end

    local typeobject = gameplay.queryByName("entity", prototype_name)
    local position = terrain.get_position_by_coord(coord[1], coord[2], rotate_area(typeobject.area, dir))
    if not position then --TODO 越界?
        return
    end

    local vsobject = vsobject_manager:create {
        prototype_name = prototype_name,
        dir = dir,
        position = position,
        type = vsobject_type,
    }
    pickup_object = {
        id = vsobject.id,
        vsobject_type = vsobject_type,
        prototype_name = prototype_name,
        dir = dir,
        fluid = {},
        x = coord[1],
        y = coord[2],
        teardown = false,
    }

    if need_set_tile_object then
        set_tile_object(pickup_object)

        -- 针对流体盒子的特殊处理
        world:pub {"ui_message", "show_set_fluidbox", has_fluidboxes(prototype_name)}
    end

    return pickup_object
end

---
function M:construct_begin()
    revert_changes({"TEMPORARY"})
end

function M:new_pickup_object(prototype_name)
    if pickup_object then
        if pickup_object.prototype_name == prototype_name then
            return
        end

        revert_changes({"TEMPORARY"})
        vsobject_manager:remove(pickup_object.id)
    end

    local typeobject = gameplay.queryByName("entity", prototype_name)
    local coord = terrain.adjust_position(camera.get_central_position(), rotate_area(typeobject.area, DEFAULT_DIR))
    pickup_object = new_pickup_object(prototype_name, DEFAULT_DIR, coord)
end

function M:confirm()
    if not pickup_object then
        return
    end

    if not check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.id) then
        print("can not construct")
        return
    end

    -- 针对流体盒子的特殊处理
    if has_fluidboxes(pickup_object.prototype_name) then
        if not pickup_object.fluid[1] then
            print("set fluid first")
            return
        end
        world:pub {"ui_message", "show_set_fluidbox", false}
    end

    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    vsobject:update {type = "confirm"}
    pickup_object.vsobject_type = "confirm"

    objects:commit("TEMPORARY", "CONFIRM")
    tile_objects:commit("TEMPORARY", "CONFIRM")

    pickup_object = new_pickup_object(pickup_object.prototype_name, pickup_object.dir, {pickup_object.x, pickup_object.y})

    -- 显示"开始施工"
    world:pub {"ui_message", "show_construct_complete", true}
end

function M:adjust_pickup_object()
    if not pickup_object then
        return
    end

    revert_changes({"TEMPORARY"})

    --
    local typeobject = gameplay.queryByName("entity", pickup_object.prototype_name)
    local coord, position = terrain.adjust_position(camera.get_central_position(), rotate_area(typeobject.area, pickup_object.dir))
    if not coord then
        return
    end
    pickup_object.x, pickup_object.y = coord[1], coord[2]

    local vsobject_type
    if not check_construct_detector(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir) then
        vsobject_type = "invalid_construct"
        refresh_pickup_pipe()

        -- 针对流体盒子的特殊处理
        if has_fluidboxes(pickup_object.prototype_name) then
            pickup_object.fluid = {}
            world:pub {"ui_message", "show_set_fluidbox", false}
        end
    else
        vsobject_type = "construct"

        set_tile_object(pickup_object)
        refresh_pickup_pipe()
        refresh_pipe_connection(pickup_object)

        -- 针对流体盒子的特殊处理
        if has_fluidboxes(pickup_object.prototype_name) then
            local fluid_types = get_neighbor_fluid_types(pickup_object.prototype_name, coord[1], coord[2], pickup_object.dir)
            assert(#fluid_types <= 1)
            if #fluid_types == 1 then
                pickup_object.fluid = {assert(fluid_types[1]), 0}
                world:pub {"ui_message", "show_set_fluidbox", false}
            else
                pickup_object.fluid = {}
                world:pub {"ui_message", "show_set_fluidbox", true}
            end
        end
    end

    pickup_object.vsobject_type = vsobject_type

    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    vsobject:set_position(position)
    vsobject:update {type = vsobject_type}
end

function M:move_pickup_object(delta)
    if not pickup_object then
        return
    end

    --
    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    local typeobject = gameplay.queryByName("entity", pickup_object.prototype_name)
    local position = math3d.add(vsobject:get_position(), delta)

    local coord = terrain.adjust_position(math3d.tovalue(position), rotate_area(typeobject.area, pickup_object.dir))
    if not coord then
        return
    end
    pickup_object.x, pickup_object.y = coord[1], coord[2]

    vsobject:set_position(position)
end

function M:rotate_pickup_object()
    if not pickup_object then
        return
    end

    revert_changes({"TEMPORARY"})
    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    local dir = rotate_dir_times(pickup_object.dir, -1)

    local typeobject = gameplay.queryByName("entity", pickup_object.prototype_name)
    local coord, position = terrain.adjust_position(camera.get_central_position(), rotate_area(typeobject.area, dir))
    if not position then
        return
    end

    pickup_object.x, pickup_object.y = coord[1], coord[2]
    pickup_object.dir = dir
    vsobject:set_position(position)

    --
    local object_type
    if not check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        object_type = "invalid_construct"
        refresh_pickup_pipe()
    else
        object_type = "construct"

        set_tile_object(pickup_object)
        refresh_pickup_pipe()
        refresh_pipe_connection(pickup_object)
    end
    pickup_object.vsobject_type = object_type

    vsobject:set_dir(pickup_object.dir)
    vsobject:update {type = object_type}
end

function M:complete()
    if pickup_object then
        -- 针对流体盒子的特殊处理
        if has_fluidboxes(pickup_object.prototype_name) then
            world:pub {"ui_message", "show_set_fluidbox", false}
        end

        vsobject_manager:remove(pickup_object.id)
        pickup_object = nil

        revert_changes({"TEMPORARY"})
    end

    local needbuild = false

    local t = {}
    for id, object in objects:all("CONFIRM") do
        object.vsobject_type = "constructed"
        t[id] = object
    end
    objects:commit("CONFIRM", "EXISTING")
    tile_objects:commit("CONFIRM", "EXISTING")

    for _, object in pairs(t) do
        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {type = "constructed"}
        gameplay_core.create_entity(object)
        needbuild = true
    end

    if needbuild then
        gameplay_core.build()
    end
end

function M:cancel()
    revert_changes({"TEMPORARY", "CONFIRM"})

    if pickup_object then
        -- 针对流体盒子的特殊处理
        if has_fluidboxes(pickup_object.prototype_name) then
            world:pub {"ui_message", "show_set_fluidbox", false}
        end

        vsobject_manager:remove(pickup_object.id)
        pickup_object = nil
    end
end

function M:check_unconfirmed(double_confirm)
    if not objects:empty("CONFIRM") then
        if not double_confirm then
            return true
        end
    end
    return false
end

function M:reset()
    objects = create_cache(cache_names, table.unpack(objects_index_field)) -- = {[id] = object, ...}
    tile_objects = create_cache(cache_names, table.unpack(tile_objects_index_field)) -- = {[coord] = {id = xx, fluidbox_dir = {[xx] = true, ...}}, ...}
end

function M:get_vsobject(x, y)
    local tile_object = assert(tile_objects:get(cache_names, packcoord(x, y)))
    return assert(vsobject_manager:get(tile_object.id))
end

function M:teardown_begin()
    revert_changes({"TEMPORARY", "CONFIRM"})
    if pickup_object then
        -- 针对流体盒子的特殊处理
        if has_fluidboxes(pickup_object.prototype_name) then
            world:pub {"ui_message", "show_set_fluidbox", false}
        end

        vsobject_manager:remove(pickup_object.id)
        pickup_object = nil
    end
end

function M:teardown(vsobject_id)
    local object = clone_object(assert(objects:get(cache_names, vsobject_id)))
    local vsobject = assert(vsobject_manager:get(vsobject_id))

    object.teardown = not object.teardown

    if object.teardown then
        object.vsobject_type = "teardown"
        vsobject:update {type = "teardown"}
    else
        object.vsobject_type = "constructed"
        vsobject:update {type = "constructed"}
    end
    objects:set("TEMPORARY", object) --TODO 此处直接覆盖掉缓存的 object
end

function M:teardown_complete()
    local removelist = {}
    for id, object in objects:select("TEMPORARY", "teardown", true) do
        local vsobject = assert(vsobject_manager:get(id))
        vsobject:remove()

        objects:remove("EXISTING", id)
        for coord in tile_objects:select("EXISTING", "id", id) do
            tile_objects:remove("EXISTING", coord)
        end

        removelist[packcoord(object.x, object.y)] = object
    end

    for _, object in pairs(removelist) do
        refresh_pipe_connection(object)
    end

    local needbuild = false
    for e in gameplay_core.select("entity:in") do
        local coord = packcoord(e.entity.x, e.entity.y)
        if removelist[coord] then
            gameplay_core.remove_entity(e)
            needbuild = true
        end
    end
    if needbuild then
        gameplay_core.build()
    end

    objects:clear("TEMPORARY")
end

function M:set_pickup_object_fluid(fluid_name)
    if not pickup_object then
        log.warn("set_pickup_object_fluid", fluid_name)
        return
    end

    pickup_object.fluid = {fluid_name, 0}
end

return M