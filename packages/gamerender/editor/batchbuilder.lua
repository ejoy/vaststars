local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local create_builder = ecs.require "editor.builder"
local vsobject_manager = ecs.require "vsobject_manager"
local DEFAULT_DIR <const> = 'N'
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local ifluid = require "gameplay.interface.fluid"
local math3d = require "math3d"
local math_abs = math.abs
local global = require "global"
local cache_names = global.cache_names
local objects = global.objects
local tile_objects = global.tile_objects
local ieditor = ecs.require "editor.editor"
local ALL_CACHE <const> = global.cache_names
local get_fluidboxes = require "gameplay.utility.get_fluidboxes"
local ALL_DIR <const> = require("gameplay.interface.constant").ALL_DIR

local gameplay_core = require "gameplay.core"

local function show_set_fluidbox(datamodel, fluid_name)
    datamodel.cur_selected_fluid = fluid_name
    datamodel.cur_fluid_category = ifluid:get_fluid_category(fluid_name)
    datamodel.show_set_fluidbox = true
end

local function hide_set_fluidbox(datamodel)
    datamodel.cur_selected_fluid = ""
    datamodel.cur_fluid_category = ""
    datamodel.show_set_fluidbox = false
end

local function get_object_by_coord(cache_names, x, y)
    local tile_object = tile_objects:get(cache_names, iprototype:packcoord(x, y))
    if not tile_object then
        return
    end

    return assert(objects:get(cache_names, tile_object.id))
end

-- 刷新 pickup object 管道 的形状
local function refresh_spec_flow_shape(cache_names, object)
    assert(object)
    local vsobject = assert(vsobject_manager:get(object.id))
    local typeobject = iprototype:queryByName("entity", object.prototype_name)

    if typeobject.pipe then
        local prototype_name, dir = ieditor:refresh_pipe(cache_names, object.prototype_name, object.x, object.y, object.dir)
        if prototype_name then
            object.prototype_name = prototype_name
            object.dir = dir

            vsobject:update {prototype_name = prototype_name}
            vsobject:set_dir(dir)
        end
    end

    if typeobject.road then
        local prototype_name, dir = ieditor:refresh_road(cache_names, object.prototype_name, object.x, object.y, object.dir)
        if prototype_name then
            object.prototype_name = prototype_name
            object.dir = dir

            vsobject:update {prototype_name = prototype_name}
            vsobject:set_dir(dir)
        end
    end
end

local function __new_entity(self, typeobject, dir, x, y, position, vsobject_type)
    local vsobject = vsobject_manager:create {
        prototype_name = typeobject.name,
        dir = dir,
        position = position,
        type = vsobject_type,
    }
    local object = {
        id = vsobject.id,
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        teardown = false,
        headquater = typeobject.headquater or false,
        manual_set_fluid = false, -- 没有手动设置液体的情况下, 会自动将液体设置为附近流体系统的液体
        fluid_name = "",
    }

    return object
end

local function show_indicator(prototype_name, cache_names, x, y)
    ieditor:revert_changes({"INDICATOR"})

    local object = get_object_by_coord(cache_names, x, y)
    if not object then
        return {}
    end
    ieditor:set_object(object, "INDICATOR")

    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    local pickup_object_typeobject = iprototype:queryByName("entity", prototype_name)

    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local px, py = ifluid:get_dir_coord(v.x, v.y, dir)
            local position = terrain.get_position_by_coord(px, py, iprototype:rotate_area(pickup_object_typeobject.area, dir))

            local vsobject = vsobject_manager:create {
                prototype_name = prototype_name,
                dir = dir,
                position = position,
                type = "indicator",
            }

            local nobject = {
                id = vsobject.id,
                prototype_name = prototype_name,
                dir = dir,
                x = px,
                y = py,
                teardown = false,
                headquater = typeobject.headquater or false,
                manual_set_fluid = false,
                fluid_name = "",
            }

            ieditor:set_object(nobject, "INDICATOR")
            refresh_spec_flow_shape({"INDICATOR"}, nobject)
        end
    end
