local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local CHANGED_FLAG_FLUIDFLOW <const> = CONSTANT.CHANGED_FLAG_FLUIDFLOW
local MAP_WIDTH <const> = CONSTANT.MAP_WIDTH
local MAP_HEIGHT <const> = CONSTANT.MAP_HEIGHT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local DIRECTION <const> = CONSTANT.DIRECTION
local STATE_NONE  <const> = 0
local STATE_START <const> = 1
local EDITOR_CACHE_NAMES = {"CONFIRM", "CONSTRUCTED"}

local math3d = require "math3d"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})

local iprototype = require "gameplay.interface.prototype"
local packcoord = iprototype.packcoord
local iobject = ecs.require "object"
local iprototype = require "gameplay.interface.prototype"
local iflow_connector = require "gameplay.interface.flow_connector"
local objects = require "objects"
local math_abs = math.abs
local iquad_lines_entity = ecs.require "engine.quad_lines_entity" -- NOTE: different from pipe_builder
local igrid_entity = ecs.require "engine.grid_entity"
local icoord = require "coord"
local create_pickup_selected_box = ecs.require "editor.indicators.pickup_selected_box"
local global = require "global"
local gameplay_core = require "gameplay.core"
local srt = require "utility.srt"
local icamera_controller = ecs.require "engine.system.camera_controller"
local ifluidbox = ecs.require "render_updates.fluidbox"

local function revert_changes(revert_cache_names)
    local t = {}
    for _, cache_name in ipairs(revert_cache_names) do
        for id, object in objects:all(cache_name) do
            t[id] = object
        end
    end
    objects:clear(revert_cache_names)

    for id, object in pairs(t) do
        local old_object = objects:get(id, {"CONFIRM", "CONSTRUCTED"})
        if old_object then
            object.prototype_name = old_object.prototype_name
            object.dir = old_object.dir
            object.srt.r = ROTATORS[object.dir]
        else
            iobject.remove(object)
        end
    end
    iobject.flush() -- object is removed from cache, so we need to flush it, else it will keep the old state
end

local function _show_dotted_line(self, from_x, from_y, to_x, to_y, dir, dir_delta)
    from_x, from_y = from_x + dir_delta.x, from_y + dir_delta.y
    local quad_num
    if from_x == to_x then
        quad_num = math_abs(from_y - to_y)
    elseif from_y == to_y then
        quad_num = math_abs(from_x - to_x)
    else
        assert(false)
    end

    if quad_num <= 1 then
        return
    end

    local position = icoord.position(from_x, from_y, 1, 1)
    if self.dotted_line then
        self.dotted_line:remove()
        self.dotted_line = nil
    end
    self.dotted_line = iquad_lines_entity.create(position, quad_num, dir)
end

local function _check_dotted_line(from_x, from_y, to_x, to_y, dir, dir_delta) -- TODO: remove this function
    from_x, from_y = from_x + dir_delta.x, from_y + dir_delta.y
    assert(from_x == to_x or from_y == to_y)
end

