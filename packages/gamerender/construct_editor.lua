local ecs = ...
local world = ecs.world

local math3d = require "math3d"

local flow_shape = require "gameplay.utility.flow_shape"
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local get_fluidboxes = require "gameplay.utility.get_fluidboxes"
local need_set_fluid = require "gameplay.utility.need_set_fluid"
local get_roadboxes = require "gameplay.utility.get_roadboxes"
local vsobject_manager = ecs.require "vsobject_manager"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.prototype"

local DEFAULT_DIR <const> = 'N'

local M = {}
local pickup_object

local global = require "global"
local cache_names = global.cache_names
local objects = global.objects
local tile_objects = global.tile_objects

local get_dir_coord; do
    local dir_coord = {
        ['N'] = {x = 0,  y = -1},
        ['E'] = {x = 1,  y = 0},
        ['S'] = {x = 0,  y = 1},
        ['W'] = {x = -1, y = 0},
    }
    function get_dir_coord(x, y, dir)
        local c = assert(dir_coord[dir])
        return x + c.x, y + c.y
    end
end

local function get_neighbor_fluid_types(prototype_name, x, y, dir)
    local fluid_types = {}
    for _, v in ipairs(get_fluidboxes(prototype_name, x, y, dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local dx, dy = get_dir_coord(v.x, v.y, dir)
            local tile_object = tile_objects:get(cache_names, iprototype:packcoord(dx, dy))
            if tile_object and tile_object.fluidbox_dir then
                if tile_object.fluidbox_dir[iprototype:opposite_dir(dir)] then
                    local object = assert(objects:get(cache_names, tile_object.id))
                    local fluid = object.fluid
                    if fluid ~= "" then
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

local function check_construct_detector(prototype_name, x, y, dir, id, fluid_type)
    local typeobject = iprototype:queryByName("entity", prototype_name)
    local construct_detector = typeobject.construct_detector
    if not construct_detector then
        return true
    end

    local w, h = iprototype:rotate_area(typeobject.area, dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local tile_object = tile_objects:get(cache_names, iprototype:packcoord(x + i, y + j))
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

    if #fluid_types == 1 and fluid_type and fluid_types[1] ~= fluid_type then
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
        manual_set_fluid = object.manual_set_fluid,
        fluid = object.fluid,
        x = object.x,
        y = object.y,
        teardown = object.teardown,
    }
end

-- object = {id = xx, prototype_name = xx, dir = xx, fluid = xx, x = xx, y = xx}
local function set_tile_object(object, cache_name)
    local t = {}

    --
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    local w, h = iprototype:rotate_area(typeobject.area, object.dir)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local coord = iprototype:packcoord(object.x + i, object.y + j)
            t[coord] = {id = object.id, coord = coord}
        end
    end

    --
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        assert(t[iprototype:packcoord(v.x, v.y)])
        t[iprototype:packcoord(v.x, v.y)].fluidbox_dir = v.fluidbox_dir
    end

    --
    for _, v in ipairs(get_roadboxes(object.prototype_name, object.x, object.y, object.dir)) do
        assert(t[iprototype:packcoord(v.x, v.y)])
        t[iprototype:packcoord(v.x, v.y)].road_dir = v.road_dir
    end

    --
    for _, tile_object in pairs(t) do
        tile_objects:set(cache_name, tile_object)
    end

    objects:set(cache_name, object)
end

local function refresh_pipe(x, y)
    local tile_object = tile_objects:get(cache_names, iprototype:packcoord(x, y))
    if not tile_object then
        return
    end

    local object = assert(objects:get(cache_names, tile_object.id))
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    if not typeobject.pipe then
        return
    end

    local state = 0
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local dx, dy = get_dir_coord(v.x, v.y, dir)
            local tile_object = tile_objects:get(cache_names, iprototype:packcoord(dx, dy))
            if tile_object and tile_object.fluidbox_dir then
                if tile_object.fluidbox_dir[iprototype:opposite_dir(dir)] then
                    state = flow_shape.set_state(state, iprototype:dir_tonumber(dir), 1)
                end
            end
        end
    end

    local ntype, dir = flow_shape.to_type_dir(state)
    return object.prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(ntype)), dir
end

local function refresh_road(x, y)
    local tile_object = tile_objects:get(cache_names, iprototype:packcoord(x, y))
    if not tile_object then
        return
    end

    local object = assert(objects:get(cache_names, tile_object.id))
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    if not typeobject.road then
        return
    end

    local state = 0
    for _, v in ipairs(get_roadboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.road_dir) do
            local dx, dy = get_dir_coord(v.x, v.y, dir)
            local tile_object = tile_objects:get(cache_names, iprototype:packcoord(dx, dy))
            if tile_object and tile_object.road_dir then
                if tile_object.road_dir[iprototype:opposite_dir(dir)] then
                    state = flow_shape.set_state(state, iprototype:dir_tonumber(dir), 1)
                end
            end
        end
    end

    local ntype, dir = flow_shape.to_type_dir(state)
    return object.prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(ntype)), dir
