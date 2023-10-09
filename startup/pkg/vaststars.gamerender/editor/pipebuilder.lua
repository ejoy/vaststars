local ecs = ...
local world = ecs.world

local create_builder = ecs.require "editor.builder"
local iprototype = require "gameplay.interface.prototype"
local packcoord = iprototype.packcoord
local unpackcoord = iprototype.unpackcoord
local iconstant = require "gameplay.interface.constant"
local ALL_DIR = iconstant.ALL_DIR
local ALL_DIR_NUM = iconstant.ALL_DIR_NUM
local ifluid = require "gameplay.interface.fluid"
local iobject = ecs.require "object"
local iprototype = require "gameplay.interface.prototype"
local iflow_connector = require "gameplay.interface.flow_connector"
local objects = require "objects"
local math_abs = math.abs
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local igrid_entity = ecs.require "engine.grid_entity"
local terrain = ecs.require "terrain"
local igameplay = ecs.require "gameplay_system"
local gameplay_core = require "gameplay.core"
local math3d = require "math3d"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
local create_pickup_selected_box = ecs.require "editor.common.pickup_selected_box"
local global = require "global"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local ifluidbox = ecs.require "render_updates.fluidbox"
local iprototype_cache = ecs.require "prototype_cache"
local icamera_controller = ecs.require "engine.system.camera_controller"
local CHANGED_FLAG_BUILDING <const> = require("gameplay.interface.constant").CHANGED_FLAG_BUILDING
local CHANGED_FLAG_FLUIDFLOW <const> = require("gameplay.interface.constant").CHANGED_FLAG_FLUIDFLOW

local REMOVE <const> = {}
local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR

-- To distinguish between "batch construction" and "batch teardown" in the touch_end event.
local STATE_NONE  <const> = 0
local STATE_START <const> = 1
local STATE_TEARDOWN <const> = 2

