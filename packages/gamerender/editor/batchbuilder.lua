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
local ALL_DIR <const> = require("gameplay.interface.constant").ALL_DIR

local function show_fluid_setting(datamodel, fluid_name)
    datamodel.cur_selected_fluid = fluid_name
    datamodel.cur_fluid_category = ifluid:get_fluid_category(fluid_name)
    datamodel.show_set_fluidbox = true
end

local function hide_fluid_setting(datamodel)
    datamodel.cur_selected_fluid = ""
    datamodel.cur_fluid_category = ""
    datamodel.show_set_fluidbox = false
end

local function get_object(x, y)
    local tile_object = tile_objects:get(ALL_CACHE, iprototype:packcoord(x, y))
    if not tile_object then
        return
    end

    return assert(objects:get(ALL_CACHE, tile_object.id))
end

local get_valid_fluidbox ; do
    local PIPE_FLUIDBOXES_DIR = ALL_DIR

    local funcs = {}
    funcs["fluidbox"] = function(typeobject, x, y, dir, result, fluid_name)
        for _, conn in ipairs(typeobject.fluidbox.connections) do
            local dx, dy, dir = iprototype:rotate_fluidbox(conn.position, dir, typeobject.area)
            result[#result+1] = {x = x + dx, y = y + dy, dir = dir, fluid_name = fluid_name}
        end
        return result
    end

    local iotypes <const> = {"input", "output"}
    funcs["fluidboxes"] = function(typeobject, x, y, dir, result, fluid_name)
        for _, iotype in ipairs(iotypes) do
            for _, v in ipairs(typeobject.fluidboxes[iotype]) do
                for index, conn in ipairs(v.connections) do
                    if fluid_name and fluid_name[iotype] then
                        local dx, dy, dir = iprototype:rotate_fluidbox(conn.position, dir, typeobject.area)
                        result[#result+1] = {x = x + dx, y = y + dy, dir = dir, fluid_name = fluid_name[iotype][index]}
                    end
                end
            end
        end
        return result
    end

    function get_valid_fluidbox(prototype_name, x, y, dir, fluid_name)
        local r = {}
        local typeobject = assert(iprototype:queryByName("entity", prototype_name))
        if typeobject.pipe then
            for _, dir in ipairs(PIPE_FLUIDBOXES_DIR) do
                r[#r+1] = {x = x, y = y, dir = dir}
            end
        else
            local types = typeobject.type
            for i = 1, #types do
                local func = funcs[types[i]]
                if func then
                    func(typeobject, x, y, dir, r, fluid_name)
                end
            end
        end
        return r
    end
end

local function set_object_appearance(object, vsobject_type)
    local vsobject = assert(vsobject_manager:get(object.id))
    vsobject:update {type = vsobject_type}
end


local function refresh_spec_flow_shape(cache_names, object)
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
end

local function show_starting_indicator(prototype_name, x, y)
    ieditor:revert_changes({"INDICATOR"})

    local object = get_object(x, y)
    if not object then
        return
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

            local indicator_object = {
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

            ieditor:set_object(indicator_object, "INDICATOR")
            refresh_spec_flow_shape({"INDICATOR"}, indicator_object)
        end
    end
end

local function is_valid_starting(x, y)
    local object = get_object(x, y)
    if not object then
        return true
    end

    local t = get_valid_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)
    return #t > 0
end

local function prepare_starting(self, datamodel)
    local coord_indicator = self.coord_indicator

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_batch_mode_begin = true
        set_object_appearance(coord_indicator, "construct")
    else
        datamodel.show_batch_mode_begin = false
        set_object_appearance(coord_indicator, "invalid_construct")
    end

    --
    local object = get_object(coord_indicator.x, coord_indicator.y)
    if object then
        show_starting_indicator(self.prototype_name, object.x, object.y)
    end

    --
    if object then
        local fluid_names = ifluid:get_fluid_name(object.prototype_name, object.fluid_name or "")
        if #fluid_names == 1 then
            assert(type(fluid_names[1]) == "string")
            self.fluid_name = fluid_names[1]
            show_fluid_setting(datamodel, fluid_names[1])
        else
            show_fluid_setting(datamodel, "")
        end
    else
        show_fluid_setting(datamodel, "")
    end
end

--------------------------------------------------------------------------------------------------

local function __new_entity(typeobject, dir, x, y, position, vsobject_type)
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

local function show_pipe_indicator(cache_name, prototype_name, starting_x, starting_y, ending_x, ending_y, vsobject_type)
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
    if not self.fluid_name then
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
    self.coord_indicator = __new_entity(typeobject, dir, x, y, position, "construct")

    --
    prepare_starting(self, datamodel)
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

local function get_distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

local function get_starting_fluidbox_coord(starting_x, starting_y, x, y)
    local object = get_object(starting_x, starting_y)
    if not object then
        return starting_x, starting_y
    end

    -- TODO
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    if iprototype:is_batch_mode(typeobject) then
        local dx = math_abs(starting_x - x)
        local dy = math_abs(starting_y - y)
        if dx >= dy then
            if starting_x < x then
                return ifluid:get_dir_coord(starting_x, starting_y, "E"), object.fluid_name, "E"
            else
                return ifluid:get_dir_coord(starting_x, starting_y, "W"), object.fluid_name, "W"
            end
        else
            if starting_y < y then
                return ifluid:get_dir_coord(starting_x, starting_y, "S"), object.fluid_name, "S"
            else
                return ifluid:get_dir_coord(starting_x, starting_y, "N"), object.fluid_name, "N"
            end
        end
    end

    local r
    for _, v in ipairs(get_valid_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
        r = r or v
        if get_distance(r.x, r.y, x, y) > get_distance(v.x, v.y, x, y) then
            r = v
        end
    end

    assert(r)
    local sx, sy = ifluid:get_dir_coord(r.x, r.y, r.dir)
    return sx, sy, r.fluid_name, r.dir
end

local dir_vector = {
    N = {x = 0,  y = -1},
    S = {x = 0,  y = 1},
    W = {x = -1, y = 0},
    E = {x = 1,  y = 0},
}

local function get_ending_fluidbox_coord(starting_fluid_name, starting_dir, starting_x, starting_y, x, y)
    local object = get_object(x, y)
    if not object then
        local dx = math_abs(starting_x - x)
        local dy = math_abs(starting_y - y)
        local vec = assert(dir_vector[starting_dir])
        return starting_x + vec.x * dx, starting_y + vec.y * dy
    end

    local r
    for _, v in ipairs(get_valid_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
        local dx = math_abs(starting_x - v.x)
        local dy = math_abs(starting_y - v.y)
        local vec = assert(dir_vector[v.dir])
        if starting_x == v.x + vec.x * dx and starting_y == v.y + vec.y * dy then
            r = v
        end
    end

    if not r then
        return
    end

    if r.fluid_name ~= starting_fluid_name then
        return
    end

    local dx = math_abs(starting_x - r.x)
    local dy = math_abs(starting_y - r.y)
    return ifluid:get_dir_coord(r.x, r.y, r.dir, dx, dy)
end

local function has_object(starting_coord_x, starting_coord_y, cur_x, cur_y)
    local dx = math_abs(starting_coord_x - cur_x)
    local dy = math_abs(starting_coord_y - cur_y)
    local step

    local find_id = {}
    local starting_object = get_object(starting_coord_x, starting_coord_y)
    if starting_object then
        find_id[starting_object.id] = true
    end
    local ending_object = get_object(cur_x, cur_y)
    if ending_object then
        find_id[ending_object.id] = true
    end

    if dx >= dy then
        if starting_coord_x <= cur_x then
            step = 1
        else
            step = -1
        end

        for vx = starting_coord_x + step, cur_x, step do
            local object = get_object(vx, starting_coord_y)
            if object and not find_id[object.id] then
                return true
            end
        end
        return false
    else
        if starting_coord_y <= cur_y then
            step = 1
        else
            step = -1
        end

        for vy = starting_coord_y, cur_y, step do
            local object = get_object(starting_coord_x, vy)
            if object and not find_id[object.id] then
                return true
            end
        end
        return false
    end
end

local function touch_end(self, datamodel)
    --
    local coord_indicator = assert(self.coord_indicator)
    local coord, position = terrain.adjust_position(camera.get_central_position(), 1, 1) -- 1, 1 水管 / 路块的 width & height
    if not coord then
        return
    end
    local vsobject = assert(vsobject_manager:get(coord_indicator.id))
    vsobject:set_position(position)
    coord_indicator.x, coord_indicator.y = coord[1], coord[2]

    --
    ieditor:revert_changes({"INDICATOR", "TEMPORARY"})

    if not self.starting_coord then
        prepare_starting(self, datamodel)
        return
    end

    local starting_x, starting_y, starting_fluid_name, starting_dir = get_starting_fluidbox_coord(self.starting_coord.x, self.starting_coord.y, coord_indicator.x, coord_indicator.y)
    local ending_x, ending_y = get_ending_fluidbox_coord(starting_fluid_name, starting_dir, starting_x, starting_y, coord_indicator.x, coord_indicator.y)
    if not ending_x then
        datamodel.show_confirm = false
        local dx = math_abs(starting_x - coord_indicator.x)
        local dy = math_abs(starting_y - coord_indicator.y)
        local x, y
        if dx > dy then
            x, y = coord_indicator.x, starting_y
        else
            x, y = starting_x, coord_indicator.y
        end
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_x, starting_y, x, y, "invalid_construct")
        return
    end

    if has_object(self.starting_coord.x, self.starting_coord.y, ending_x, ending_y) then
        datamodel.show_confirm = false
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_x, starting_y, ending_x, ending_y, "invalid_construct")
        return
    end

    local starting_object = get_object(self.starting_coord.x, self.starting_coord.y)
    local cur_object = get_object(ending_x, ending_y)

    -- TODO
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
    if cur_object then
        ieditor:set_object(cur_object, "TEMPORARY")
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

    --
    if not starting_object or not cur_object then
        check_show_confirm(self, datamodel)
        show_pipe_indicator("TEMPORARY", coord_indicator.prototype_name, starting_x, starting_y, ending_x, ending_y, "construct")

        --
        if not self.fluid_name then
            if cur_object then
                -- object.fluid_name 建筑可能没有流体盒子
                local fluid_names = ifluid:get_fluid_name(cur_object.prototype_name, cur_object.fluid_name or "")
                if #fluid_names == 1 then
                    assert(type(fluid_names[1]) == "string")
                    self.fluid_name = fluid_names[1]
                    show_fluid_setting(datamodel, fluid_names[1])
                else
                    show_fluid_setting(datamodel, "")
                end
            else
                show_fluid_setting(datamodel, "")
            end
        end
        return
    end

    if starting_object.id == cur_object.id then
        datamodel.show_confirm = false
        show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_x, starting_y, ending_x, ending_y, "invalid_construct")
        return
    end

    for _, dir in ipairs(ALL_DIR) do
        local x, y = ifluid:get_dir_coord(starting_x, starting_y, dir)
        if x == ending_x and y == ending_y then
            datamodel.show_confirm = false
            show_pipe_indicator("INDICATOR", coord_indicator.prototype_name, starting_x, starting_y, ending_x, ending_y, "invalid_construct")
            return
        end
    end

    check_show_confirm(self, datamodel)
    show_pipe_indicator("TEMPORARY", coord_indicator.prototype_name, starting_x, starting_y, ending_x, ending_y, "construct")
end

local function confirm(self, datamodel)
    assert(self.fluid_name)

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
    self.fluid_name = nil
    hide_fluid_setting(datamodel)
    datamodel.show_confirm = false
    datamodel.show_construct_complete = true
end

local function complete(self, datamodel)
    vsobject_manager:remove(self.coord_indicator.id)
    self.coord_indicator = nil

    self:revert_changes({"INDICATOR", "TEMPORARY"})

    datamodel.show_rotate = false
    datamodel.show_confirm = false
    hide_fluid_setting(datamodel)

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
    if self.starting_coord then
        datamodel.show_confirm = true
    end
    -- TODO 缺少[当前坐标]是否可以作为[结束点]的判断
end

local function batch_mode_begin(self, datamodel)
    assert(self.starting_coord == nil)
    local coord_indicator = assert(self.coord_indicator)
    self.starting_coord = {x = coord_indicator.x, y = coord_indicator.y}

    --
    datamodel.show_batch_mode_begin = false

    --
    local object = get_object(self.starting_coord.x, self.starting_coord.y)
    if object then
        local fluid_names = ifluid:get_fluid_name(object.prototype_name, object.fluid_name or "")
        assert(#fluid_names > 0)
        if #fluid_names == 1 then
            assert(type(fluid_names[1]) == "string")
            self.fluid_name = fluid_names[1]
            show_fluid_setting(datamodel, fluid_names[1])
        else
            show_fluid_setting(datamodel, "")
        end
    else
        show_fluid_setting(datamodel, "")
    end
end

local function clean(self, datamodel)
    if self.coord_indicator then
        vsobject_manager:remove(self.coord_indicator.id)
        self.coord_indicator = nil
    end

    self:revert_changes({"INDICATOR", "TEMPORARY"})
    hide_fluid_setting(datamodel)
    datamodel.show_batch_mode_begin = false
    datamodel.show_confirm = false
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

    -- M.fluid_name
    M.prototype_name = ""
    -- M.starting_coord = {x = xx, y = xx}
    M.batch_mode_begin = batch_mode_begin
    return M
end
return create