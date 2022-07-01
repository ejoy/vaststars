local ecs = ...
local world = ecs.world

local create_builder = ecs.require "editor.builder"
local iprototype = require "gameplay.interface.prototype"
local packcoord = iprototype.packcoord
local unpackcoord = iprototype.unpackcoord
local iflow_shape = require "gameplay.utility.flow_shape"
local set_shape_edge = iflow_shape.set_shape_edge
local iconstant = require "gameplay.interface.constant"
local ALL_DIR = iconstant.ALL_DIR
local ifluid = require "gameplay.interface.fluid"
local global = require "global"
local iobject = ecs.require "object"
local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local flow_shape = require "gameplay.utility.flow_shape"
local ieditor = ecs.require "editor.editor"
local terrain = ecs.require "terrain"

local EDITOR_CACHE_CONSTRUCTED = {"CONFIRM", "CONSTRUCTED"}
local EDITOR_CACHE_TEMPORARY = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}

local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR
local STATE_NONE  <const> = 0
local STATE_START <const> = 1

local function _show_failed(self, prototype_name, from_x, from_y, to_x, to_y)
    assert(from_x == to_x or from_y == to_y)
    self.coord_indicator.state = "invalid_construct"
    if from_x == to_x and from_y == to_y then
        return
    end

    local dir = iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local function uniquekey(x, y, dir)
        if dir == "E" then
            x = x + 1
            dir = "W"
        elseif dir == "S" then
            y = y + 1
            dir = "N"
        end
        return ("%d,%d,%s"):format(x, y, dir)
    end

    local map = {}
    local connections = {}
    for x = from_x, to_x do
        for y = from_y, to_y do
            local opposite_dir = iprototype.opposite_dir(dir)
            local key

            key = uniquekey(x, y, dir)
            if map[key] then
                connections[#connections+1] = {x = x, y = y, dir = dir}

                local succ, _x, _y = terrain:move_coord(x, y, opposite_dir, 1)
                assert(succ)
                connections[#connections+1] = {x = _x, y = _y, dir = opposite_dir}
            else
                map[key] = true
            end

            key = uniquekey(x, y, opposite_dir)
            if map[key] then
                connections[#connections+1] = {x = x, y = y, dir = opposite_dir}

                local succ, _x, _y = terrain:move_coord(x, y, dir, 1)
                assert(succ)
                connections[#connections+1] = {x = _x, y = _y, dir = dir}
            else
                map[key] = true
            end
        end
    end

    for x = from_x, to_x do
        for y = from_y, to_y do
            local object = objects:coord(x, y, EDITOR_CACHE_CONSTRUCTED)
            if not object then
                object = iobject.new {
                    prototype_name = flow_shape.get_init_prototype_name(prototype_name),
                    dir = DEFAULT_DIR,
                    x = x,
                    y = y,
                    fluid_name = "",
                    fluidflow_network_id = 0,
                    state = "invalid_construct",
                }
                objects:set(object, EDITOR_CACHE_TEMPORARY[1])
            else
                local o = iobject.clone(object)
                o.state = "invalid_construct"
                objects:set(o, EDITOR_CACHE_TEMPORARY[1])
            end
            ieditor:refresh_flow_shape(EDITOR_CACHE_TEMPORARY, EDITOR_CACHE_TEMPORARY[1], object, iprototype.opposite_dir(dir), x, y)
        end
    end
end

local function _shift_pipe_prototype_name(prototype_name)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    if typeobject.pipe then
        return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format("X"))
    end
    if typeobject.pipe_to_ground then
        return prototype_name:gsub("(.*%-)(%u%u)(.*)", ("%%1%s%%3"):format("JI"))
    end
    return prototype_name
end

local function _update_fluid_name(State, fluid_name, fluidflow_network_id)
    if State.fluid_name ~= "" then
        if fluid_name ~= "" then
            if State.fluid_name ~= fluid_name then
                State.failed = true
            end
        else
            assert(fluidflow_network_id ~= 0)
            State.fluidflow_network_ids[fluidflow_network_id] = true
        end
    else
        if fluid_name ~= "" then
            State.fluid_name = fluid_name
        else
            assert(fluidflow_network_id ~= 0)
            State.fluidflow_network_ids[fluidflow_network_id] = true
        end
    end
end

-- auto connect with a neighbor who has fluidbox
local function _set_endpoint_connect(State, x, y)
    local pipe_edge = 0
    local succ, _x, _y
    for _, dir in ipairs(ALL_DIR) do
        succ, _x, _y = terrain:move_coord(x, y, dir, 1)
        if not succ then
            goto continue
        end

        local object = objects:coord(_x, _y, EDITOR_CACHE_TEMPORARY)
        if not object then
            goto continue
        end

        if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
            goto continue
        end

        for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
            succ, _x, _y = terrain:move_coord(v.x, v.y, v.dir, 1)
            if succ and _x == x and _y == y then
                pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(dir), true)
                _update_fluid_name(State, v.fluid_name, object.fluidflow_network_id)
                break
            end
        end
        ::continue::
    end
    return pipe_edge
end

local function _set_pipe(State, x, y)
    local pipe_edge = 0
    local object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
    if object then
        if not iprototype.is_pipe(object.prototype_name) then
            State.failed = true
        else
            pipe_edge = iflow_shape.prototype_name_to_state(object.prototype_name, object.dir)
            _update_fluid_name(State, object.fluid_name, object.fluidflow_network_id)
        end
    end
    return pipe_edge
end

local function _get_distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

-- fluidboxes return by ifluid:get_fluidbox()
local function _match_fluidbox(fluidboxes, x, y, dir)
    local min = math.maxinteger
    local f
    for _, v in ipairs(fluidboxes) do
        if v.dir == dir then
            local dist = _get_distance(v.x, v.y, x, y)
            if dist < min then
                min = dist
                f = v
            end
        end
    end
    return f
end

local function state_end(self, datamodel, from_x, from_y, to_x, to_y)
    self.coord_indicator.state = "construct"

    local dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir,
        math.abs(from_x - to_x),
        math.abs(from_y - to_y)
    )
    if not succ then
        _show_failed(self, datamodel.prototype_name, from_x, from_y, to_x, to_y)
        return
    end

    local prototype_name = self.coord_indicator.prototype_name
    local dir_num = iprototype.dir_tonumber(iprototype.calc_dir(from_x, from_y, to_x, to_y))
    local opposite_dir_num = iprototype.dir_tonumber(iprototype.opposite_dir(dir))

    local map = {}
    local coord
    local State = {
        failed = false,
        fluid_name = "",
        fluidflow_network_ids = {},
    }

    local x, y = from_x, from_y
    while true do
        coord = packcoord(x, y)

        if x == from_x and y == from_y then
            local _object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
            if _object then
                if iprototype.is_pipe(_object.prototype_name) then
                    local pipe_edge = _set_pipe(State, x, y)
                    pipe_edge = set_shape_edge(pipe_edge, dir_num, true)
                    map[coord] = pipe_edge

                elseif iprototype.is_pipe_to_ground(_object.prototype_name) then
                    for _, v in ipairs(ifluid:get_fluidbox(_object.prototype_name, _object.x, _object.y, _object.dir, _object.fluid_name)) do
                        if v.ground and v.dir == iprototype.opposite_dir(dir) then
                            _update_fluid_name(State, _object.fluid_name, _object.fluidflow_network_id)
                            break -- pipe to ground only has one fluidbox in one direction
                        end
                    end
                    map[coord] = 0

                else
                    -- entity is not a pipe or a pipe to ground, (from_x, from_y) is the fluidbox coord of the entity
                    -- find the fluidbox of the entity equal to (from_x, from_y) -- TODO: optimize
                    local f = _match_fluidbox(ifluid:get_fluidbox(_object.prototype_name, _object.x, _object.y, _object.dir, _object.fluid_name), from_x, from_y, dir)
                    if not f then -- no fluidbox in the direction of the entity
                        State.failed = true
                    else
                        _update_fluid_name(State, f.fluid_name, _object.fluidflow_network_id)
                    end
                    map[coord] = 0
                end
            else
                local pipe_edge = _set_endpoint_connect(State, x, y)
                if not (x == to_x and y == to_y) then
                    pipe_edge = set_shape_edge(pipe_edge, dir_num, true)
                end
                map[coord] = pipe_edge
            end

        elseif x == to_x and y == to_y then
            local _object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
            if _object then
                if iprototype.is_pipe(_object.prototype_name) then
                    local pipe_edge = _set_pipe(State, x, y)
                    pipe_edge = set_shape_edge(pipe_edge, opposite_dir_num, true)
                    map[coord] = pipe_edge

                elseif iprototype.is_pipe_to_ground(_object.prototype_name) then
                    for _, v in ipairs(ifluid:get_fluidbox(_object.prototype_name, _object.x, _object.y, _object.dir, _object.fluid_name)) do
                        if v.ground and v.dir == dir then
                            _update_fluid_name(State, v.fluid_name, _object.fluidflow_network_id)
                            break -- pipe to ground only has one fluidbox in one direction
                        end
                    end
                    map[coord] = 0

                else
                    for _, v in ipairs(ifluid:get_fluidbox(_object.prototype_name, _object.x, _object.y, _object.dir, _object.fluid_name)) do
                        if v.dir == iprototype.opposite_dir(dir) and (from_x == v.x or from_y == v.y) then
                            _update_fluid_name(State, v.fluid_name, _object.fluidflow_network_id)
                            break -- only one fluidbox aligned with the start point
                        end
                    end
                    map[coord] = 0
                end
            else
                local pipe_edge = _set_endpoint_connect(State, x, y)
                pipe_edge = set_shape_edge(pipe_edge, opposite_dir_num, true)
                map[coord] = pipe_edge
            end
        else
            local pipe_edge = _set_pipe(State, x, y)
            pipe_edge = set_shape_edge(pipe_edge, dir_num, true)
            pipe_edge = set_shape_edge(pipe_edge, opposite_dir_num, true)
            map[coord] = pipe_edge
        end

        if x == to_x and y == to_y then
            break
        end
        x, y = x + delta.x, y + delta.y
    end

    local fluidflow_network_id = 0
    if not State.failed and State.fluid_name == "" then
        global.fluidflow_network_id = global.fluidflow_network_id + 1
        fluidflow_network_id = global.fluidflow_network_id
    end
    local object_state = State.failed and "invalid_construct" or "construct"

    for coord, state in pairs(map) do
        local x, y = unpackcoord(coord)
        local shape, dir = iflow_shape.to_type_dir(state)
        local object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
        if object then
            if iprototype.is_pipe(object.prototype_name) then
                local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
                _object.prototype_name = iflow_shape.to_prototype_name(prototype_name, shape)
                _object.dir = dir
                _object.fluid_name = State.fluid_name
                _object.fluidflow_network_id = fluidflow_network_id
                _object.state = object_state
                objects:set(_object, EDITOR_CACHE_TEMPORARY[1])
            elseif iprototype.is_pipe_to_ground(object.prototype_name) then
                local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
                _object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JI")
                _object.fluid_name = State.fluid_name
                _object.fluidflow_network_id = fluidflow_network_id
                _object.state = object_state
                objects:set(_object, EDITOR_CACHE_TEMPORARY[1])
            else
                local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
                local typeobject = iprototype.queryByName("entity", _object.prototype_name)
                if iprototype.has_type(typeobject.type, "fluidbox") and _object.fluid_name ~= State.fluid_name then
                    _object.fluid_name = State.fluid_name
                end
                _object.state = object_state
            end
        else
            object = iobject.new {
                prototype_name = iflow_shape.to_prototype_name(prototype_name, shape),
                dir = dir,
                x = x,
                y = y,
                fluid_name = State.fluid_name,
                fluidflow_network_id = fluidflow_network_id,
                state = object_state,
            }
            objects:set(object, EDITOR_CACHE_TEMPORARY[1])
        end
    end

    for fluidflow_network_id in pairs(State.fluidflow_network_ids) do
        for _, object in objects:selectall("fluidflow_network_id", fluidflow_network_id, EDITOR_CACHE_TEMPORARY) do
            local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
            if iprototype.has_type(iprototype.queryByName("entity", _object.prototype_name).type, "fluidbox") then -- TODO: check why this is needed
                _object.fluid_name = State.fluid_name
                _object.fluidflow_network_id = fluidflow_network_id
            end
        end
    end

    datamodel.show_laying_pipe_confirm = not State.failed
end

local function state_init(self, datamodel)
    local coord_indicator = self.coord_indicator

    local function show_indicator(prototype_name, object)
        local function get_check_connect_prototype_name(prototype_name)
            local typeobject = iprototype.queryByName("entity", prototype_name)
            if typeobject.pipe then
                return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format("X"))
            end
            return prototype_name
        end

        local succ, dx, dy, obj
        for _, v in ipairs(ifluid:get_fluidbox(get_check_connect_prototype_name(object.prototype_name), object.x, object.y, object.dir)) do
            succ, dx, dy = terrain:move_coord(v.x, v.y, v.dir, 1)
            if succ then
                obj = objects:coord(dx, dy, EDITOR_CACHE_TEMPORARY)
                if not obj then
                    obj = iobject.new {
                        prototype_name = prototype_name,
                        dir = iprototype.opposite_dir(v.dir),
                        x = dx,
                        y = dy,
                        fluid_name = "",
                        fluidflow_network_id = "",
                        state = "indicator",
                    }
                    objects:set(obj, "INDICATOR")
                end
            end
        end
    end

    local function is_valid_starting(x, y)
        local object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
        if not object then
            return true
        end
        local t = ifluid:get_fluidbox(_shift_pipe_prototype_name(object.prototype_name), object.x, object.y, object.dir, object.fluid_name)
        return #t > 0
    end

    local function get_pipe_prototype_name(prototype_name, shape)
        assert(#shape == 1)
        return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(shape))
    end

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_laying_pipe_begin = true
        coord_indicator.state = "construct"

        local object = objects:coord(coord_indicator.x, coord_indicator.y, EDITOR_CACHE_TEMPORARY)
        if object then
            show_indicator(get_pipe_prototype_name(coord_indicator.prototype_name, "U"), object)
        end
    else
        datamodel.show_laying_pipe_begin = false
        coord_indicator.state = "invalid_construct"
    end