local function length(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function countNeighboringFluids(x, y)
    local fluids = {}
    for _, dir in ipairs(ALL_DIR) do
        local x, y = iprototype.move_coord(x, y, dir)
        local fluid = ifluidbox.get(x, y, iprototype.reverse_dir(dir))
        if fluid and fluid ~= 0 then
            fluids[fluid] = true
        end
    end
    return length(fluids)
end

local function _get_object(self, x, y, cache_names)
    local coord = iprototype.packcoord(x, y)
    local tmp = self.pending[coord]
    if tmp == REMOVE then
        return
    end

    return objects:coord(x, y, cache_names)
end

-- automatically connects to its neighbors which has fluidbox, except for pipe or pipe to ground
local function _connect_to_neighbor(State, x, y, prototype_name, dir)
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
                if State.fluid_name ~= "" then
                    if fb.fluid_name ~= "" then
                        State.succ = (State.fluid_name == fb.fluid_name)
                    end
                else
                    if fb.fluid_name then
                        State.fluid_name = fb.fluid_name
                    end
                end

                prototype_name, dir = iflow_connector.set_connection(prototype_name, dir, neighbor_dir, true)
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
        local typeobject = iprototype.queryByName(object.prototype_name)
        local _prototype_name, _dir
        -- normal pipe can replace other pipe, including pipe to ground
        _prototype_name, _dir = iflow_connector.covers_building_category(object.prototype_name, object.dir, typeobject.building_category)
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
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(State, x, y, endpoint_prototype_name, endpoint_dir)
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
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(State, x, y, endpoint_prototype_name, endpoint_dir)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end
        else
            if object then
                if not iprototype.is_pipe(object.prototype_name) then
                    local typeobject = iprototype.queryByName(object.prototype_name)
                    -- usually, the type of 'fluidbox' is a fluid tank.
                    if not iprototype.has_type(typeobject.type, "fluidbox") then
                        State.succ = false
                    end
                    map[coord] = {object.prototype_name, object.dir}
                else
                    local endpoint_prototype_name, endpoint_dir = object.prototype_name, object.dir
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                    endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                    map[coord] = {endpoint_prototype_name, endpoint_dir}
                end
            else
                local endpoint_prototype_name, endpoint_dir = iflow_connector.cleanup(prototype_name, DEFAULT_DIR)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, dir, true)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(State, x, y, endpoint_prototype_name, endpoint_dir)
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end
        end

        if x == to_x and y == to_y then
            break
        end
        x, y = x + dir_delta.x, y + dir_delta.y
    end

    -- TODO: map may be include some non-pipe objects, such as some building which have fluidboxes, only for changing the state of the building
    for coord, v in pairs(map) do
        local x, y = unpackcoord(coord)
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if object then
            object = assert(objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone))
            if object.prototype_name ~= v[1] or object.dir ~= v[2] then
                object.prototype_name = v[1]
                object.dir = v[2]
                object.srt.r = ROTATORS[object.dir]
                object.fluid_name = State.fluid_name
            end
        else
            object = iobject.new {
                prototype_name = v[1],
                dir = v[2],
                x = x,
                y = y,
                srt = {
                    t = math3d.ref(math3d.vector(terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)))),
                    r = ROTATORS[dir],
                },
                fluid_name = State.fluid_name,
                group_id = 0,
            }
            objects:set(object, EDITOR_CACHE_NAMES[1])
        end
    end

    self.to_x, self.to_y = to_x, to_y
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
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(State, x, y, endpoint_prototype_name, endpoint_dir)
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
                endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(State, x, y, endpoint_prototype_name, endpoint_dir)
                endpoint_prototype_name, endpoint_dir = iflow_connector.set_connection(endpoint_prototype_name, endpoint_dir, reverse_dir, true)
                map[coord] = {endpoint_prototype_name, endpoint_dir}
            end
        else
            if object then
                if not iprototype.is_pipe(object.prototype_name) then
                    State.succ = false
                    map[coord] = {object.prototype_name, object.dir}
                else
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

    -- TODO: map may be include some non-pipe objects, such as some building which have fluidboxes, only for changing the state of the building
    for coord, v in pairs(map) do
        local x, y = unpackcoord(coord)
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if object then
            object = assert(objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone))
            if object.prototype_name ~= v[1] or object.dir ~= v[2] then
                object.prototype_name = v[1]
                object.dir = v[2]
                object.srt.r = ROTATORS[object.dir]
            end
        else
            object = iobject.new {
                prototype_name = v[1],
                dir = v[2],
                x = x,
                y = y,
                srt = {
                    t = math3d.ref(math3d.vector(terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)))),
                    r = ROTATORS[dir],
                },
                fluid_name = State.fluid_name,
                group_id = 0,
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

    if countNeighboringFluids(coord_indicator.x, coord_indicator.y) > 1 then
        datamodel.show_place_one = false
        datamodel.show_start_laying = false
    end

    for _, c in pairs(self.pickup_components) do
        c:on_status_change(datamodel.show_start_laying or datamodel.show_place_one)
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
        if State.starting_connection.fluid_name ~= "" then
            State.fluid_name = State.starting_connection.fluid_name
        end
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
                succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir,
                    math_abs(from_x - fluidbox.x),
                    math_abs(from_y - fluidbox.y)
                )
                if not succ then
                    goto continue
                end
                if to_x == fluidbox.x and to_y == fluidbox.y then
                    State.ending_connection = fluidbox
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

        local ending = objects:coord(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            if starting.id == ending.id then
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

local function __calc_grid_position(building_position, typeobject, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local _, originPosition = terrain:align(math3d.vector(0, 0, 0), w, h)
    return math3d.ref(math3d.add(math3d.sub(building_position, originPosition), GRID_POSITION_OFFSET))
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

    local removed = {}
    for coord, object in pairs(self.pending) do
        if object == REMOVE then
            removed[coord] = true
        else
            local object_id = object.id
            local old = objects:get(object_id, {"CONSTRUCTED"})
            if not old then
                object.gameplay_eid = igameplay.create_entity(object)
            else
                if old.prototype_name ~= object.prototype_name then
                    igameplay.destroy_entity(object.gameplay_eid)
                    object.gameplay_eid = igameplay.create_entity(object)
                elseif old.dir ~= object.dir then
                    igameplay.rotate(object.gameplay_eid, object.dir)
                end
            end
        end
    end
    objects:commit("CONFIRM", "CONSTRUCTED")

    for coord in pairs(removed) do
        local x, y = iprototype.unpackcoord(coord)
        local obj = assert(objects:coord(x, y))
        iobject.remove(obj)
        objects:remove(obj.id)
        local building = global.buildings[obj.id]
        if building then
            for _, v in pairs(building) do
                v:remove()
            end
        end

        print("remove", obj.id, obj.x, obj.y)
        igameplay.destroy_entity(obj.gameplay_eid)
    end

    gameplay_core.set_changed(CHANGED_FLAG_BUILDING | CHANGED_FLAG_FLUIDFLOW)
end

local function getPlacedPrototypeName(x, y, default_prototype_name, default_dir)
    local o = objects:coord(x, y, EDITOR_CACHE_NAMES)
    local prototype_name, dir
    if not o then
        prototype_name, dir = iflow_connector.cleanup(default_prototype_name, default_dir)
    else
        prototype_name, dir = o.prototype_name, o.dir
    end

    for _, d in ipairs(iconstant.ALL_DIR) do
        local dx, dy = iprototype.move_coord(x, y, d)
        local o = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
        if o and iprototype.is_pipe(o.prototype_name) then
            prototype_name, dir = iflow_connector.set_connection(prototype_name, dir, d, true)
        end
    end
    return prototype_name, dir
end

--------------------------------------------------------------------------------------------------
local function new_entity(self, datamodel, typeobject, x, y)
    assert(x and y)
    self.typeobject = typeobject
    iobject.remove(self.coord_indicator)
    local prototype_name, dir = getPlacedPrototypeName(x, y, typeobject.name, DEFAULT_DIR)

    self.coord_indicator = iobject.new {
        prototype_name = prototype_name,
        dir = dir,
        x = x,
        y = y,
        srt = {
            t = math3d.ref(math3d.vector(terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, dir)))),
            r = ROTATORS[dir],
        },
        fluid_name = "",
        group_id = 0,
    }

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create(terrain._width, terrain._height, terrain.tile_size, {t = __calc_grid_position(self.coord_indicator.srt.t, typeobject, dir)})
    end

    self.pickup_components[#self.pickup_components + 1] = create_pickup_selected_box(self.coord_indicator.srt.t, typeobject.area, dir, true)

    --
    _builder_init(self, datamodel)
end


local function __align(position, area, dir)
    local coord = terrain:align(position, iprototype.rotate_area(area, dir))
    if not coord then
        return
    end
    local t = math3d.ref(math3d.vector(terrain:get_position_by_coord(coord[1], coord[2], iprototype.rotate_area(area, dir))))
    return t, coord[1], coord[2]
end

local function touch_move(self, datamodel, delta_vec)
    if not self.coord_indicator then
        return
    end
    if self.coord_indicator then
        iobject.move_delta(self.coord_indicator, delta_vec)

        local coord_indicator = self.coord_indicator
        local typeobject = iprototype.queryByName(coord_indicator.prototype_name)
        local _, x, y = __align(icamera_controller.get_central_position(), typeobject.area, coord_indicator.dir)
        local prototype_name, dir = getPlacedPrototypeName(x, y, self.typeobject.name, DEFAULT_DIR)
        if prototype_name ~= self.coord_indicator.prototype_name or dir ~= self.coord_indicator.dir then
            local srt = self.coord_indicator.srt
            local x, y = self.coord_indicator.x, self.coord_indicator.y
            iobject.remove(self.coord_indicator)
            print("touch_move", x, y, prototype_name, dir)
            self.coord_indicator = iobject.new {
                prototype_name = prototype_name,
                dir = dir,
                x = x,
                y = y,
                srt = srt,
                group_id = 0,
            }
        end
    end
    if self.grid_entity then
        local typeobject = iprototype.queryByName(self.coord_indicator.prototype_name)
        local w, h = iprototype.rotate_area(typeobject.area, self.coord_indicator.dir)
        local grid_position = terrain:get_position_by_coord(self.coord_indicator.x, self.coord_indicator.y, w, h)
        self.grid_entity:set_position(__calc_grid_position(grid_position, typeobject, self.coord_indicator.dir))
    end
    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.coord_indicator.srt, self.coord_indicator.dir)
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

    local prototype_name, dir = getPlacedPrototypeName(self.coord_indicator.x, self.coord_indicator.y, self.typeobject.name, DEFAULT_DIR)
    if prototype_name ~= self.coord_indicator.prototype_name or dir ~= self.coord_indicator.dir then
        local x, y = self.coord_indicator.x, self.coord_indicator.y
        iobject.remove(self.coord_indicator)
        print("touch_move", x, y, prototype_name, dir)
        self.coord_indicator = iobject.new {
            prototype_name = prototype_name,
            dir = dir,
            x = x,
            y = y,
            srt = {
                t = math3d.ref(math3d.vector(terrain:get_position_by_coord(x, y, iprototype.rotate_area(self.typeobject.area, dir)))),
                r = ROTATORS[dir],
            },
            group_id = 0,
        }
    end

    if self.grid_entity then
        local typeobject = iprototype.queryByName(self.coord_indicator.prototype_name)
        local w, h = iprototype.rotate_area(typeobject.area, self.coord_indicator.dir)
        local grid_position = terrain:get_position_by_coord(self.coord_indicator.x, self.coord_indicator.y, w, h)
        self.grid_entity:set_position(__calc_grid_position(grid_position, typeobject, self.coord_indicator.dir))
    end

    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.coord_indicator.srt, self.coord_indicator.dir)
    end

    if self.state == STATE_NONE then
        return _builder_init(self, datamodel)
    elseif self.state == STATE_START then
        return _builder_start(self, datamodel)
    elseif self.state == STATE_TEARDOWN then
        return _teardown_start(self, datamodel)
    end
