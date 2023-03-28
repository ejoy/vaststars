local ecs = ...
local world = ecs.world

local create_builder = ecs.require "editor.builder"
local iprototype = require "gameplay.interface.prototype"
local packcoord = iprototype.packcoord
local unpackcoord = iprototype.unpackcoord
local iconstant = require "gameplay.interface.constant"
local ALL_DIR = iconstant.ALL_DIR
local ifluid = require "gameplay.interface.fluid"
local global = require "global"
local iobject = ecs.require "object"
local iprototype = require "gameplay.interface.prototype"
local iflow_connector = require "gameplay.interface.flow_connector"
local objects = require "objects"
local terrain = ecs.require "terrain"
local math_abs = math.abs
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local igrid_entity = ecs.require "engine.grid_entity"
local logistic_coord = ecs.require "terrain"
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local ientity = require "gameplay.interface.entity"
local gameplay_core = require "gameplay.core"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local math3d = require "math3d"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})

local REMOVE <const> = {}
local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR

-- To distinguish between "batch construction" and "batch teardown" in the touch_end event.
local STATE_NONE  <const> = 0
local STATE_START <const> = 1
local STATE_TEARDOWN <const> = 2

local function _get_object(self, x, y, cache_names)
    local coord = iprototype.packcoord(x, y)
    local tmp = self.pending[coord]
    if tmp == REMOVE then
        return
    end

    return objects:coord(x, y, cache_names)
end

-- fluidflow_id may be nil, only used for fluidbox
local function _update_fluid_name(State, fluid_name, fluidflow_id)
    if State.fluid_name ~= "" then
        if fluid_name ~= "" then
            if State.fluid_name ~= fluid_name then
                State.succ = false
            end
        end
        if fluidflow_id then
            State.fluidflow_ids[fluidflow_id] = true
        end
    else
        if fluid_name ~= "" then
            State.fluid_name = fluid_name
        end
        if fluidflow_id then
            State.fluidflow_ids[fluidflow_id] = true
        end
    end
end

-- automatically connects to its neighbors which has fluidbox, except for pipe or pipe to ground
local function _connect_to_neighbor(x, y, State, prototype_name, dir)
    local succ, neighbor_x, neighbor_y, dx, dy
    for _, neighbor_dir in ipairs(ALL_DIR) do
        succ, neighbor_x, neighbor_y = terrain:move_coord(x, y, neighbor_dir, 1)
        if not succ then
            goto continue
        end

        local object = objects:coord(neighbor_x, neighbor_y, EDITOR_CACHE_NAMES)
        if not object then
            goto continue
        end

        if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
            goto continue
        end

        for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
            succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
            if succ and dx == x and dy == y then
                prototype_name, dir = iflow_connector.set_connection(prototype_name, dir, neighbor_dir, true)
                _update_fluid_name(State, fb.fluid_name, object.fluidflow_id) -- TODO: different fluid just don't connect automatically, but it doesn't cause fatal error
                goto continue -- only one fluidbox can be connected to the endpoint
            end
        end
        ::continue::
    end
    return prototype_name, dir
end

-- prototype_name is the prototype_name of the pipe currently being built
local function _get_covers_connections(prototype_name, object)
    local _prototype_name
    if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        -- because pipe can replace other pipe
        _prototype_name = prototype_name
    else
        _prototype_name = object.prototype_name
    end

    return ifluid:get_fluidbox(_prototype_name, object.x, object.y, object.dir, object.fluid_name)
end

local function _set_endpoint_connection(prototype_name, State, object, connection, dir)
    if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        _update_fluid_name(State, object.fluid_name, object.fluidflow_id)

        local typeobject = iprototype.queryByName(object.prototype_name)
        local _prototype_name, _dir
        -- normal pipe can replace other pipe, including pipe to ground
        _prototype_name, _dir = iflow_connector.covers_flow_type(object.prototype_name, object.dir, typeobject.flow_type)
        _prototype_name, _dir = iflow_connector.set_connection(_prototype_name, _dir, dir, true)
        if not _prototype_name or not _dir then
            State.succ = false
            return object.prototype_name, object.dir
        else
            return _prototype_name, _dir
        end
    else
        if not connection then
            State.succ = false
        else
            _update_fluid_name(State, connection.fluid_name, object.fluidflow_id)
        end
        return object.prototype_name, object.dir
    end
end