end

local function state_start(self, datamodel)
    local starting_object = objects:coord(self.from_x, self.from_y, EDITOR_CACHE_TEMPORARY)
    local ending_object = objects:coord(self.coord_indicator.x, self.coord_indicator.y, EDITOR_CACHE_TEMPORARY)
    if starting_object then
        local fluidboxes = ifluid:get_fluidbox(_shift_pipe_prototype_name(starting_object.prototype_name), starting_object.x, starting_object.y, starting_object.dir)
        if #fluidboxes <= 0 then
            self.coord_indicator.state = "invalid_construct"
            datamodel.show_laying_pipe_confirm = false
            return
        end

        local dir = iprototype.calc_dir(self.from_x, self.from_y, self.coord_indicator.x, self.coord_indicator.y)
        table.sort(fluidboxes, function(a, b) -- TODO: sort by distance and direction
            local dist1 = _get_distance(a.x, a.y, self.coord_indicator.x, self.coord_indicator.y)
            local dist2 = _get_distance(b.x, b.y, self.coord_indicator.x, self.coord_indicator.y)
            if dist1 < dist2 then
                return true
            elseif dist1 > dist2 then
                return false
            end

            return ((a.dir == dir) and 0 or 1) < ((b.dir == dir) and 0 or 1)
        end)

        local from_x, from_y = fluidboxes[1].x, fluidboxes[1].y
        if ending_object then
            if starting_object.id == ending_object.id then
                self.coord_indicator.state = "invalid_construct"
                datamodel.show_laying_pipe_confirm = false
                return
            end

            for _, v in ipairs(ifluid:get_fluidbox(ending_object.prototype_name, ending_object.x, ending_object.y, ending_object.dir)) do
                if v.dir == iprototype.opposite_dir(dir) and (from_x == v.x or from_y == v.y) then
                    state_end(self, datamodel, from_x, from_y, v.x, v.y)
                    return
                end
            end
        end

        local succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir, math.abs(self.coord_indicator.x - from_x), math.abs(self.coord_indicator.y - from_y))
        if not succ then -- TODO: check map boundary
            self.coord_indicator.state = "invalid_construct"
            datamodel.show_laying_pipe_confirm = false
            return
        end
        state_end(self, datamodel, from_x, from_y, to_x, to_y)
        return
    else
        if ending_object then
            local from_x, from_y = self.from_x, self.from_y
            local dir = iprototype.calc_dir(self.from_x, self.from_y, self.coord_indicator.x, self.coord_indicator.y)

            if iprototype.is_pipe(ending_object.prototype_name) or iprototype.is_pipe_to_ground(ending_object.prototype_name) then
                state_end(self, datamodel, from_x, from_y, self.coord_indicator.x, self.coord_indicator.y)
                return
            else
                for _, v in ipairs(ifluid:get_fluidbox(ending_object.prototype_name, ending_object.x, ending_object.y, ending_object.dir)) do
                    if v.dir == iprototype.opposite_dir(dir) and (from_x == v.x or from_y == v.y) then
                        state_end(self, datamodel, from_x, from_y, v.x, v.y)
                        return
                    end
                end

                local succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir, math.abs(self.coord_indicator.x - from_x), math.abs(self.coord_indicator.y - from_y))
                if not succ then -- TODO: check map boundary
                    self.coord_indicator.state = "invalid_construct"
                    datamodel.show_laying_pipe_confirm = false
                    return
                end
                state_end(self, datamodel, from_x, from_y, to_x, to_y)
                return
            end
        else
            local from_x, from_y = self.from_x, self.from_y
            local dir = iprototype.calc_dir(self.from_x, self.from_y, self.coord_indicator.x, self.coord_indicator.y)
            local succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir, math.abs(self.coord_indicator.x - from_x), math.abs(self.coord_indicator.y - from_y))
            if not succ then -- TODO: check map boundary
                self.coord_indicator.state = "invalid_construct"
                datamodel.show_laying_pipe_confirm = false
                return
            end
            state_end(self, datamodel, from_x, from_y, to_x, to_y)
            return
        end
    end