end

local function refresh_pickup_flow_shape()
    assert(pickup_object)
    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    local typeobject = iprototype:queryByName("entity", pickup_object.prototype_name)

    if typeobject.pipe then
        local prototype_name, dir = refresh_pipe(pickup_object.x, pickup_object.y)
        if prototype_name then
            pickup_object.prototype_name = prototype_name
            pickup_object.dir = dir

            vsobject:update {prototype_name = prototype_name}
            vsobject:set_dir(dir)
        end
    end

    if typeobject.road then
        local prototype_name, dir = refresh_road(pickup_object.x, pickup_object.y)
        if prototype_name then
            pickup_object.prototype_name = prototype_name
            pickup_object.dir = dir

            vsobject:update {prototype_name = prototype_name}
            vsobject:set_dir(dir)
        end
    end
end

local function refresh_flow_shape(object)
    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local dx, dy = get_dir_coord(v.x, v.y, dir)
            local prototype_name, dir = refresh_pipe(dx, dy)
            if prototype_name then
                local tile_object = assert(tile_objects:get(cache_names, iprototype:packcoord(dx, dy)))

                local vsobject = assert(vsobject_manager:get(tile_object.id))
                vsobject:update {prototype_name = prototype_name}
                vsobject:set_dir(dir)

                local object = clone_object(assert(objects:get(cache_names, tile_object.id)))
                object.prototype_name = prototype_name
                object.dir = dir

                set_tile_object(object, "TEMPORARY")
            end
        end
    end

    for _, v in ipairs(get_roadboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.road_dir) do
            local dx, dy = get_dir_coord(v.x, v.y, dir)
            local prototype_name, dir = refresh_road(dx, dy)
            if prototype_name then
                local tile_object = assert(tile_objects:get(cache_names, iprototype:packcoord(dx, dy)))

                local vsobject = assert(vsobject_manager:get(tile_object.id))
                vsobject:update {prototype_name = prototype_name}
                vsobject:set_dir(dir)

                local object = clone_object(assert(objects:get(cache_names, tile_object.id)))
                object.prototype_name = prototype_name
                object.dir = dir

                set_tile_object(object, "TEMPORARY")
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

local function new_pickup_object(prototype_name, dir, x, y, fluid)
    local vsobject_type, need_set_tile_object
    if not check_construct_detector(prototype_name, x, y, dir) then
        vsobject_type = "invalid_construct"
        need_set_tile_object = false
    else
        vsobject_type = "construct"
        need_set_tile_object = true
    end

    local typeobject = iprototype:queryByName("entity", prototype_name)
    local position = terrain.get_position_by_coord(x, y, iprototype:rotate_area(typeobject.area, dir))
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
        fluid = "",
        manual_set_fluid = false,
        x = x,
        y = y,
        teardown = false,
    }

    if need_set_tile_object then
        set_tile_object(pickup_object, "TEMPORARY")

        refresh_pickup_flow_shape()
        refresh_flow_shape(pickup_object)
    end

    local show_confirm = true
    -- 针对流体盒子的特殊处理
    if need_set_fluid(pickup_object.prototype_name) then
        local fluid_types = get_neighbor_fluid_types(pickup_object.prototype_name, x, y, pickup_object.dir)
        if #fluid_types == 1 then
            pickup_object.fluid = fluid_types[1]
            vsobject:update_fluid(fluid_types[1])
            show_confirm = true
        else
            pickup_object.fluid = fluid or ""
            vsobject:update_fluid("")
            show_confirm = false
        end
        world:pub {"ui_message", "show_set_fluidbox", true}
    else
        world:pub {"ui_message", "show_set_fluidbox", false}
    end

    -- 针对 水管 & 路块 的特殊处理
    world:pub {"ui_message", "show_rotate_confirm", {rotate = not(typeobject.pipe or typeobject.road), confirm = show_confirm}}

    return pickup_object
end
M.debug_new_pickup_object = new_pickup_object -- for debug