-- Note: different from pipe_builder
-- automatically connects to its neighbors which has fluidbox, except for pipe or pipe to ground
local function _connect_to_neighbor(State, PipeToGroundState, x, y, neighbor_dir, prototype_name, dir)
    local succ, neighbor_x, neighbor_y
    succ, neighbor_x, neighbor_y = icoord.move(x, y, neighbor_dir, 1)
    if not succ then
        return prototype_name, dir
    end

    local object = objects:coord(neighbor_x, neighbor_y, EDITOR_CACHE_NAMES)
    if not object then
        return prototype_name, dir
    end

    local _prototype_name, _dir = object.prototype_name, object.dir
    if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        _prototype_name, _dir = iflow_connector.covers(object.prototype_name, object.dir)
    end

    local function check_connection(conn, typeobject)
        local dx, dy, ddir = ifluidbox.rotate(conn.position, DIRECTION[object.dir], typeobject.area)
        dx, dy = iprototype.move_coord(object.x + dx, object.y + dy, ddir, 1)
        if not (dx == x and dy == y and ddir == DIRECTION[iprototype.reverse_dir(neighbor_dir)]) then
            return
        end

        if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
            local coord = packcoord(object.x, object.y)
            _prototype_name, _dir = iflow_connector.set_connection(object.prototype_name, object.dir, iprototype.reverse_dir(neighbor_dir), true)
            if _prototype_name then
                PipeToGroundState.map[coord] = {object.x, object.y, _prototype_name, _dir}
            end
        end

        local fluid = ifluidbox.get(object.x, object.y, iprototype.reverse_dir(neighbor_dir))
        local fluid_name = ""
        if fluid then
            fluid_name = iprototype.queryById(fluid).name
        end
        if not (fluid_name == "" or State.fluid_name == "" or fluid_name == State.fluid_name) then
            State.succ = false
        else
            State.fluid_name = fluid_name

            prototype_name, dir = iflow_connector.set_connection(prototype_name, dir, neighbor_dir, true)
            assert(prototype_name and dir) -- TODO:remove this assert
        end

        return prototype_name, dir -- only one fluidbox can be connected to the endpoint
    end

    local typeobject = iprototype.queryByName(_prototype_name)
    if typeobject.fluidbox then
        for _, conn in ipairs(typeobject.fluidbox.connections) do
            local prototype_name, dir = check_connection(conn, typeobject)
            if prototype_name then
                return prototype_name, dir
            end
        end
    end
    if typeobject.fluidboxes then
        for _, iotype in ipairs({"input", "output"}) do
            for idx, v in ipairs(typeobject.fluidboxes[iotype]) do
                for _, conn in ipairs(v.connections) do
                    local prototype_name, dir = check_connection(conn, typeobject)
                    if prototype_name then
                        return prototype_name, dir
                    end
                end
            end
        end
    end

    return prototype_name, dir
end