end

local function start_laying(self, datamodel)
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
        -- TODO: mark the object for deletion
        self.pending[iprototype.packcoord(object.x, object.y)] = object
    end
    objects:commit("TEMPORARY", "CONFIRM")

    confirm(self, datamodel)

    local to_x, to_y = self.to_x, self.to_y
    self.to_x, self.to_y = nil, nil

    self:new_entity(datamodel, self.typeobject, to_x, to_y)
end

local function place_one(self, datamodel)
    local coord_indicator = self.coord_indicator
    local x, y = coord_indicator.x, coord_indicator.y
    local object = _get_object(self, x, y, EDITOR_CACHE_NAMES)
    if object then
        return
    end
    if countNeighboringFluids(x, y) > 1 then
        return
    end

    --
    local m = 0
    for _, dir in ipairs(ALL_DIR_NUM) do
        local dx, dy = iprototype.move_coord(x, y, dir)
        local fluid = ifluidbox.get(dx, dy, iprototype.reverse_dir(dir))
        if fluid then
            m = m | (1 << dir)
        end
    end

    local typeobject = iprototype.queryByName("管道1-O型")
    local prototype, dir = iprototype_cache.get("pipe").MaskToPrototypeDir(typeobject.building_category, m)

    object = iobject.new {
        prototype_name = prototype,
        dir = dir,
        x = x,
        y = y,
        srt = {
            t = math3d.ref(math3d.vector(terrain:get_position_by_coord(x, y, iprototype.rotate_area(typeobject.area, "N")))),
            r = ROTATORS["N"],
        },
        fluid_name = '',
        group_id = 0,
    }
    objects:set(object, EDITOR_CACHE_NAMES[2])
    self.pending[iprototype.packcoord(object.x, object.y)] = object
    print("place_one", object.x, object.y, object.prototype_name)

    --
    for _, dir in ipairs(ALL_DIR_NUM) do
        local dx, dy = iprototype.move_coord(x, y, dir)
        local fluid = ifluidbox.get(dx, dy, iprototype.reverse_dir(dir))
        if fluid then
            local neighbor = assert(_get_object(self, dx, dy, EDITOR_CACHE_NAMES))
            if iprototype.is_pipe(neighbor.prototype_name) then
                local m = iprototype_cache.get("pipe").PrototypeDirToMask(neighbor.prototype_name, neighbor.dir)
                m = m | (1 << iprototype.reverse_dir(dir))
                local prototype, dir = iprototype_cache.get("pipe").MaskToPrototypeDir(typeobject.building_category, m)
                local o = assert(objects:modify(dx, dy, {"CONFIRM", "CONSTRUCTED"}, iobject.clone))
                o.prototype_name = prototype
                o.dir = dir
                self.pending[iprototype.packcoord(o.x, o.y)] = o
                print("place_one", o.x, o.y, o.prototype_name)
            end
        end
    end

    datamodel.show_confirm = true

    confirm(self, datamodel)
    self:clean(self, datamodel)
    self:new_entity(datamodel, self.typeobject, x, y)