local function _builder_end(self, datamodel, State, dir, dir_delta)
    local reverse_dir = iprototype.reverse_dir(dir)
    local prototype_name = self.coord_indicator.prototype_name
    local typeobject = iprototype.queryByName(prototype_name)

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
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)

        if x == from_x and y == from_y then
            if object then
                map[coord] = {_set_endpoint_connection(prototype_name, State, object, State.starting_connection, dir)}
            else
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(x, y, State, endpoint_prototype_name, endpoint_dir)
                if not (x == to_x and y == to_y) then
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                end
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end

        elseif x == to_x and y == to_y then
            if object then
                map[coord] = {_set_endpoint_connection(prototype_name, State, object, State.ending_connection, reverse_dir)}
            else
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(x, y, State, endpoint_prototype_name, endpoint_dir)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end
        else
            if object then
                if not iprototype.is_pipe(object.prototype_name) then
                    State.succ = false
                    map[coord] = {object.prototype_name, object.dir}
                else
                    _update_fluid_name(State, object.fluid_name, object.fluidflow_id)
                    local endpoint_prototype_name, endpoint_dir = object.prototype_name, object.dir
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                    map[coord] = {endpoint_prototype_name, endpoint_dir}
                end
            else
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end
        end

        if x == to_x and y == to_y then
            break
        end
        x, y = x + dir_delta.x, y + dir_delta.y
    end

    local new_fluidflow_id = 0
    if State.succ then
        global.fluidflow_id = global.fluidflow_id + 1
        new_fluidflow_id = global.fluidflow_id
    end
    local state = State.succ and "construct" or "invalid_construct"

    -- TODO: map may be include some non-pipe objects, such as some building which have fluidboxes, only for changing the state of the building
    for coord, v in pairs(map) do
        local x, y = unpackcoord(coord)
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if object then
            object = assert(objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone))
            if object.prototype_name ~= v[1] or object.dir ~= v[2] then
                object.prototype_name = v[1]
                object.dir = v[2]
            end
            object.state = state
        else
            object = iobject.new {
                prototype_name = v[1],
                dir = v[2],
                x = x,
                y = y,
                srt = {
                    t = terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)),
                },
                fluid_name = State.fluid_name,
                fluidflow_id = new_fluidflow_id,
                state = state,
            }
            objects:set(object, EDITOR_CACHE_NAMES[1])
        end
    end

    if State.succ then
        for fluidflow_id in pairs(State.fluidflow_ids) do
            for _, object in objects:selectall("fluidflow_id", fluidflow_id, EDITOR_CACHE_NAMES) do
                local _object = assert(objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone))
                assert(iprototype.has_type(iprototype.queryByName(_object.prototype_name).type, "fluidbox"))
                _object.fluid_name = State.fluid_name
                _object.fluidflow_id = new_fluidflow_id
            end
        end
    end

    datamodel.show_finish_laying = State.succ
end

local function _teardown_end(self, datamodel, State, dir, dir_delta)
    local reverse_dir = iprototype.reverse_dir(dir)
    local prototype_name = self.coord_indicator.prototype_name
    local typeobject = iprototype.queryByName(prototype_name)

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
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)

        if x == from_x and y == from_y then
            if object then
                map[coord] = {_set_endpoint_connection(prototype_name, State, object, State.starting_connection, dir)}
            else
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(x, y, State, endpoint_prototype_name, endpoint_dir)
                if not (x == to_x and y == to_y) then
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                end
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end

        elseif x == to_x and y == to_y then
            if object then
                map[coord] = {_set_endpoint_connection(prototype_name, State, object, State.ending_connection, reverse_dir)}
            else
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(x, y, State, endpoint_prototype_name, endpoint_dir)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end
        else
            if object then
                if not iprototype.is_pipe(object.prototype_name) then
                    State.succ = false
                    map[coord] = {object.prototype_name, object.dir}
                else
                    _update_fluid_name(State, object.fluid_name, object.fluidflow_id)
                    local endpoint_prototype_name, endpoint_dir = object.prototype_name, object.dir
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                    map[coord] = {endpoint_prototype_name, endpoint_dir}
                end
            else
                State.succ = false
            end
        end

        if x == to_x and y == to_y then
            break
        end
        x, y = x + dir_delta.x, y + dir_delta.y
    end

    local new_fluidflow_id = 0
    if State.succ then
        global.fluidflow_id = global.fluidflow_id + 1
        new_fluidflow_id = global.fluidflow_id
    end
    local state = State.succ and "construct" or "invalid_construct"

    -- TODO: map may be include some non-pipe objects, such as some building which have fluidboxes, only for changing the state of the building
    for coord, v in pairs(map) do
        local x, y = unpackcoord(coord)
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if object then
            object = assert(objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone))
            if object.prototype_name ~= v[1] or object.dir ~= v[2] then
                object.prototype_name = v[1]
                object.dir = v[2]
            end
            object.state = state
        else
            object = iobject.new {
                prototype_name = v[1],
                dir = v[2],
                x = x,
                y = y,
                srt = {
                    t = terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)),
                },
                fluid_name = State.fluid_name,
                fluidflow_id = new_fluidflow_id,
                state = state,
            }
            objects:set(object, EDITOR_CACHE_NAMES[1])
        end
    end

    datamodel.show_finish_teardown = State.succ