-- NOTE: different from pipe_builder
local function _get_covers_fluidbox(object, groud)
    local prototype_name
    if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        prototype_name = iflow_connector.covers(object.prototype_name, object.dir)
    else
        prototype_name = object.prototype_name
    end

    local funcs = {}
    funcs["fluidbox"] = function(typeobject, x, y, dir, result)
        for _, conn in ipairs(typeobject.fluidbox.connections) do
            local dx, dy, dir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
            if groud == nil and conn.ground then
                goto continue
            end

            result[#result+1] = {x = x + dx, y = y + dy, dir = dir, ground = conn.ground}
            ::continue::
        end
        return result
    end

    local iotypes = {"input", "output"}
    funcs["fluidboxes"] = function(typeobject, x, y, dir, fluid_name, result)
        for _, iotype in ipairs(iotypes) do
            for idx, v in ipairs(typeobject.fluidboxes[iotype]) do
                for _, conn in ipairs(v.connections) do
                    if groud == nil and conn.ground then
                        goto continue
                    end
                    local dx, dy, dir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
                    result[#result+1] = {x = x + dx, y = y + dy, dir = dir, ground = conn.ground}
                    ::continue::
                end
            end
        end
        return result
    end

    local result = {}
    local typeobject = assert(iprototype.queryByName(prototype_name))
    for _, t in ipairs(typeobject.type) do
        local func = funcs[t]
        if func then
            result = func(typeobject, object.x, object.y, object.dir, result)
        end
    end
    return result
end

-- check if the neighbor pipe can be replaced with a pipe to ground
local function _can_replace(object, forward_dir)
    if not iprototype.is_pipe(object.prototype_name) and not iprototype.is_pipe_to_ground(object.prototype_name) then
        return false
    end

    local reverse_dir = iprototype.reverse_dir(forward_dir)
    local _prototype_name, _dir
    _prototype_name, _dir = iflow_connector.set_connection(object.prototype_name, object.dir, forward_dir, true)
    if not (_prototype_name == object.prototype_name and _dir == object.dir) then
        return false
    end

    _prototype_name, _dir = iflow_connector.set_connection(object.prototype_name, object.dir, reverse_dir, true)
    if not (_prototype_name == object.prototype_name and _dir == object.dir) then
        return false
    end

    return true
end

local function __can_be_starting_point(object)
    if not iprototype.is_pipe(object.prototype_name) and not iprototype.is_pipe_to_ground(object.prototype_name) then
        return false
    end

    return true
end

local function _set_starting(prototype_name, State, PipeToGroundState, x, y, dir)
    local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    local typeobject = iprototype.queryByName(prototype_name)

    if x == PipeToGroundState.to_x and y == PipeToGroundState.to_y then
        return
    end

    if not object then
        local endpoint_prototype_name, endpoint_dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, nil, dir)
        endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(State, PipeToGroundState, x, y, iprototype.reverse_dir(dir), endpoint_prototype_name, endpoint_dir)
        PipeToGroundState.map[packcoord(x, y)] = {x, y, assert(endpoint_prototype_name), assert(endpoint_dir)}
        return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
    end

    if iprototype.is_pipe(object.prototype_name) then
        local coord = packcoord(x, y)
        local _prototype_name, _dir
        if _can_replace(object, dir) then
            -- replace the neighbor pipe with a pipe to ground
            _prototype_name, _dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, iprototype.reverse_dir(dir), dir)
            PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}
            return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
        end

        -- the neighbor pipe can not be replaced with a pipe to ground, so we need to change the shape of the pipe
        _prototype_name, _dir = iflow_connector.set_connection(object.prototype_name, object.dir, dir, true)
        PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}

        local x, y = object.x + PipeToGroundState.dir_delta.x, object.y + PipeToGroundState.dir_delta.y
        if x == PipeToGroundState.to_x and y == PipeToGroundState.to_y then
            State.succ = false
            return
        end

        _prototype_name, _dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, iprototype.reverse_dir(dir), dir)

        coord = packcoord(x, y)
        local next_object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if not next_object then
            PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}
            return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
        end

        if not _can_replace(next_object, dir) then
            State.succ = false
            PipeToGroundState.map[coord] = {x, y, assert(next_object.prototype_name), assert(next_object.dir)}
            return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
        end

        PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}
        return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y

    elseif iprototype.is_pipe_to_ground(object.prototype_name) then
        -- the pipe to ground can certainly be replaced with the new pipe to ground, promise by _builder_init()
        if not __can_be_starting_point(object) then
            State.succ = false
            return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
        end

        local _prototype_name, _dir

        _prototype_name, _dir = iflow_connector.set_connection(object.prototype_name, object.dir, dir, true)
        if _prototype_name then
            local coord = packcoord(x, y)
            PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}

            _prototype_name, _dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, iprototype.reverse_dir(dir), dir)
            if _prototype_name then
                x, y = x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
                local coord = packcoord(x, y)
                PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}
            end
        else
            local coord = packcoord(x, y)
            _prototype_name, _dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, iprototype.reverse_dir(dir), dir)
            _prototype_name, _dir = iflow_connector.set_connection(_prototype_name, _dir, iprototype.reverse_dir(dir), false)
            PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}
        end

        return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y

    else
        local _prototype_name, _dir
        local typeobject = iprototype.queryByName(prototype_name)
        _prototype_name, _dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, iprototype.reverse_dir(dir), dir)

        x, y = x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
        if x == PipeToGroundState.to_x and y == PipeToGroundState.to_y then
            State.succ = false
            return
        end

        local coord = packcoord(x, y)
        local next_object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if not next_object then
            PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}
            return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
        end

        if not _can_replace(next_object, dir) then
            State.succ = false
            PipeToGroundState.map[coord] = {x, y, assert(next_object.prototype_name), assert(next_object.dir)}
            return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
        end

        PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), assert(_dir)}
        return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
    end