local function update_pickup_object(pickup_object, vsobject)
    local vsobject_type
    local fluid_type
    if pickup_object.manual_set_fluid then
        fluid_type = pickup_object.fluid
    end

    if not check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.id, fluid_type) then
        vsobject_type = "invalid_construct"
        refresh_pickup_flow_shape()
    else
        vsobject_type = "construct"

        set_tile_object(pickup_object, "TEMPORARY")
        refresh_pickup_flow_shape()
        refresh_flow_shape(pickup_object)

        -- 针对流体盒子的特殊处理
        if need_set_fluid(pickup_object.prototype_name) then
            local fluid_types = get_neighbor_fluid_types(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir)
            assert(#fluid_types <= 1)
            if #fluid_types == 1 then
                pickup_object.fluid = assert(fluid_types[1])
                vsobject:update_fluid(fluid_types[1])
                world:pub {"ui_message", "show_rotate_confirm", {confirm = true}}
            else
                if not pickup_object.manual_set_fluid then
                    pickup_object.fluid = ""
                    vsobject:update_fluid("")
                    world:pub {"ui_message", "show_rotate_confirm", {confirm = false}}
                end
            end
        end
    end

    pickup_object.vsobject_type = vsobject_type
    return pickup_object
end

---
function M:construct_begin()
    revert_changes({"TEMPORARY"})
    world:pub {"ui_message", "show_rotate_confirm", {rotate = false, confirm = false}}
end

function M:new_pickup_object(prototype_name)
    if pickup_object then
        if pickup_object.prototype_name == prototype_name then
            return
        end

        revert_changes({"TEMPORARY"})
        vsobject_manager:remove(pickup_object.id)
    end

    local typeobject = iprototype:queryByName("entity", prototype_name)
    local coord = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, DEFAULT_DIR))
    pickup_object = new_pickup_object(prototype_name, DEFAULT_DIR, coord[1], coord[2])
end

function M.restore_object(gameplay_eid, prototype_name, dir, x, y)
    local vsobject_type = "constructed"
    local typeobject = iprototype:queryByName("entity", prototype_name)
    local position = assert(terrain.get_position_by_coord(x, y, iprototype:rotate_area(typeobject.area, dir)))

    local vsobject = vsobject_manager:create {
        prototype_name = prototype_name,
        dir = dir,
        position = position,
        type = vsobject_type,
    }
    local object = {
        id = vsobject.id,
        gameplay_eid = gameplay_eid,
        vsobject_type = vsobject_type,
        prototype_name = prototype_name,
        dir = dir,
        fluid = "",
        manual_set_fluid = false,
        x = x,
        y = y,
        teardown = false,
    }
    set_tile_object(object, "CONSTRUCTED")
end

function M:confirm()
    if not pickup_object then
        return
    end

    local fluid_type
    if pickup_object.manual_set_fluid then
        fluid_type = pickup_object.fluid
    end

    if not check_construct_detector(pickup_object.prototype_name, pickup_object.x, pickup_object.y, pickup_object.dir, pickup_object.id, fluid_type) then
        print("can not construct")
        return
    end

    -- 针对流体盒子的特殊处理
    if need_set_fluid(pickup_object.prototype_name) then
        if pickup_object.fluid == "" then
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

    pickup_object = new_pickup_object(pickup_object.prototype_name, pickup_object.dir, pickup_object.x, pickup_object.y)

    for _, dir in ipairs({'N', 'E', 'S', 'W'}) do
        local dx, dy = get_dir_coord(pickup_object.x, pickup_object.y, dir)
        local tile_object = tile_objects:get(cache_names, iprototype:packcoord(dx, dy))
        if tile_object then
            local obj = assert(vsobject_manager:get(tile_object.id))
            if obj.fluid_name ~= "" then
                vsobject:update_fluid("")
                break
            end
        end
    end

    -- 显示"开始施工"
    world:pub {"ui_message", "show_construct_complete", true}
end

function M:adjust_pickup_object()
    if not pickup_object then
        return
    end

    revert_changes({"TEMPORARY"})

    local vsobject = assert(vsobject_manager:get(pickup_object.id))

    --
    local typeobject = iprototype:queryByName("entity", pickup_object.prototype_name)
    local coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, pickup_object.dir))
    if not coord then
        return
    end
    pickup_object.x, pickup_object.y = coord[1], coord[2]
    vsobject:set_position(position)

    --
    pickup_object = update_pickup_object(pickup_object, vsobject)
    vsobject:update {type = pickup_object.vsobject_type}
end