end

local function remove_one(self, datamodel, x, y)
    local coord = iprototype.packcoord(x, y)
    self.pending[coord] = REMOVE
    local ret = confirm(self, datamodel)
    self:clean(self, datamodel)
    self:new_entity(datamodel, self.typeobject)
    return ret
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
    datamodel.show_finish_teardown = false
    datamodel.show_finish_laying = false
    datamodel.show_confirm = true
    datamodel.show_cancel = false

    for _, object in objects:all("TEMPORARY") do
        -- TODO: mark the object for deletion
        self.pending[iprototype.packcoord(object.x, object.y)] = REMOVE
    end
    objects:commit("TEMPORARY", "CONFIRM")

    confirm(self, datamodel)
    self:clean(self, datamodel)

    self:new_entity(datamodel, self.typeobject)

    local to_x, to_y = self.to_x, self.to_y
    self.to_x, self.to_y = nil, nil
    self:new_entity(datamodel, self.typeobject, to_x, to_y)
end

local function clean(self, datamodel)
    self:revert_changes({"TEMPORARY", "CONFIRM"})

    self.state = STATE_NONE
    datamodel.show_finish_laying = false
    datamodel.show_finish_teardown = false
    datamodel.show_start_laying = false
    datamodel.show_start_teardown = false
    datamodel.show_cancel = false
    datamodel.show_remove_one = false

    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    for _, c in pairs(self.pickup_components) do
        c:remove()
    end
    self.pickup_components = {}
    self.pending = {}
end

local function create()
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end

    M.prototype_name = ""
    M.state = STATE_NONE
    M.start_laying = start_laying
    M.cancel = cancel
    M.finish_laying = finish_laying
    M.confirm = place_one
    M.remove_one = remove_one
    M.start_teardown = start_teardown
    M.finish_teardown = finish_teardown
    M.clean = clean

    M.pending = {}
    M.pickup_components = {}
    M.to_x = nil
    M.to_y = nil
    return M
end
return create