end

--------------------------------------------------------------------------------------------------
local function new_entity(self, datamodel, typeobject)
    iobject.remove(self.coord_indicator)

    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir)
    self.prototype_name = typeobject.name
    self.coord_indicator = iobject.new {
        prototype_name = typeobject.name,
        dir = DEFAULT_DIR,
        x = x,
        y = y,
        fluid_name = "",
        fluidflow_network_id = 0,
        state = "construct"
    }

    --
    state_init(self, datamodel)
end

local function touch_move(self, datamodel, delta_vec)
    iobject.move_delta(self.coord_indicator, delta_vec)
end

local function touch_end(self, datamodel)
    iobject.align(self.coord_indicator)
    ieditor:revert_changes({"INDICATOR", "TEMPORARY"})

    if self.state ~= STATE_START then
        state_init(self, datamodel)
    else
        state_start(self, datamodel)
    end
end

local function complete(self, datamodel)
    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    self:revert_changes({"INDICATOR", "TEMPORARY"})

    datamodel.show_rotate = false
    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = false

    self.super.complete(self)

    datamodel.show_laying_pipe_begin = false
    datamodel.show_construct_complete = false
end

local function laying_pipe_begin(self, datamodel)
    iobject.align(self.coord_indicator)
    self:revert_changes({"INDICATOR", "TEMPORARY"})
    datamodel.show_laying_pipe_begin = false
    datamodel.show_laying_pipe_cancel = true

    self.state = STATE_START
    self.from_x = self.coord_indicator.x
    self.from_y = self.coord_indicator.y

    state_start(self, datamodel)