function M:move_pickup_object(delta)
    if not pickup_object then
        return
    end

    --
    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    local typeobject = iprototype:queryByName("entity", pickup_object.prototype_name)
    local position = math3d.ref(math3d.add(vsobject:get_position(), delta))

    local coord = terrain.adjust_position(math3d.tovalue(position), iprototype:rotate_area(typeobject.area, pickup_object.dir))
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
    local dir = iprototype:rotate_dir_times(pickup_object.dir, -1)

    local typeobject = iprototype:queryByName("entity", pickup_object.prototype_name)
    local coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, dir))
    if not position then
        return
    end

    pickup_object.x, pickup_object.y = coord[1], coord[2]
    pickup_object.dir = dir
    vsobject:set_position(position)
    vsobject:set_dir(pickup_object.dir)

    --
    pickup_object = update_pickup_object(pickup_object, vsobject)
    vsobject:update {type = pickup_object.vsobject_type}
end

function M:complete()
    if pickup_object then
        -- 针对流体盒子的特殊处理
        if need_set_fluid(pickup_object.prototype_name) then
            world:pub {"ui_message", "show_set_fluidbox", false}
        end

        vsobject_manager:remove(pickup_object.id)
        pickup_object = nil

        revert_changes({"TEMPORARY"})
        world:pub {"ui_message", "show_rotate_confirm", {rotate = false, confirm = false}}
    end

    local needbuild = false
    for _, object in objects:all("CONFIRM") do
        object.vsobject_type = "constructed"

        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {type = "constructed"}

        object.gameplay_eid = gameplay_core.create_entity(object)
        needbuild = true
    end
    objects:commit("CONFIRM", "CONSTRUCTED")
    tile_objects:commit("CONFIRM", "CONSTRUCTED")

    if needbuild then
        gameplay_core.build()
    end
end

function M:cancel()
    revert_changes({"TEMPORARY", "CONFIRM"})
    world:pub {"ui_message", "show_rotate_confirm", {rotate = false, confirm = false}}

    if pickup_object then
        -- 针对流体盒子的特殊处理
        if need_set_fluid(pickup_object.prototype_name) then
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
    for _, cache_name in ipairs(cache_names) do
        for _, object in objects:all(cache_name) do
            vsobject_manager:remove(object.id)
        end
        objects:clear(cache_name)
        tile_objects:clear(cache_name)
    end
end

function M:get_vsobject(x, y)
    local tile_object = assert(tile_objects:get(cache_names, iprototype:packcoord(x, y)))
    return assert(vsobject_manager:get(tile_object.id))
end

function M:teardown_begin()
    revert_changes({"TEMPORARY", "CONFIRM"})
    world:pub {"ui_message", "show_rotate_confirm", {rotate = false, confirm = false}}

    if pickup_object then
        -- 针对流体盒子的特殊处理
        if need_set_fluid(pickup_object.prototype_name) then
            world:pub {"ui_message", "show_set_fluidbox", false}
        end

        vsobject_manager:remove(pickup_object.id)
        pickup_object = nil
    end
end

function M:teardown(id)
    local object = clone_object(assert(objects:get(cache_names, id)))
    local vsobject = assert(vsobject_manager:get(id))

    object.teardown = not object.teardown

    if object.teardown then
        object.vsobject_type = "teardown"
        vsobject:update {type = "teardown"}
    else
        object.vsobject_type = "constructed"
        vsobject:update {type = "constructed"}
    end
    objects:set("TEMPORARY", object)
end

function M:teardown_complete()
    local removelist = {}
    for id, object in objects:select("TEMPORARY", "teardown", true) do
        local vsobject = assert(vsobject_manager:get(id))
        vsobject:remove()

        objects:remove("CONSTRUCTED", id)
        for coord in tile_objects:select("CONSTRUCTED", "id", id) do
            tile_objects:remove("CONSTRUCTED", coord)
        end

        removelist[iprototype:packcoord(object.x, object.y)] = object
    end

    for _, object in pairs(removelist) do
        refresh_flow_shape(object)
    end

    local needbuild = false
    for e in gameplay_core.select("entity:in") do
        local coord = iprototype:packcoord(e.entity.x, e.entity.y)
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

    pickup_object.manual_set_fluid = true
    pickup_object.fluid = fluid_name
    world:pub {"ui_message", "show_rotate_confirm", {confirm = true}}

    local vsobject = assert(vsobject_manager:get(pickup_object.id))
    vsobject:update_fluid(fluid_name)

    pickup_object = update_pickup_object(pickup_object, vsobject)
    vsobject:update {type = pickup_object.vsobject_type}
end

return M