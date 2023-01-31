local ecs = ...
local world = ecs.world

local create_builder = ecs.require "editor.builder"
local iprototype = require "gameplay.interface.prototype"
local packcoord = iprototype.packcoord
local unpackcoord = iprototype.unpackcoord
local iconstant = require "gameplay.interface.constant"
local ALL_DIR = iconstant.ALL_DIR
local iobject = ecs.require "object"
local iprototype = require "gameplay.interface.prototype"
local iflow_connector = require "gameplay.interface.flow_connector"
local objects = require "objects"
local terrain = ecs.require "terrain"
local math_abs = math.abs
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local task = ecs.require "task"
local roadnet = ecs.require "roadnet"
local igrid_entity = ecs.require "engine.grid_entity"

local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR
local STATE_NONE  <const> = 0
local STATE_START <const> = 1

local function _get_object(x, y, cache_names)
    local object = objects:coord(x, y, cache_names)
    local road_type, road_mask = roadnet.editor_get(x, y)
    if object then
        assert(not road_type)
        return object
    end

    if road_type then
        local _prototype_name, _dir = roadnet.get_prototype_name(road_type, road_mask)
        return {
            id = iobject.new_object_id(),
            x = x,
            y = y,
            prototype_name = _prototype_name,
            dir = _dir,
            object_state = "none",
        }
    end

    return
end