end

local function show_pipe_indicator(cache_name, prototype_name, starting_x, starting_y, ending_x, ending_y, vsobject_type)
    ieditor:revert_changes({cache_name})

    local typeobject = iprototype:queryByName("entity", prototype_name)
    for x = starting_x, ending_x do
        for y = starting_y, ending_y do
            local position = terrain.get_position_by_coord(x, y, iprototype:rotate_area(typeobject.area, DEFAULT_DIR))

            local vsobject = vsobject_manager:create {
                prototype_name = prototype_name,
                dir = DEFAULT_DIR,
                position = position,
                type = vsobject_type,
            }

            local object = {
                id = vsobject.id,
                prototype_name = prototype_name,
                dir = DEFAULT_DIR,
                x = x,
                y = y,
                teardown = false,
                headquater = typeobject.headquater or false,
                manual_set_fluid = false,
                fluid_name = "",
            }

            ieditor:set_object(object, cache_name)
            refresh_spec_flow_shape({cache_name}, object)
            ieditor:refresh_neighbor_flow_shape({cache_name}, object)
        end
    end
end

--

local function new_entity(self, datamodel, typeobject)
    self:clean(datamodel)

    local dir = DEFAULT_DIR
    local coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, dir))
    local x, y = coord[1], coord[2]

    -- TODO
    local vsobject_type
    datamodel.show_confirm = false
    local object = get_object_by_coord(ALL_CACHE, x, y)
    if object then
        if next(ifluid:get_fluidbox_coord(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) then
            datamodel.show_batch_mode_begin = true
            datamodel.show_batch_mode_end = false
            hide_set_fluidbox(datamodel)
            show_indicator(typeobject.name, ALL_CACHE, object.x, object.y)
            vsobject_type = "construct"
        else
            datamodel.show_batch_mode_begin = false
            datamodel.show_batch_mode_end = false
            hide_set_fluidbox(datamodel)
            vsobject_type = "invalid_construct"
        end
    else
        datamodel.show_batch_mode_begin = true
        datamodel.show_batch_mode_end = false
        show_set_fluidbox(datamodel, "")
        vsobject_type = "construct"
    end

    self.prototype_name = typeobject.name
    self.pickup_object = __new_entity(self, typeobject, dir, x, y, position, vsobject_type)
end

local function touch_move(self, datamodel, delta_vec)
    assert(self.pickup_object)
    assert(self.prototype_name ~= "")
    local vsobject = assert(vsobject_manager:get(self.pickup_object.id))
    local typeobject = iprototype:queryByName("entity", self.prototype_name)
    local position = math3d.ref(math3d.add(vsobject:get_position(), delta_vec))
    local coord = terrain.adjust_position(math3d.tovalue(position), iprototype:rotate_area(typeobject.area, self.pickup_object.dir))
    if not coord then
        log.error(("can not get coord"))
        return
    end
    self.pickup_object.x, self.pickup_object.y = coord[1], coord[2]
    vsobject:set_position(position)
end

local function get_distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

-- TODO
local function get_fluidbox_coord(starting_x, starting_y, ending_x, ending_y)
    local tile_object = tile_objects:get(ALL_CACHE, iprototype:packcoord(starting_x, starting_y))
    if tile_object then
        -- 选中了某个建筑
        local min_dist, min_x, min_y, min_fluidbox_coord

        local object = objects:get(ALL_CACHE, tile_object.id)
        for coord, t in pairs(ifluid:get_fluidbox_coord(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
            local x, y = iprototype:unpackcoord(coord)
            local dist = get_distance(x, y, ending_x, ending_y)
            min_dist = min_dist or dist
            min_x = min_x or x
            min_y = min_y or y
            min_fluidbox_coord = min_fluidbox_coord or t
            if min_dist > dist then
                min_x = x
                min_y = y
                min_fluidbox_coord = t
            end
        end
        return min_x, min_y, min_fluidbox_coord
    else
        -- 没有选中任何建筑
        local fluidbox_coord = {}
        for _, dir in ipairs(ALL_DIR) do
            fluidbox_coord[dir] = ""
        end
        return starting_x, starting_y, fluidbox_coord
    end
end

local function get_object_id(x, y)
    local tile_object = tile_objects:get(cache_names, iprototype:packcoord(x, y))
    if not tile_object then
        return
    end
    return tile_object.id
end

local function has_object(starting_x, starting_y, cur_x, cur_y)
    local dx = math_abs(starting_x - cur_x)
    local dy = math_abs(starting_y - cur_y)
    local step
    local starting_object_id = get_object_id(starting_x, starting_y)
    local ending_object_id   = get_object_id(cur_x, cur_y)

    if dx >= dy then
        if starting_x <= cur_x then
            step = 1
        else
            step = -1
        end

        for vx = starting_x + step, cur_x, step do
            local object_id = get_object_id(vx, starting_y)
            if object_id and ((starting_object_id and object_id ~= starting_object_id) and (ending_object_id and object_id ~= ending_object_id)) then
                return true
            end
        end
        return false
    else
        if starting_y <= cur_y then
            step = 1
        else
            step = -1
        end

        for vy = starting_y, cur_y, step do
            local object_id = get_object_id(starting_x, vy)
            if object_id and ((starting_object_id and object_id ~= starting_object_id) and (ending_object_id and object_id ~= ending_object_id)) then
                return true
            end
        end
        return false
    end
end

local function get_ending_coord(starting_x, starting_y, cur_x, cur_y)
    local dx = math_abs(starting_x - cur_x)
    local dy = math_abs(starting_y - cur_y)
    if dx >= dy then
        return cur_x, starting_y
    else
        return starting_x, cur_y
    end
end

local function check_fluidbox_coord(starting_x, starting_y, cur_x, cur_y, fluidbox_coord)
    if starting_x > cur_x then
        starting_x, cur_x = cur_x, starting_x
    end
    if starting_y > cur_y then
        starting_y, cur_y = cur_y, starting_y
    end
    for coord in pairs(fluidbox_coord) do
        local x, y = iprototype:unpackcoord(coord)
        if x >= starting_x and x <= cur_x and y >= starting_y and y <= cur_y then
            return true, fluidbox_coord[coord]
        end
    end
end

local function touch_end(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    -- 纠正 entity 的位置与格子对应
    local typeobject = iprototype:queryByName("entity", self.prototype_name)
    assert(typeobject.pipe or typeobject.road)
    local coord, position = terrain.adjust_position(camera.get_central_position(), 1, 1) -- 1, 1 水管 / 路块的 width & height
    if not coord then
        return
    end
    local vsobject = assert(vsobject_manager:get(self.pickup_object.id))
    vsobject:set_position(position)
    pickup_object.x, pickup_object.y = coord[1], coord[2]
    local starting_coord = self.starting_coord

    if self.ending_coord then
        return
    end

    ieditor:revert_changes({"INDICATOR", "TEMPORARY"})

    -- 还未点击开始
    if not self.starting_coord then
        local cur_object_id = get_object_id(pickup_object.x, pickup_object.y)
        if cur_object_id then
            local cur_object = objects:get(ALL_CACHE, cur_object_id)
            local fluidbox_coord = ifluid:get_fluidbox_coord(cur_object.prototype_name, cur_object.x, cur_object.y, cur_object.dir, cur_object.fluid_name)
            if not next(fluidbox_coord) then
                datamodel.show_batch_mode_begin = false
                datamodel.show_batch_mode_end = false
                datamodel.show_confirm = false
                return
            end
        end

        datamodel.show_batch_mode_begin = true
        datamodel.show_batch_mode_end = false
        datamodel.show_confirm = false
        show_indicator(pickup_object.prototype_name, ALL_CACHE, pickup_object.x, pickup_object.y)
        return
    end

    if has_object(starting_coord.x, starting_coord.y, pickup_object.x, pickup_object.y) then
        datamodel.show_batch_mode_begin = false
        datamodel.show_batch_mode_end = false
        datamodel.show_confirm = false
        local ending_x, ending_y = get_ending_coord(starting_coord.x, starting_coord.y, pickup_object.x, pickup_object.y)
        show_pipe_indicator("INDICATOR", pickup_object.prototype_name, starting_coord.x, starting_coord.y, ending_x, ending_y, "invalid_construct")
        return
    end

    local starting_object_id = get_object_id(starting_coord.x, starting_coord.y)
    local cur_object_id = get_object_id(pickup_object.x, pickup_object.y)
    if starting_object_id then
        if cur_object_id then
            if starting_object_id and cur_object_id and starting_object_id == cur_object_id then
                datamodel.show_batch_mode_begin = false
                datamodel.show_batch_mode_end = false
                datamodel.show_confirm = false
                local ending_x, ending_y = get_ending_coord(starting_coord.x, starting_coord.y, pickup_object.x, pickup_object.y)
                show_pipe_indicator("INDICATOR", pickup_object.prototype_name, starting_coord.x, starting_coord.y, ending_x, ending_y, "invalid_construct")
                return
            else
                local cur_object = objects:get(ALL_CACHE, cur_object_id)
                local fluidbox_coord = ifluid:get_fluidbox_coord(cur_object.prototype_name, cur_object.x, cur_object.y, cur_object.dir, cur_object.fluid_name)
                local success, fluid_name = check_fluidbox_coord(starting_coord.x, starting_coord.y, pickup_object.x, pickup_object.y, fluidbox_coord)
                if not next(fluidbox_coord) or not success then
                    datamodel.show_batch_mode_begin = false
                    datamodel.show_batch_mode_end = false
                    datamodel.show_confirm = false
                    local ending_x, ending_y = get_ending_coord(starting_coord.x, starting_coord.y, pickup_object.x, pickup_object.y)
                    show_pipe_indicator("INDICATOR", pickup_object.prototype_name, starting_coord.x, starting_coord.y, ending_x, ending_y, "invalid_construct")
                    return
                end

                if cur_object_id then
                    local cur_object = objects:get(ALL_CACHE, cur_object_id)
                    ieditor:set_object(cur_object, "TEMPORARY")
                    local typeobject = iprototype:queryByName("entity", cur_object.prototype_name)
                    if iprototype:is_batch_mode(typeobject) then
                        for _, dir in ipairs(ALL_DIR) do
                            local coord = iprototype:packcoord( ifluid:get_dir_coord(cur_object.x, cur_object.y, dir) )
                            local tile_object = tile_objects:get(ALL_CACHE, coord)
                            if tile_object then
                                local object = objects:get(ALL_CACHE, tile_object.id)
                                ieditor:set_object(ieditor:clone_object(object), "TEMPORARY")
                            end
                        end
                    end
                end

                self.fluid_name = fluid_name
                show_set_fluidbox(datamodel, self.fluid_name)

                local ending_x, ending_y = get_ending_coord(starting_coord.x, starting_coord.y, pickup_object.x, pickup_object.y)
                show_pipe_indicator("TEMPORARY", pickup_object.prototype_name, starting_coord.x, starting_coord.y, ending_x, ending_y, "construct")
                return
            end
        end
    end

    if self.starting_coord and self.starting_coord.x == pickup_object.x and self.starting_coord.y == pickup_object.y then
        local vsobject_type
        datamodel.show_confirm = false
        local object = get_object_by_coord(ALL_CACHE, pickup_object.x, pickup_object.y)
        if object then
            if next(ifluid:get_fluidbox_coord(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) then
                datamodel.show_batch_mode_begin = false
                datamodel.show_batch_mode_end = false
                hide_set_fluidbox(datamodel)
                show_indicator(typeobject.name, ALL_CACHE, object.x, object.y)
                vsobject_type = "construct"
            else
                datamodel.show_batch_mode_begin = false
                datamodel.show_batch_mode_end = false
                hide_set_fluidbox(datamodel)
                vsobject_type = "invalid_construct"
            end
        else
            datamodel.show_batch_mode_begin = false
            datamodel.show_batch_mode_end = true
            show_set_fluidbox(datamodel, "")
            vsobject_type = "construct"
        end
        vsobject:update {type == vsobject_type}
        return
    end

    local starting_x, starting_y, dirs = get_fluidbox_coord(self.starting_coord.x, self.starting_coord.y, pickup_object.x, pickup_object.y)
    -- TODO
    local starting_object = get_object_by_coord(ALL_CACHE, starting_x, starting_y)
    if starting_object then
        ieditor:set_object(starting_object, "TEMPORARY")
        local typeobject = iprototype:queryByName("entity", starting_object.prototype_name)
        if iprototype:is_batch_mode(typeobject) then
            for _, dir in ipairs(ALL_DIR) do
                local coord = iprototype:packcoord( ifluid:get_dir_coord(starting_object.x, starting_object.y, dir) )
                local tile_object = tile_objects:get(ALL_CACHE, coord)
                if tile_object then
                    local object = objects:get(ALL_CACHE, tile_object.id)
                    ieditor:set_object(ieditor:clone_object(object), "TEMPORARY")
                end
            end
        end
    end

    local ending_x, ending_y = coord[1], coord[2]
    local dx = math_abs(starting_x - ending_x)
    local dy = math_abs(starting_y - ending_y)
    local step, indicator_dir, vsobject_type

    if dx >= dy then
        if starting_x <= ending_x then
            step = 1
            indicator_dir = 'E'
        else
            step = -1
            indicator_dir = 'W'
        end

        if dirs[indicator_dir] then
            vsobject_type = "construct"
            datamodel.show_batch_mode_end = true
        else
            vsobject_type = "invalid_construct"
            datamodel.show_batch_mode_end = false
        end

        for vx = starting_x + step, ending_x, step do
            local x, y = vx, starting_y
            if not (x == starting_x and y == starting_y) and not (x == ending_x and y == ending_y) then
                if tile_objects:get(ALL_CACHE, iprototype:packcoord(x, y)) then
                    vsobject_type = "invalid_construct"
                    datamodel.show_batch_mode_end = false
                    break
                end
            end
        end

        for vx = starting_x, ending_x, step do
            local x, y = vx, starting_y
            local position = terrain.get_position_by_coord(x, y, iprototype:rotate_area(typeobject.area, DEFAULT_DIR))
            if not position then
                break
            end

            if tile_objects:get(ALL_CACHE, iprototype:packcoord(x, y)) then
                if x == starting_x and y == starting_y then
                    goto continue
                else
                    break
                end
            end

            local object = assert(__new_entity(self, typeobject, DEFAULT_DIR, x, y, position, vsobject_type))
            ieditor:set_object(object, "TEMPORARY")

            ieditor:refresh_neighbor_flow_shape({"TEMPORARY"}, object)
            refresh_spec_flow_shape({"TEMPORARY"}, object)
            ::continue::
        end
    else
        if starting_y <= ending_y then
            step = 1
            indicator_dir = 'S'
        else
            step = -1
            indicator_dir = 'N'
        end

        if dirs[indicator_dir] then
            vsobject_type = "construct"
            datamodel.show_batch_mode_end = true
        else
            vsobject_type = "invalid_construct"
            datamodel.show_batch_mode_end = false
        end

        for vy = starting_y, ending_y, step do
            local x, y = starting_x, vy
            if not (x == starting_x and y == starting_y) and not (x == ending_x and y == ending_y) then
                if tile_objects:get(ALL_CACHE, iprototype:packcoord(x, y)) then
                    vsobject_type = "invalid_construct"
                    datamodel.show_batch_mode_end = false
                    break
                end
            end
        end

        for vy = starting_y, ending_y, step do
            local x, y = starting_x, vy
            local position = terrain.get_position_by_coord(x, y, iprototype:rotate_area(typeobject.area, DEFAULT_DIR))
            if not position then
                break
            end

            if tile_objects:get(ALL_CACHE, iprototype:packcoord(x, y)) then
                if x == starting_x and y == starting_y then
                    goto continue
                else
                    break
                end
            end

            local object = assert(__new_entity(self, typeobject, DEFAULT_DIR, x, y, position, vsobject_type))
            ieditor:set_object(object, "TEMPORARY")

            ieditor:refresh_neighbor_flow_shape({"TEMPORARY"}, object)
            refresh_spec_flow_shape({"TEMPORARY"}, object)
            ::continue::
        end
    end

    self.fluid_name = dirs[indicator_dir] or ""
    show_set_fluidbox(datamodel, self.fluid_name)
end

local function confirm(self, datamodel)
    for _, object in objects:all("TEMPORARY") do
        object.fluid_name = self.fluid_name
        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {type = "confirm"}
    end
    objects:commit("TEMPORARY", "CONFIRM")
    tile_objects:commit("TEMPORARY", "CONFIRM")

    local typeobject = iprototype:queryByName("entity", self.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.starting_coord = nil
    self.ending_coord = nil
    self.fluid_name = ""
    hide_set_fluidbox(datamodel)
    datamodel.show_confirm = false
    datamodel.show_construct_complete = true
end

local function complete(self, datamodel)
    vsobject_manager:remove(self.pickup_object.id)
    self.pickup_object = nil

    self:revert_changes({"INDICATOR", "TEMPORARY"})

    datamodel.show_rotate = false
    datamodel.show_confirm = false
    hide_set_fluidbox(datamodel)

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

    datamodel.show_batch_mode_begin = false
    datamodel.show_construct_complete = false
end

local function set_fluid(self, datamodel, fluid_name)
    self.fluid_name = fluid_name


    if self.fluid_name and self.fluid_name ~= "" then
        datamodel.show_confirm = true
    end
end

local function batch_mode_begin(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    self.starting_coord = {x = pickup_object.x, y = pickup_object.y}

    datamodel.show_confirm = false
    local object = get_object_by_coord(ALL_CACHE, self.starting_coord.x, self.starting_coord.y)
    if object then
        if next(ifluid:get_fluidbox_coord(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) then
            datamodel.show_batch_mode_begin = false
            datamodel.show_batch_mode_end = false
            hide_set_fluidbox(datamodel)
        else
            datamodel.show_batch_mode_begin = true
            datamodel.show_batch_mode_end = false
            hide_set_fluidbox(datamodel)
        end
    else
        datamodel.show_batch_mode_begin = false
        datamodel.show_batch_mode_end = true
        show_set_fluidbox(datamodel, "")
    end
end

local function batch_mode_end(self, datamodel)
    local pickup_object = assert(self.pickup_object)
    self.ending_coord = {x = pickup_object.x, y = pickup_object.y}

    datamodel.show_batch_mode_end = false

    if self.fluid_name and self.fluid_name ~= "" then
        datamodel.show_confirm = true
    end
end

local function clean(self, datamodel)
    if self.pickup_object then
        vsobject_manager:remove(self.pickup_object.id)
        self.pickup_object = nil
    end

    self:revert_changes({"INDICATOR", "TEMPORARY"})
    hide_set_fluidbox(datamodel)
    datamodel.show_confirm = false
    datamodel.show_batch_mode_begin = false
    datamodel.show_batch_mode_end = false
    self.super.clean(self, datamodel)
end

local function create()
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm
    M.complete = complete
    M.set_fluid = set_fluid

    M.clean = clean

    M.fluid_name = ""
    M.prototype_name = ""
    -- M.starting_coord = {x = xx, y = xx}
    -- M.ending_coord = {x = xx, y = xx}
    M.batch_mode_begin = batch_mode_begin
    M.batch_mode_end = batch_mode_end
    return M
end
return create