end

local function _set_section(prototype_name, State, PipeToGroundState, x, y, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local reverse_dir = iprototype.reverse_dir(dir)

    if PipeToGroundState.distance + 1 < PipeToGroundState.max_distance then
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if object then
            if _can_replace(object, dir) then
                PipeToGroundState.replace_object[object.id] = true
            else
                PipeToGroundState.replace = false
            end
        end

        PipeToGroundState.distance = PipeToGroundState.distance + 1
        return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
    end

    PipeToGroundState.distance = 0
    State.dotted_line_coord = {x, y, PipeToGroundState.to_x, PipeToGroundState.to_y, dir, PipeToGroundState.dir_delta}
    _check_dotted_line(table.unpack(State.dotted_line_coord))

    local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    if object then
        if not _can_replace(object, dir) then
            State.succ = false
            return
        end
    end

    local _prototype_name, _dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, dir, reverse_dir)
    PipeToGroundState.map[packcoord(x, y)] = {x, y, assert(_prototype_name), assert(_dir)}

    x, y = x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
    State.dotted_line_coord = {x, y, PipeToGroundState.to_x, PipeToGroundState.to_y, dir, PipeToGroundState.dir_delta}
    _check_dotted_line(table.unpack(State.dotted_line_coord))

    local last = false
    if x == PipeToGroundState.to_x and y == PipeToGroundState.to_y then
        last = true
    end

    object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    if object then
        if not _can_replace(object, dir) then
            State.succ = false
            return
        end
    end
    local _prototype_name, _dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, reverse_dir, dir)
    PipeToGroundState.map[packcoord(x, y)] = {x, y, assert(_prototype_name), assert(_dir)}

    if last then
        return
    else
        return x + PipeToGroundState.dir_delta.x, y + PipeToGroundState.dir_delta.y
    end
end

local function _set_ending(prototype_name, State, PipeToGroundState, x, y, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local endpoint_prototype_name, endpoint_dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, nil, iprototype.reverse_dir(dir))
    assert(endpoint_prototype_name and endpoint_dir)
    endpoint_prototype_name, endpoint_dir = _connect_to_neighbor(State, PipeToGroundState, x, y, dir, endpoint_prototype_name, endpoint_dir)
    assert(endpoint_prototype_name and endpoint_dir)

    local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    if not object then
        PipeToGroundState.map[packcoord(x, y)] = {x, y, assert(endpoint_prototype_name), assert(endpoint_dir)}
        return
    end

    if _can_replace(object, dir) then
        PipeToGroundState.map[packcoord(x, y)] = {x, y, assert(endpoint_prototype_name), assert(endpoint_dir)}
        return
    end

    if not iprototype.is_pipe(object.prototype_name) and not iprototype.is_pipe_to_ground(object.prototype_name) then
        State.succ = false
        return
    end

    local px, py = x - PipeToGroundState.dir_delta.x, y - PipeToGroundState.dir_delta.y
    local coord

    coord = packcoord(px, py)
    if PipeToGroundState.map[coord] then
        State.succ = false
        return
    end

    endpoint_prototype_name, endpoint_dir = iflow_connector.covers_pipe_to_ground(typeobject.building_category, dir, iprototype.reverse_dir(dir))
    PipeToGroundState.map[coord] = {px, py, assert(endpoint_prototype_name), assert(endpoint_dir)}

    coord = packcoord(x, y)
    local _prototype_name, _dir = iflow_connector.set_connection(object.prototype_name, object.dir, iprototype.reverse_dir(dir), true)
    if not _prototype_name then
        State.succ = false
        return
    end

    PipeToGroundState.map[coord] = {x, y, _prototype_name, _dir}
    return x, y
end

