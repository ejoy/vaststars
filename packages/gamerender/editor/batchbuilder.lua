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
local objects = global.objects
local tile_objects = global.tile_objects
local ieditor = ecs.require "editor.editor"
local ALL_CACHE <const> = global.cache_names
local get_fluidboxes = require "gameplay.utility.get_fluidboxes"

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

local function get_object_id(x, y)
    local tile_object = tile_objects:get(ALL_CACHE, iprototype:packcoord(x, y))
    if not tile_object then
        return
    end

    return tile_object.id
end

local function get_object(x, y)
    local tile_object = tile_objects:get(ALL_CACHE, iprototype:packcoord(x, y))
    if not tile_object then
        return
    end

    return assert(objects:get(ALL_CACHE, tile_object.id))
end

local function check_starting(x, y)
    local object = get_object(x, y)
    if not object then
        return true
    end

    return ifluid:has_fluidbox(object.prototype_name)
end

local check_ending ; do 
    local dir_vector = {
        N = {x = 0,  y = -1},
        S = {x = 0,  y = 1},
        W = {x = -1, y = 0},
        E = {x = 1,  y = 0},
    }
    function check_ending(starting_x, starting_y, x, y)
        local object = get_object(x, y)
        if not object then
            return true
        end

        for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
            local dx = math_abs(starting_x - v.x)
            local dy = math_abs(starting_y - v.y)
            local vec = assert(dir_vector[v.dir])
            if starting_x == v.x + vec.x * dx and starting_y == v.y + vec.y * dy then
                return true
            end
        end
        return false
    end
end

local function update_coord_indicator(coord_indicator, vsobject_type)
    local vsobject = assert(vsobject_manager:get(coord_indicator.id))
    vsobject:update {type = vsobject_type}
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

    local object = get_object(x, y)
    if not object then
        return {}
    end
    ieditor:set_object(object, "INDICATOR")

    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    local coord_indicator_typeobject = iprototype:queryByName("entity", prototype_name)

    for _, v in ipairs(get_fluidboxes(object.prototype_name, object.x, object.y, object.dir)) do
        for dir in pairs(v.fluidbox_dir) do
            local px, py = ifluid:get_dir_coord(v.x, v.y, dir)
            local position = terrain.get_position_by_coord(px, py, iprototype:rotate_area(coord_indicator_typeobject.area, dir))

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

    if starting_x > ending_x then
        starting_x, ending_x = ending_x, starting_x
    end
    if starting_y > ending_y then
        starting_y, ending_y = ending_y, starting_y
    end

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

local function check_show_confirm(self, datamodel)
    if self.fluid_name == "" then
        return
    end
    datamodel.show_confirm = true
end

--

local function new_entity(self, datamodel, typeobject)
    if self.coord_indicator then
        vsobject_manager:remove(self.coord_indicator.id)
    end

    local dir = DEFAULT_DIR
    local coord, position = terrain.adjust_position(camera.get_central_position(), iprototype:rotate_area(typeobject.area, dir))
    local x, y = coord[1], coord[2]
    self.prototype_name = typeobject.name
    self.coord_indicator = __new_entity(self, typeobject, dir, x, y, position, "construct")

    --
    if check_starting(x, y) then
        datamodel.show_batch_mode_begin = true
        update_coord_indicator(self.coord_indicator, "construct")
    else
        datamodel.show_batch_mode_begin = false
        update_coord_indicator(self.coord_indicator, "invalid_construct")
    end

    --
    local object = get_object(x, y)
    if object then
        show_indicator(typeobject.name, ALL_CACHE, object.x, object.y)
    end

    --
    if object then
        -- object.fluid_name 建筑可能没有流体盒子
        local fluid_names = ifluid:get_fluidname(object.prototype_name, object.fluid_name or "")
        if #fluid_names == 1 then
            assert(type(fluid_names[1]) == "string")
            self.fluid_name = fluid_names[1]
            show_set_fluidbox(datamodel, fluid_names[1])
        else
            show_set_fluidbox(datamodel, "")
        end
    else
        show_set_fluidbox(datamodel, "")
    end
end

local function touch_move(self, datamodel, delta_vec)
    assert(self.coord_indicator)
    assert(self.prototype_name ~= "")
    local vsobject = assert(vsobject_manager:get(self.coord_indicator.id))
    local typeobject = iprototype:queryByName("entity", self.prototype_name)
    local position = math3d.ref(math3d.add(vsobject:get_position(), delta_vec))
    local coord = terrain.adjust_position(math3d.tovalue(position), iprototype:rotate_area(typeobject.area, self.coord_indicator.dir))
    if not coord then
        log.error(("can not get coord"))
        return
    end
    self.coord_indicator.x, self.coord_indicator.y = coord[1], coord[2]
    vsobject:set_position(position)
end

-- TODO
local function has_object(starting_x, starting_y, cur_x, cur_y)
    local dx = math_abs(starting_x - cur_x)
    local dy = math_abs(starting_y - cur_y)
    local step
    local find_id = {}
    local starting_object_id = get_object_id(starting_x, starting_y)
    if starting_object_id then
        find_id[starting_object_id] = true
    end
    local ending_object_id = get_object_id(cur_x, cur_y)
    if ending_object_id then
        find_id[ending_object_id] = true
    end

    if dx >= dy then
        if starting_x <= cur_x then
            step = 1
        else
            step = -1
        end

        for vx = starting_x + step, cur_x, step do
            local object = get_object(vx, starting_y)
            if object and not find_id[object.id] then
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
            local object = get_object(starting_x, vy)
            if object and not find_id[object.id] then
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