end

local function _builder_init(self, datamodel)
    local coord_indicator = self.coord_indicator
    local prototype_name = self.coord_indicator.prototype_name

    local function is_valid_starting(x, y)
        local object = _get_object(self, x, y, EDITOR_CACHE_NAMES)
        if not object then
            return true
        end
        return #_get_covers_connections(prototype_name, object) > 0
    end

    local object = _get_object(self, coord_indicator.x, coord_indicator.y, EDITOR_CACHE_NAMES)
    if object then
        if iprototype.is_pipe(object.prototype_name) then
            datamodel.show_remove_one = true
            datamodel.show_start_teardown = true
        end
        datamodel.show_place_one = false
    else
        datamodel.show_place_one = true
        datamodel.show_remove_one = false
        datamodel.show_start_teardown = false
    end

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_start_laying = true
    else
        datamodel.show_start_laying = false
    end
end

-- sort by distance and direction
-- prototype_name is the prototype_name of the pipe currently being built
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

local function _builder_start(self, datamodel)
    local from_x, from_y = self.from_x, self.from_y
    local to_x, to_y = self.coord_indicator.x, self.coord_indicator.y
    local prototype_name = self.coord_indicator.prototype_name
    local starting = objects:coord(from_x, from_y, EDITOR_CACHE_NAMES)
    local dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)

    local State = {
        succ = true,
        fluid_name = "",
        fluidflow_ids = {},
        starting_connection = nil,
        starting_fluidflow_id = nil,
        ending_connection = nil,
        ending_fluidflow_id = nil,
        from_x = from_x,
        from_y = from_y,
        to_x = to_x,
        to_y = to_y,
    }

    if starting then
        -- starting object should at least have one connection, promised by _builder_init()
        local connection = _find_starting_connection(prototype_name, starting, to_x, to_y, dir)
        State.starting_connection, State.starting_fluidflow_id = connection, starting.fluidflow_id
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

        local ending = objects:coord(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            if starting.id == ending.id then
                State.succ = false
                State.ending_connection, State.ending_fluidflow_id = connection, ending.fluidflow_id
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
                        State.ending_connection, State.ending_fluidflow_id = another, ending.fluidflow_id
                        _builder_end(self, datamodel, State, dir, delta)
                        return
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
        return
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

        local ending = objects:coord(to_x, to_y, EDITOR_CACHE_NAMES)
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
                    State.ending_connection, State.ending_fluidflow_id = fluidbox, ending.fluidflow_id
                    _builder_end(self, datamodel, State, dir, delta)
                    return
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
        return
    end
end

local function _teardown_start(self, datamodel)
    local from_x, from_y = self.from_x, self.from_y
    local to_x, to_y = self.coord_indicator.x, self.coord_indicator.y
    local prototype_name = self.coord_indicator.prototype_name
    local starting = objects:coord(from_x, from_y, EDITOR_CACHE_NAMES)
    local dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)

    local State = {
        succ = true,
        fluid_name = "",
        fluidflow_ids = {},
        starting_connection = nil,
        starting_fluidflow_id = nil,
        ending_connection = nil,
        ending_fluidflow_id = nil,
        from_x = from_x,
        from_y = from_y,
        to_x = to_x,
        to_y = to_y,
    }

    if starting then
        -- starting object should at least have one connection, promised by _builder_init()
        local connection = _find_starting_connection(prototype_name, starting, to_x, to_y, dir)
        State.starting_connection, State.starting_fluidflow_id = connection, starting.fluidflow_id
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

        local ending = objects:coord(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            if starting.id == ending.id then
                State.succ = false
                State.ending_connection, State.ending_fluidflow_id = connection, ending.fluidflow_id
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
                        State.ending_connection, State.ending_fluidflow_id = another, ending.fluidflow_id
                        _teardown_end(self, datamodel, State, dir, delta)
                        return
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
        _teardown_end(self, datamodel, State, dir, delta)
        return
    else
        State.succ = false
        return
    end
end

local function __apply_teardown(self, x, y)
    for _, dir in ipairs(iconstant.ALL_DIR) do
        local succ, dx, dy = terrain:move_coord(x, y, dir, 1)
        if not succ then
            goto continue
        end
        local object = objects:modify(dx, dy, {"CONFIRM", "CONSTRUCTED"}, iobject.clone)
        if not object then
            goto continue
        end
        if not iprototype.is_pipe(object.prototype_name) then
            goto continue
        end

        local prototype_name, dir = iflow_connector.set_connection(object.prototype_name, object.dir, iprototype.reverse_dir(dir), false)
        assert(prototype_name and dir)

        object.prototype_name = prototype_name
        object.dir = dir
        objects:set(object, "CONFIRM")

        self.pending[iprototype.packcoord(dx, dy)] = object
        ::continue::
    end
end

local function __calc_grid_position(self, typeobject)
    local _, originPosition = logistic_coord:align(math3d.vector {0, 0, 0}, iprototype.unpackarea(typeobject.area))
    local buildingPosition = logistic_coord:get_begin_position_by_coord(self.pickup_object.x, self.pickup_object.y)
    return math3d.ref(math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET))