-- NOTE: different from pipe_builder
local function _builder_end(self, datamodel, State, dir, dir_delta)
    local prototype_name = self.coord_indicator.prototype_name
    local typeobject = iprototype.queryByName(prototype_name)

    if State.starting_fluidbox then -- TODO: optimize
        if State.ending_fluidbox then
            State.dotted_line_coord = {State.starting_fluidbox.x, State.starting_fluidbox.y, State.ending_fluidbox.x, State.ending_fluidbox.y, dir, dir_delta}
        else
            State.dotted_line_coord = {State.starting_fluidbox.x, State.starting_fluidbox.y, State.to_x, State.to_y, dir, dir_delta}
        end
    else
        State.dotted_line_coord = {State.from_x, State.from_y, State.to_x, State.to_y, dir, dir_delta}
    end
    _check_dotted_line(table.unpack(State.dotted_line_coord))

    local from_x, from_y
    if State.starting_fluidbox then
        from_x, from_y = State.starting_fluidbox.x, State.starting_fluidbox.y
    else
        from_x, from_y = State.from_x, State.from_y
    end
    local to_x, to_y
    if State.ending_fluidbox then
        to_x, to_y = State.ending_fluidbox.x, State.ending_fluidbox.y
    else
        to_x, to_y = State.to_x, State.to_y
    end
    local x, y = assert(from_x), assert(from_y)

    local PipeToGroundState = {}
    PipeToGroundState.dir_delta = dir_delta
    PipeToGroundState.to_x = to_x
    PipeToGroundState.to_y = to_y
    PipeToGroundState.distance = 0
    PipeToGroundState.max_distance = iflow_connector.ground(typeobject.building_category) -- The maximum distance at which an underground pipe can connect is 10 tiles, resulting in a gap of 9 tiles in between.
    PipeToGroundState.remove = {}
    PipeToGroundState.replace_object = {}
    PipeToGroundState.replace = true
    PipeToGroundState.map = {}

    while true do
        if x == from_x and y == from_y then
            x, y = _set_starting(prototype_name, State, PipeToGroundState, x, y, dir)

        elseif x == to_x and y == to_y then
            local last_x, last_y = x, y -- TODO: optimize
            x, y = _set_ending(prototype_name, State, PipeToGroundState, x, y, dir)

            -- refresh the shape of the neighboring pipe
            -- TODO: optimize
            local coord = packcoord(to_x, to_y)
            if PipeToGroundState.map[coord] and iprototype.is_pipe_to_ground(PipeToGroundState.map[coord][3]) then
                local dx, dy = last_x + dir_delta.x, last_y + dir_delta.y
                local coord = packcoord(dx, dy)
                local object = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
                if object and (iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name)) then
                    local _prototype_name, _dir = iflow_connector.set_connection(object.prototype_name, object.dir, iprototype.reverse_dir(dir), false)
                    if object.prototype_name ~= _prototype_name or object.dir ~= _dir then
                        PipeToGroundState.map[coord] = {x, y, assert(_prototype_name), _dir}
                    end
                end
            end

        else
            x, y = _set_section(prototype_name, State, PipeToGroundState, x, y, dir)
        end

        if not x and not y then
            break
        end
    end

    -- TODO: pipe to ground can be replaced by pipe
    if PipeToGroundState.replace then
        for object_id in pairs(PipeToGroundState.replace_object) do
            local object = assert(objects:get(object_id))
            object = assert(objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone))

            local item_name = iprototype.item(iprototype.queryByName(object.prototype_name)).name
            PipeToGroundState.remove[item_name] = (PipeToGroundState.remove[item_name] or 0) + 1

            iobject.remove(object)
            self.removed[object.id] = true
        end
    end

    for _, v in pairs(PipeToGroundState.map) do
        local x, y = v[1], v[2]
        local prototype_name, dir = v[3], v[4]
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if object then
            object = assert(objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone))
            if object.prototype_name ~= prototype_name or object.dir ~= dir then
                local item_name_1 = iprototype.item(iprototype.queryByName(object.prototype_name)).name
                local item_name_2 = iprototype.item(iprototype.queryByName(prototype_name)).name

                if item_name_1 ~= item_name_2 then
                    local item_name = item_name_1
                    PipeToGroundState.remove[item_name] = (PipeToGroundState.remove[item_name] or 0) + 1
                end
                object.prototype_name = prototype_name
                object.dir = dir
                object.srt.r = ROTATORS[object.dir]
            end

        else
            object = iobject.new {
                prototype_name = prototype_name,
                dir = dir,
                x = x,
                y = y,
                srt = srt.new {
                    t = math3d.vector(icoord.position(x, y, iprototype.rotate_area(typeobject.area, dir))),
                    r = ROTATORS[dir],
                },
                group_id = 0,
            }
            objects:set(object, "CONFIRM")
        end
    end

    _show_dotted_line(self, table.unpack(State.dotted_line_coord))