end

local function laying_pipe_cancel(self, datamodel)
    self:revert_changes({"INDICATOR", "TEMPORARY"})
    local typeobject = iprototype.queryByName("entity", self.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.state = STATE_NONE
    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = false
    datamodel.show_construct_complete = true
end

local function laying_pipe_confirm(self, datamodel)
    for _, object in objects:all("TEMPORARY") do
        object.state = "confirm"
        object.PREPARE = true
    end
    objects:commit("TEMPORARY", "CONFIRM")

    local typeobject = iprototype.queryByName("entity", self.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.state = STATE_NONE
    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = false
    datamodel.show_construct_complete = true
end

local function clean(self, datamodel)
    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    self:revert_changes({"INDICATOR", "TEMPORARY"})
    datamodel.show_construct_complete = false
    datamodel.show_rotate = false
    self.state = STATE_NONE
    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = false
    datamodel.show_laying_pipe_begin = false
    self.super.clean(self, datamodel)
end

local function create()
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.complete = complete

    M.clean = clean

    M.prototype_name = ""
    M.state = STATE_NONE
    -- M.from_x
    -- M.from_y
    M.laying_pipe_begin = laying_pipe_begin
    M.laying_pipe_cancel = laying_pipe_cancel
    M.laying_pipe_confirm = laying_pipe_confirm
    return M
end
return create