local function _get_connections(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local r = {}
    if not typeobject.crossing then
        return r
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        r[#r+1] = {x = x, y = y, dir = conn.position[3], roadside = conn.roadside} -- area of road is 1x1
    end
    return r
end

-- NOTE:
-- automatically connects to its neighbors which has crossing, except for road
local function _connect_to_neighbor(x, y, prototype_name, dir)
    local succ, neighbor_x, neighbor_y, dx, dy, connected_dir
    for _, neighbor_dir in ipairs(ALL_DIR) do
        succ, neighbor_x, neighbor_y = terrain:move_coord(x, y, neighbor_dir, 1)
        if not succ then
            goto continue
        end

        local object = _get_object(neighbor_x, neighbor_y, EDITOR_CACHE_NAMES)
        if not object then
            goto continue
        end

        if iprototype.is_road(object.prototype_name) then
            goto continue
        end

        for _, fb in ipairs(_get_connections(object.prototype_name, object.x, object.y, object.dir)) do
            succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
            if succ and dx == x and dy == y then
                prototype_name, dir = iflow_connector.covers_roadside(prototype_name, dir, neighbor_dir, true)
                connected_dir = neighbor_dir
                goto continue -- only one connection can be connected to the endpoint
            end
        end
        ::continue::
    end
    return prototype_name, dir, connected_dir
end

-- NOTE:
-- prototype_name is the prototype_name of the road currently being built
local function _get_covers_connections(prototype_name, object)
    local _prototype_name
    if iprototype.is_road(object.prototype_name) then
        -- because road can replace other road
        _prototype_name = prototype_name
    else
        _prototype_name = object.prototype_name
    end
    return _get_connections(_prototype_name, object.x, object.y, object.dir)
end

-- NOTE:
local function _set_endpoint_connection(State, object, connection, dir)
    if iprototype.is_road(object.prototype_name) then
        local typeobject = iprototype.queryByName("entity", object.prototype_name)
        local _prototype_name, _dir
        -- normal road can replace other road
        _prototype_name, _dir = iflow_connector.covers_flow_type(object.prototype_name, object.dir, typeobject.flow_type)
        _prototype_name, _dir = iflow_connector.set_road_connection(_prototype_name, _dir, dir, true)
        if not _prototype_name or not _dir then
            State.succ = false
            return object.prototype_name, object.dir
        else
            return _prototype_name, _dir
        end
    else
        if not connection then
            State.succ = false
        end
        return object.prototype_name, object.dir
    end
end

-- NOTE:
local function _builder_end(self, datamodel, State, dir, dir_delta)
    local reverse_dir = iprototype.reverse_dir(dir)
    local prototype_name = self.coord_indicator.prototype_name
    local map = {}

    local from_x, from_y
    if State.starting_connection then
        from_x, from_y = State.starting_connection.x, State.starting_connection.y
    else
        from_x, from_y = State.from_x, State.from_y
    end
    local to_x, to_y
    if State.ending_connection then
        to_x, to_y = State.ending_connection.x, State.ending_connection.y
    else
        to_x, to_y = State.to_x, State.to_y
    end
    local x, y = assert(from_x), assert(from_y)

    while true do
        local coord = packcoord(x, y)
        local object = _get_object(x, y, EDITOR_CACHE_NAMES)

        if x == from_x and y == from_y then
            if object then
                map[coord] = {_set_endpoint_connection(State, object, State.starting_connection, dir)}
            else
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(x, y, endpoint_prototype_name, endpoint_dir)
                if not (x == to_x and y == to_y) then
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_road_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                end
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end

        elseif x == to_x and y == to_y then
            if object then
                map[coord] = {_set_endpoint_connection(State, object, State.ending_connection, reverse_dir)}
            else
                local connected_dir
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir, connected_dir = _connect_to_neighbor(x, y, endpoint_prototype_name, endpoint_dir)
                if connected_dir ~= reverse_dir then
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_road_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                end
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end

        else
            if object then
                if not iprototype.is_road(object.prototype_name) then
                    State.succ = false
                    map[coord] = {object.prototype_name, object.dir}
                else
                    local endpoint_prototype_name, endpoint_dir = object.prototype_name, object.dir
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_road_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_road_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                    map[coord] = {endpoint_prototype_name, endpoint_dir}
                end
            else
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_road_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_road_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end

        end

        if x == to_x and y == to_y then
            break
        end
        x, y = x + dir_delta.x, y + dir_delta.y
    end

    local object_state = State.succ and "construct" or "invalid_construct"
    self.coord_indicator.state = object_state

    -- TODO: map may be include some non-road objects, such as some building which have crossing, only for changing the state of the building
    for coord, v in pairs(map) do
        local x, y = unpackcoord(coord)
        local road_type, road_mask = roadnet.get_road_mask(v[1], v[2])
        roadnet.editor_set(x, y, road_type, road_mask, object_state)
    end

    datamodel.show_laying_road_confirm = State.succ
end

-- NOTE:
local function _builder_init(self, datamodel)
    local coord_indicator = self.coord_indicator
    local prototype_name = self.coord_indicator.prototype_name
    local init_prototype_name = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)

    local function show_indicator(prototype_name, object)
        local succ, dx, dy, obj, _prototype_name, _dir
        for _, conn in ipairs(_get_covers_connections(prototype_name, object)) do
            succ, dx, dy = terrain:move_coord(conn.x, conn.y, conn.dir, 1)
            if not succ then
                goto continue
            end
            if not self:check_construct_detector(prototype_name, dx, dy) then
                goto continue
            end

            obj = _get_object(dx, dy, EDITOR_CACHE_NAMES)
            if obj then
                -- road can replace other road
                if not iprototype.is_road(obj.prototype_name) then
                    goto continue
                end
            end

            -- don't need to use set_road_connection() here, because the prototype_name is not a road without roadside
            -- why use DEFAULT_DIR? because iprototype.reverse_dir(conn.dir) will cause assert error by iflow_connector.set_connection(), such as '管道1-O型' + S
            _prototype_name, _dir = iflow_connector.set_connection(init_prototype_name, DEFAULT_DIR, iprototype.reverse_dir(conn.dir), true)
            if _prototype_name then
                local typeobject = iprototype.queryByName("entity", _prototype_name)
                obj = iobject.new {
                    prototype_name = _prototype_name,
                    dir = _dir,
                    x = dx,
                    y = dy,
                    srt = {
                        t = terrain:get_position_by_coord(dx, dy, iprototype.rotate_area(typeobject.area, _dir)),
                    },
                    state = "indicator",
                    object_state = "none",
                }
                objects:set(obj, "INDICATOR")
            end
            ::continue::
        end
    end

    local function is_valid_starting(x, y)
        local object = _get_object(x, y, EDITOR_CACHE_NAMES)
        if not object then
            return true
        end
        return #_get_covers_connections(prototype_name, object) > 0
    end

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_laying_road_begin = true
        coord_indicator.state = "construct"

        local object = _get_object(coord_indicator.x, coord_indicator.y, EDITOR_CACHE_NAMES)
        if object then
            show_indicator(prototype_name, object)
        end
    else
        datamodel.show_laying_road_begin = false
        coord_indicator.state = "invalid_construct"
    end
end

-- sort by distance and direction
-- prototype_name is the prototype_name of the road currently being built
local function _find_starting_connection(prototype_name, object, dx, dy, dir)
    local connections = _get_covers_connections(prototype_name, object)
    assert(#connections > 0) -- promised by _builder_init()

    local function _get_distance(x1, y1, x2, y2)
        return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
    end

    table.sort(connections, function(a, b)
        local dist1 = _get_distance(a.x, a.y, dx, dy)
        local dist2 = _get_distance(b.x, b.y, dx, dy)
        if dist1 < dist2 then
            return true
        elseif dist1 > dist2 then
            return false
        else
            return ((a.dir == dir) and 0 or 1) < ((b.dir == dir) and 0 or 1)
        end
    end)
    return connections[1]
end

-- NOTE:
local function _builder_start(self, datamodel)
    local from_x, from_y = self.from_x, self.from_y
    local to_x, to_y = self.coord_indicator.x, self.coord_indicator.y
    local prototype_name = self.coord_indicator.prototype_name
    local starting = _get_object(from_x, from_y, EDITOR_CACHE_NAMES)
    local dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)

    local State = {
        succ = true,
        starting_connection = nil,
        ending_connection = nil,
        from_x = from_x,
        from_y = from_y,
        to_x = to_x,
        to_y = to_y,
    }

    if starting then
        -- starting object should at least have one connection, promised by _builder_init()
        local connection = _find_starting_connection(prototype_name, starting, to_x, to_y, dir)
        State.starting_connection = connection
        if connection.dir ~= dir then
            State.succ = false
        end

        local succ
        succ, to_x, to_y = terrain:move_coord(connection.x, connection.y, dir,
            math_abs(to_x - connection.x),
            math_abs(to_y - connection.y)
        )
        if not succ then
            State.succ = false
        end

        local ending = _get_object(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            if starting.x == ending.x and starting.y == ending.y then
                State.succ = false
                State.ending_connection = connection
            else
                for _, another in ipairs(_get_covers_connections(prototype_name, ending)) do
                    if another.dir ~= iprototype.reverse_dir(dir) then
                        goto continue
                    end
                    succ, to_x, to_y = terrain:move_coord(connection.x, connection.y, dir,
                        math_abs(another.x - connection.x),
                        math_abs(another.y - connection.y)
                    )
                    if not succ then
                        goto continue
                    end
                    if to_x == another.x and to_y == another.y then
                        State.ending_connection = another
                        _builder_end(self, datamodel, State, dir, delta)
                        return State.succ
                    end
                    ::continue::
                end
                State.succ = false
            end
        end

        if not self:check_construct_detector(prototype_name, to_x, to_y, DEFAULT_DIR) then
            State.succ = false
        end
        State.to_x, State.to_y = to_x, to_y
        dir, delta = iprototype.calc_dir(connection.x, connection.y, to_x, to_y)
        _builder_end(self, datamodel, State, dir, delta)
        return State.succ
    else
        if not self:check_construct_detector(prototype_name, from_x, from_y, DEFAULT_DIR) then
            State.succ = false
        end

        State.from_x, State.from_y = from_x, from_y
        local succ
        succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir,
            math_abs(to_x - from_x),
            math_abs(to_y - from_y)
        )
        if not succ then
            State.succ = false
        end
        State.to_x, State.to_y = to_x, to_y

        local ending = _get_object(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            for _, fluidbox in ipairs(_get_covers_connections(prototype_name, ending)) do
                if fluidbox.dir ~= iprototype.reverse_dir(dir) then
                    goto continue
                end
                succ, to_x, to_y = terrain:move_coord(fluidbox.x, fluidbox.y, dir,
                    math_abs(from_x - fluidbox.x),
                    math_abs(from_y - fluidbox.y)
                )
                if not succ then
                    goto continue
                end
                if to_x == fluidbox.x and to_y == fluidbox.y then
                    State.ending_connection = fluidbox
                    _builder_end(self, datamodel, State, dir, delta)
                    return State.succ
                end
                ::continue::
            end
            State.succ = false
        end

        --
        local succ
        succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir,
            math_abs(to_x - from_x),
            math_abs(to_y - from_y)
        )
        if not succ then
            State.succ = false
        end
        if not self:check_construct_detector(prototype_name, to_x, to_y, DEFAULT_DIR) then
            State.succ = false
        end
        State.to_x, State.to_y = to_x, to_y
        dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)
        _builder_end(self, datamodel, State, dir, delta)
        return State.succ
    end