end

-- sort by distance and direction
local function _find_starting_fluidbox(object, dx, dy, dir)
    local fluidboxes = _get_covers_fluidbox(object, true)
    assert(#fluidboxes > 0) -- promised by _builder_init()

    local function _get_distance(x1, y1, x2, y2)
        return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
    end

    table.sort(fluidboxes, function(a, b)
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
    return fluidboxes[1]
end

local function _builder_start(self, datamodel)
    local from_x, from_y = self.from_x, self.from_y
    local to_x, to_y = self.coord_indicator.x, self.coord_indicator.y
    local starting = objects:coord(from_x, from_y, EDITOR_CACHE_NAMES)
    local dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)

    self.State = {
        succ = true,
        fluid_name = "",
        starting_fluidbox = nil,
        ending_fluidbox = nil,
        from_x = from_x,
        from_y = from_y,
        to_x = to_x,
        to_y = to_y,
        dotted_line_coord = {},
    }
    local State = self.State

    if starting then
        -- starting object should at least have one fluidbox, promised by _builder_init()
        local fluidbox = _find_starting_fluidbox(starting, to_x, to_y, dir)
        State.starting_fluidbox = fluidbox

        local succ
        succ, to_x, to_y = icoord.move(fluidbox.x, fluidbox.y, dir,
            math_abs(to_x - fluidbox.x),
            math_abs(to_y - fluidbox.y)
        )

        if not succ then
            State.succ = false
        end

        local ending = objects:coord(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            if starting.id == ending.id then
                State.succ = false
                State.ending_fluidbox = fluidbox
            else
                for _, another in ipairs(_get_covers_fluidbox(ending)) do
                    if another.dir ~= iprototype.reverse_dir(dir) then
                        goto continue
                    end
                    succ, to_x, to_y = icoord.move(fluidbox.x, fluidbox.y, dir,
                        math_abs(another.x - fluidbox.x),
                        math_abs(another.y - fluidbox.y)
                    )
                    if not succ then
                        goto continue
                    end
                    if to_x == another.x and to_y == another.y then
                        State.ending_fluidbox = another
                        _builder_end(self, datamodel, State, dir, delta)
                        return
                    end
                    ::continue::
                end
                State.succ = false
            end
        end

        if not self._check_coord(to_x, to_y, dir, self.typeobject) then
            State.succ = false
        end
        State.to_x, State.to_y = to_x, to_y
        dir, delta = iprototype.calc_dir(fluidbox.x, fluidbox.y, to_x, to_y)
        _builder_end(self, datamodel, State, dir, delta)
        return
    else
        if not self._check_coord(from_x, from_y, dir, self.typeobject) then
            State.succ = false
        end
        State.from_x, State.from_y = from_x, from_y

        local succ
        local ending = objects:coord(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            -- find one fluidbox that is matched with the direction specified, not the pipe to ground
            for _, fluidbox in ipairs(_get_covers_fluidbox(ending)) do
                if fluidbox.dir ~= iprototype.reverse_dir(dir) then
                    goto continue
                end
                succ, to_x, to_y = icoord.move(fluidbox.x, fluidbox.y, dir,
                    math_abs(from_x - fluidbox.x),
                    math_abs(from_y - fluidbox.y)
                )
                if not succ then
                    goto continue
                end
                if to_x == fluidbox.x and to_y == fluidbox.y then
                    State.ending_fluidbox = fluidbox
                    _builder_end(self, datamodel, State, dir, delta)
                    return
                end
                ::continue::
            end
            State.succ = false
        end

        --
        local succ
        succ, to_x, to_y = icoord.move(from_x, from_y, dir,
            math_abs(to_x - from_x),
            math_abs(to_y - from_y)
        )

        if not succ then
            State.succ = false
        end
        if not self._check_coord(to_x, to_y, dir, self.typeobject) then
            State.succ = false
        end
        State.to_x, State.to_y = to_x, to_y
        dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)
        _builder_end(self, datamodel, State, dir, delta)
        return
    end
end

local function __calc_grid_position(self, typeobject, x, y, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local _, originPosition = icoord.align(math3d.vector {0, 0, 0}, w, h)
    local buildingPosition = icoord.position(x, y, w, h)
    return math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET)
end

local function __align(position_type, prototype_name, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local pos = icamera_controller.get_screen_world_position(position_type)
    local coord, position = icoord.align(pos, iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end
    return math3d.vector(position), coord[1], coord[2]
end

local function _new_entity(self, typeobject, x, y, position, dir)
    iobject.remove(self.coord_indicator)

    self.coord_indicator = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        srt = srt.new {
            t = position,
            r = ROTATORS[dir],
        },
        group_id = 0,
    }

    if not self.grid_entity then
        self.grid_entity = igrid_entity.create(MAP_WIDTH, MAP_HEIGHT, TILE_SIZE, {t = __calc_grid_position(self, typeobject, x, y, dir)})
    end

    self.pickup_components[#self.pickup_components + 1] = create_pickup_selected_box(self.coord_indicator.srt.t, typeobject.area, dir, true)
end

--------------------------------------------------------------------------------------------------
local function touch_move(self, datamodel, delta_vec)
    if not self.coord_indicator then
        return
    end
    if self.coord_indicator then
        iobject.move_delta(self.coord_indicator, delta_vec)
    end
    if self.grid_entity then
        local typeobject = iprototype.queryByName(self.coord_indicator.prototype_name)
        self.grid_entity:set_position(__calc_grid_position(self, typeobject, self.coord_indicator.x, self.coord_indicator.y, self.coord_indicator.dir))
    end
    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.coord_indicator.srt, self.coord_indicator.dir)
    end
end

local function touch_end(self, datamodel)
    if not self.coord_indicator then
        return
    end
    local pos, x, y = __align(self.position_type, self.typeobject.name, self.coord_indicator.dir)
    self.coord_indicator.srt.t, self.coord_indicator.x, self.coord_indicator.y = pos, x, y

    revert_changes({"CONFIRM"})
    if self.dotted_line then
        self.dotted_line:remove()
        self.dotted_line = nil
    end

    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.coord_indicator.srt, self.coord_indicator.dir)
    end

    if self.state == STATE_START then
        _builder_start(self, datamodel)
        for _, c in pairs(self.pickup_components) do
            c:on_status_change(self.State.succ)
        end
    else
        if not self._check_coord(self.coord_indicator.x, self.coord_indicator.y, self.coord_indicator.dir, self.typeobject) then
            self.State = {succ = false}
        else
            self.State = {succ = true}
        end
        for _, c in pairs(self.pickup_components) do
            c:on_status_change(self.State.succ)
        end
    end
end

local igameplay = ecs.require "gameplay.gameplay_system"
local function __complete(self)
    for object_id, object in objects:all("CONFIRM") do -- TODO: duplicate code, see also pipe_function_pop.lua
        -- TODO: special case for assembling machine
        local recipe
        local typeobject = iprototype.queryByName(object.prototype_name)
        if iprototype.has_type(typeobject.type, "assembling") then
            recipe = ""
        end

        local old = objects:get(object_id, {"CONSTRUCTED"})
        if not old then
            object.gameplay_eid = igameplay.create_entity(object)
            object.recipe = recipe
        else
            if old.prototype_name ~= object.prototype_name then
                igameplay.destroy_entity(object.gameplay_eid)
                object.gameplay_eid = igameplay.create_entity(object)
            elseif old.dir ~= object.dir then
                igameplay.rotate(object.gameplay_eid, object.dir)
            end
        end
    end
    objects:commit("CONFIRM", "CONSTRUCTED")
    objects:clear("CONFIRM")
    objects:clear("CONSTRUCTED")

    for object_id in pairs(self.removed) do
        local obj = assert(objects:get(object_id))
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
end

local function complete(self, datamodel)
    __complete(self)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    revert_changes({"CONFIRM"})

    datamodel.show_rotate = false

    local typeobject = iprototype.queryByName(self.coord_indicator.prototype_name)

    local x, y = self.coord_indicator.x, self.coord_indicator.y
    local pos, dir = self.coord_indicator.srt.t, self.coord_indicator.dir
    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    gameplay_core.set_changed(CHANGED_FLAG_BUILDING | CHANGED_FLAG_FLUIDFLOW)

    _new_entity(self, typeobject, x, y, pos, dir)
    return true
end

local function start_laying(self, datamodel)
    local pos, x, y = __align(self.position_type, self.typeobject.name, self.coord_indicator.dir)
    self.coord_indicator.srt.t, self.coord_indicator.x, self.coord_indicator.y = pos, x, y

    revert_changes({"CONFIRM"})

    self.state = STATE_START
    self.from_x = self.coord_indicator.x
    self.from_y = self.coord_indicator.y

    _builder_start(self, datamodel)
end

local function finish_laying(self, datamodel)
    for _, object in objects:all("CONFIRM") do
        object.PREPARE = true
    end

    if self.dotted_line then
        self.dotted_line:remove()
        self.dotted_line = nil
    end

    self.state = STATE_NONE

    return complete(self, datamodel)
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    if self.dotted_line then
        self.dotted_line:remove()
        self.dotted_line = nil
    end

    for _, c in pairs(self.pickup_components) do
        c:remove()
    end
    self.pickup_components = {}

    self.removed = {}
    revert_changes({"CONFIRM"})
    datamodel.show_rotate = false
    self.state = STATE_NONE

    if self.pickup_object then
        iobject.remove(self.pickup_object)
    end
end

local function confirm(self, datamodel)
    if self.State and not self.State.succ then
        log.info("can not construct") --TODO: show error message
        return
    end

    if self.state == STATE_NONE then
        start_laying(self, datamodel)
    elseif self.state == STATE_START then
        finish_laying(self, datamodel)
        __complete(self)
    end
end

local function new(self, datamodel, typeobject, position_type)
    self._check_coord = ecs.require(("editor.rules.check_coord.%s"):format(typeobject.check_coord))

    self.typeobject = typeobject
    self.position_type = position_type

    local dir = DEFAULT_DIR
    local pos, x, y = __align(self.position_type, self.typeobject.name, dir)
    if not pos then
        return
    end

    _new_entity(self, typeobject, x, y, pos, dir)
end

local function build(self, v)
    igameplay.create_entity(v)
end

local function create()
    local m = {}
    m.new = new
    m.touch_move = touch_move
    m.touch_end = touch_end
    m.confirm = confirm
    m.clean = clean
    m.build = build
    m.removed = {}
    m.pickup_components = {}
    m.prototype_name = ""
    m.state = STATE_NONE
    return m
end
return create