end
--------------------------------------------------------------------------------------------------
local function new_entity(self, datamodel, typeobject)
    if not self.grid_entity then
        self.grid_entity = igrid_entity.create("polyline_grid", terrain._width, terrain._height, terrain.tile_size, {t = __calc_grid_position(self, typeobject)})
    end
    self.grid_entity:show(true)

    iobject.remove(self.coord_indicator)
    local dir = DEFAULT_DIR

    local x, y = iobject.central_coord(typeobject.name, dir, logistic_coord)
    if not x or not y then
        return
    end

    self.coord_indicator = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        srt = {
            t = terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)),
        },
        fluid_name = "",
    }

    --
    _builder_init(self, datamodel)
end

local function touch_move(self, datamodel, delta_vec)
    if self.coord_indicator then
        iobject.move_delta(self.coord_indicator, delta_vec)
    end
    if self.grid_entity then
        local typeobject = iprototype.queryByName(self.coord_indicator.prototype_name)
        self.grid_entity:send("obj_motion", "set_position", __calc_grid_position(self, typeobject))
    end
end

local function touch_end(self, datamodel)
    if not self.coord_indicator then
        return
    end

    local x, y
    self.coord_indicator, x, y = iobject.align(self.coord_indicator)
    self.coord_indicator.x, self.coord_indicator.y = x, y
    self:revert_changes({"TEMPORARY"})

    if self.state == STATE_NONE then
        return _builder_init(self, datamodel)
    elseif self.state == STATE_START then
        return _builder_start(self, datamodel)
    elseif self.state == STATE_TEARDOWN then
        return _teardown_start(self, datamodel)
    end
end

local function start_laying(self, datamodel)
    local x, y
    self.coord_indicator, x, y = iobject.align(self.coord_indicator)
    self.coord_indicator.x, self.coord_indicator.y = x, y

    self:revert_changes({"TEMPORARY"})
    datamodel.show_place_one = false
    datamodel.show_start_laying = false
    datamodel.show_start_teardown = false
    datamodel.show_remove_one = false
    datamodel.show_cancel = true

    self.state = STATE_START
    self.from_x = self.coord_indicator.x
    self.from_y = self.coord_indicator.y

    _builder_start(self, datamodel)
end

local function finish_laying(self, datamodel)
    self.state = STATE_NONE
    datamodel.show_finish_laying = false
    datamodel.show_confirm = true
    datamodel.show_cancel = false

    for _, object in objects:all("TEMPORARY") do
        object.state = "confirm"
        self.pending[iprototype.packcoord(object.x, object.y)] = object
    end
    objects:commit("TEMPORARY", "CONFIRM")

    local typeobject = iprototype.queryByName(self.coord_indicator.prototype_name)
    self:new_entity(datamodel, typeobject)
end

local function place_one(self, datamodel)
    local coord_indicator = self.coord_indicator
    local x, y = coord_indicator.x, coord_indicator.y
    local object = _get_object(self, x, y, EDITOR_CACHE_NAMES)
    assert(not object)

    local new_fluidflow_id = 0
    global.fluidflow_id = global.fluidflow_id + 1
    new_fluidflow_id = global.fluidflow_id
    local typeobject = iprototype.queryByName("管道1-O型")

    object = iobject.new {
        prototype_name = "管道1-O型",
        dir = "N",
        x = x,
        y = y,
        srt = {
            t = terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, "N")),
        },
        fluid_name = 0,
        fluidflow_id = new_fluidflow_id,
    }
    objects:set(object, EDITOR_CACHE_NAMES[2])

    datamodel.show_confirm = true
end