local function touch_end(self, datamodel)
    --
    local coord_indicator = assert(self.coord_indicator)
    local typeobject = iprototype:queryByName("entity", self.prototype_name)
    assert(typeobject.pipe or typeobject.road)
    local coord, position = terrain.adjust_position(camera.get_central_position(), 1, 1) -- 1, 1 水管 / 路块的 width & height
    if not coord then
        return
    end
    local vsobject = assert(vsobject_manager:get(self.coord_indicator.id))
    vsobject:set_position(position)
    coord_indicator.x, coord_indicator.y = coord[1], coord[2]
    local starting_coord = self.starting_coord

    --
    ieditor:revert_changes({"INDICATOR", "TEMPORARY"})

    if not self.starting_coord then
        --
        if check_starting(coord_indicator.x, coord_indicator.y) then
            datamodel.show_batch_mode_begin = true
            update_coord_indicator(self.coord_indicator, "construct")
        else
            datamodel.show_batch_mode_begin = false
            update_coord_indicator(self.coord_indicator, "invalid_construct")
        end

        --
        local object = get_object(coord_indicator.x, coord_indicator.y)
        if object then
            show_indicator(typeobject.name, ALL_CACHE, object.x, object.y)
        end
        return
    end

    local cur_x, cur_y = get_ending_coord(starting_coord.x, starting_coord.y, coord_indicator.x, coord_indicator.y)
    if has_object(starting_coord.x, starting_coord.y, cur_x, cur_y) then
        local ending_x, ending_y = get_ending_coord(starting_coord.x, starting_coord.y, cur_x, cur_y)
        datamodel.show_confirm = false
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_coord.x, starting_coord.y, ending_x, ending_y, "invalid_construct")
        return
    end

    local starting_object = get_object(starting_coord.x, starting_coord.y)
    local cur_object = get_object(cur_x, cur_y)

    --
    if not starting_object or not cur_object then
        if check_ending(starting_coord.x, starting_coord.y, coord_indicator.x, coord_indicator.y) then
            check_show_confirm(self, datamodel)
            show_pipe_indicator("TEMPORARY", coord_indicator.prototype_name, starting_coord.x, starting_coord.y, cur_x, cur_y, "construct")
        else
            datamodel.show_confirm = false
            show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_coord.x, starting_coord.y, cur_x, cur_y, "invalid_construct")
        end

        --
        if cur_object then
            -- object.fluid_name 建筑可能没有流体盒子
            local fluid_names = ifluid:get_fluidname(cur_object.prototype_name, cur_object.fluid_name or "")
            if #fluid_names == 1 then
                assert(type(fluid_names[1]) == "string")
                self.fluid_name = fluid_names[1]
                show_set_fluidbox(datamodel, fluid_names[1])
            else
                show_set_fluidbox(datamodel, "")
            end
        else
            show_set_fluidbox(datamodel, "")
        end
        return
    end

    if starting_object.id == cur_object.id then
        datamodel.show_confirm = false
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_coord.x, starting_coord.y, cur_x, cur_y, "invalid_construct")
        return
    end

    if check_ending(starting_coord.x, starting_coord.y, coord_indicator.x, coord_indicator.y) then
        check_show_confirm(self, datamodel)
        show_pipe_indicator("TEMPORARY", coord_indicator.prototype_name, starting_coord.x, starting_coord.y, cur_x, cur_y, "construct")
    else
        datamodel.show_confirm = false
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_coord.x, starting_coord.y, cur_x, cur_y, "invalid_construct")
    end
end

local function confirm(self, datamodel)
    assert(self.fluid_name ~= "")

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
    vsobject_manager:remove(self.coord_indicator.id)
    self.coord_indicator = nil

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
    assert(self.starting_coord == nil)
    local coord_indicator = assert(self.coord_indicator)
    self.starting_coord = {x = coord_indicator.x, y = coord_indicator.y}

    datamodel.show_confirm = false
    local object = get_object(self.starting_coord.x, self.starting_coord.y)
    if object then
        if next(ifluid:get_fluidbox_coord(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) then
            datamodel.show_batch_mode_begin = false
            hide_set_fluidbox(datamodel)
        else
            datamodel.show_batch_mode_begin = true
            hide_set_fluidbox(datamodel)
        end
    else
        datamodel.show_batch_mode_begin = false
        show_set_fluidbox(datamodel, "")
    end
end

local function batch_mode_end(self, datamodel)
    assert(self.ending_coord == nil)
    local coord_indicator = assert(self.coord_indicator)
    self.ending_coord = {x = coord_indicator.x, y = coord_indicator.y}

    if self.fluid_name and self.fluid_name ~= "" then
        datamodel.show_confirm = true
    end
end

local function clean(self, datamodel)
    if self.coord_indicator then
        vsobject_manager:remove(self.coord_indicator.id)
        self.coord_indicator = nil
    end

    self:revert_changes({"INDICATOR", "TEMPORARY"})
    hide_set_fluidbox(datamodel)
    datamodel.show_confirm = false
    datamodel.show_batch_mode_begin = false
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