end

--------------------------------------------------------------------------------------------------
local function new_entity(self, datamodel, typeobject, x, y)
    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", terrain._width, terrain._height, terrain.tile_size, {t = {0, 0.1, 0}})
    end
    self.grid_entity:show(true)

    iobject.remove(self.coord_indicator)
    local dir = DEFAULT_DIR

    self.coord_indicator = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        srt = {
            t = terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)),
        },
        state = "construct",
        object_state = "none",
    }

    --
    _builder_init(self, datamodel)
end

local function touch_move(self, datamodel, delta_vec)
    if self.coord_indicator then
        iobject.move_delta(self.coord_indicator, delta_vec)
    end
end

local function touch_end(self, datamodel)
    if not self.coord_indicator then
        return
    end
    local _, x, y = iobject.align(self.coord_indicator)
    self.coord_indicator.x, self.coord_indicator.y = x, y
    self:revert_changes({"INDICATOR"})
    roadnet.editor_clear_constructing()

    if self.state ~= STATE_START then
        _builder_init(self, datamodel)
        return false
    else
        return _builder_start(self, datamodel)
    end
end

local function complete(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    self:revert_changes({"INDICATOR"})
    roadnet.editor_clear_constructing()
    roadnet.editor_build()

    datamodel.show_rotate = false
    datamodel.show_laying_road_confirm = false
    datamodel.show_laying_road_cancel = false
    datamodel.show_laying_road_begin = false

    task.update_progress("routemap")
end

local function laying_pipe_begin(self, datamodel)
    self:revert_changes({"INDICATOR"})
    roadnet.editor_clear_constructing()

    datamodel.show_laying_road_begin = false
    datamodel.show_laying_road_cancel = true

    self.state = STATE_START
    self.from_x = self.coord_indicator.x
    self.from_y = self.coord_indicator.y

    return _builder_start(self, datamodel)
end

local function laying_pipe_cancel(self, datamodel)
    self:revert_changes({"INDICATOR"})
    roadnet.editor_clear_constructing()

    self.state = STATE_NONE
    datamodel.show_laying_road_confirm = false
    datamodel.show_laying_road_cancel = false
end

local function laying_pipe_confirm(self, datamodel)
    roadnet.editor_confirm()

    self.state = STATE_NONE
    datamodel.show_laying_road_confirm = false
    datamodel.show_laying_road_cancel = false
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
    end

    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    self:revert_changes({"INDICATOR"})
    roadnet.editor_clear_constructing()

    datamodel.show_rotate = false
    self.state = STATE_NONE
    datamodel.show_laying_road_confirm = false
    datamodel.show_laying_road_cancel = false
    datamodel.show_laying_road_begin = false
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
    M.laying_pipe_begin = laying_pipe_begin
    M.laying_pipe_cancel = laying_pipe_cancel
    M.laying_pipe_confirm = laying_pipe_confirm
    return M
end
return create