local function remove_one(self, datamodel)
    local coord_indicator = self.coord_indicator
    local x, y = coord_indicator.x, coord_indicator.y
    local coord = iprototype.packcoord(x, y)

    local object = assert(objects:modify(x, y, {"CONFIRM", "CONSTRUCTED"}, iobject.clone))
    object.state = "remove"

    self.pending[coord] = REMOVE

    datamodel.show_confirm = true
end

local function confirm(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    self:revert_changes({"TEMPORARY"})

    datamodel.show_start_laying = false
    datamodel.show_finish_laying = false
    datamodel.show_cancel = false

    local remove = {}
    for coord, object in pairs(self.pending) do
        local x, y = iprototype.unpackcoord(coord)

        if object == REMOVE then
            local obj = assert(objects:coord(x, y, {"CONFIRM"}))
            igameplay.remove_entity(obj.gameplay_eid)
            iobject.remove(obj)

            remove[coord] = true
        else
            local fluid_icon
            local fluid_name = object.fluid_name
            local object_id = object.id

            if fluid_name ~= "" then
                if ((x % 2 == 1 and y % 2 == 1) or (x % 2 == 0 and y % 2 == 0)) then
                    fluid_icon = true
                end
            end

            local old = objects:get(object_id, {"CONSTRUCTED"})
            if not old then
                object.gameplay_eid = igameplay.create_entity(object)
                object.fluid_icon = fluid_icon
            else
                if old.prototype_name ~= object.prototype_name then
                    igameplay.remove_entity(object.gameplay_eid)
                    object.gameplay_eid = igameplay.create_entity(object)
                elseif old.dir ~= object.dir then
                    ientity:set_direction(gameplay_core.get_world(), gameplay_core.get_entity(object.gameplay_eid), object.dir)
                elseif old.fluid_name ~= object.fluid_name then
                    if iprototype.has_type(iprototype.queryByName(object.prototype_name).type, "fluidbox") then
                        object.fluid_icon = fluid_icon
                        ifluid:update_fluidbox(gameplay_core.get_entity(object.gameplay_eid), object.fluid_name)
                        igameplay.update_chimney_recipe(object)
                    end
                end
            end
        end
    end
    objects:commit("CONFIRM", "CONSTRUCTED")

    for coord in pairs(remove) do
        local x, y = iprototype.unpackcoord(coord)
        __apply_teardown(self, x, y)
    end

    gameplay_core.build()
    iui.redirect("construct.rml", "builder_back")
end

local function cancel(self, datamodel)
    self:revert_changes({"TEMPORARY"})
    local typeobject = iprototype.queryByName(self.coord_indicator.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.state = STATE_NONE
    datamodel.show_finish_laying = false
    datamodel.show_cancel = false
end

local function start_teardown(self, datamodel)
    local x, y
    self.coord_indicator, x, y = iobject.align(self.coord_indicator)
    self.coord_indicator.x, self.coord_indicator.y = x, y

    self:revert_changes({"TEMPORARY"})
    datamodel.show_start_teardown = false
    datamodel.show_start_laying = false
    datamodel.show_place_one = false
    datamodel.show_remove_one = false
    datamodel.show_cancel = true

    self.state = STATE_TEARDOWN
    self.from_x = self.coord_indicator.x
    self.from_y = self.coord_indicator.y

    _teardown_start(self, datamodel)
end

local function finish_teardown(self, datamodel)
    self.state = STATE_NONE
    datamodel.show_finish_laying = false
    datamodel.show_confirm = true
    datamodel.show_cancel = false

    for _, object in objects:all("TEMPORARY") do
        object.state = "remove"
        self.pending[iprototype.packcoord(object.x, object.y)] = REMOVE
    end
    objects:commit("TEMPORARY", "CONFIRM")

    local typeobject = iprototype.queryByName(self.coord_indicator.prototype_name)
    self:new_entity(datamodel, typeobject)
end

local function back(self, datamodel)
    self:revert_changes({"TEMPORARY", "CONFIRM"})

    self.state = STATE_NONE
    datamodel.show_finish_laying = false
    datamodel.show_finish_teardown = false
    datamodel.show_start_laying = false
    datamodel.show_start_teardown = false
    datamodel.show_cancel = false

    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

	iui.redirect("construct.rml", "builder_back")

    self.pending = {}
end

local function create()
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm

    M.prototype_name = ""
    M.state = STATE_NONE
    M.start_laying = start_laying
    M.cancel = cancel
    M.finish_laying = finish_laying
    M.place_one = place_one
    M.remove_one = remove_one
    M.start_teardown = start_teardown
    M.finish_teardown = finish_teardown
    M.back = back

    M.pending = {}
    return M
end
return create