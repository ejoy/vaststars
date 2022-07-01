local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"
local iconstant = require "gameplay.interface.constant"
local ALL_DIR = iconstant.ALL_DIR
local terrain = ecs.require "terrain"
local iflow_shape = require "gameplay.utility.flow_shape"
local set_shape_edge = iflow_shape.set_shape_edge
local iui = ecs.import.interface "vaststars.gamerender|iui"

local pipe_edge_mb = mailbox:sub {"pipe_edge"}

-- see also: pipe_function_pop.rml
local CONNECT <const> = 1
local DISCONNECT <const> = 2
local DISABLE <const> = 3

-- TODO: duplicated in pipebuilder.lua
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

local function get_connections(object_id)
    local pipe_object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(pipe_object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName("entity", pipe_object.prototype_name)
    assert(typeobject.pipe or typeobject.pipe_to_ground)

    local function get_connections(typeobject, dir, x, y)
        local connections = {}
        for _, conn in ipairs(typeobject.fluidbox.connections) do
            local dx, dy, dir = iprototype.rotate_fluidbox(conn.position, dir, typeobject.area)
            dx = dx + x
            dy = dy + y
            connections[dir] = {x = dx, y = dy, ground = conn.ground}
        end
        return connections
    end
    local _connections = get_connections(typeobject, pipe_object.dir, pipe_object.x, pipe_object.y)

    local connections = {}
    if typeobject.pipe then
        for _, dir in ipairs(ALL_DIR) do
            if _connections[dir] then
                connections[dir] = DISCONNECT
            else
                local succ, _x, _y = terrain:move_coord(pipe_object.x, pipe_object.y, dir, 1) -- assume the pipe has fluidbox
                if not succ then
                    connections[dir] = DISABLE
                else
                    local _object = objects:coord(_x, _y)
                    if not _object then
                        connections[dir] = DISABLE
                    else
                        local State = {
                            failed = false,
                            fluid_name = pipe_object.fluid_name,
                            fluidflow_network_ids = {},
                        }

                        local _typeobject = iprototype.queryByName("entity", _object.prototype_name)
                        if _typeobject.pipe then
                            _update_fluid_name(State, _object.fluid_name, _object.fluidflow_network_id)
                            if State.failed then
                                connections[dir] = DISABLE
                            else
                                connections[dir] = CONNECT
                            end
                        elseif _typeobject.pipe_to_ground then
                            local conn = get_connections(_typeobject, _object.dir, _object.x, _object.y)[dir]
                            if conn and conn.ground then
                                _update_fluid_name(State, _object.fluid_name, _object.fluidflow_network_id)
                                if State.failed then
                                    connections[dir] = DISABLE
                                else
                                    connections[dir] = CONNECT
                                end
                            else
                                connections[dir] = DISABLE
                            end
                        else
                            for _, v in ipairs(ifluid:get_fluidbox(_typeobject.name, _object.x, _object.y, _object.dir)) do
                                if v.x == _x and v.y == _y and v.dir == iprototype.opposite_dir(dir) then
                                    _update_fluid_name(State, _object.fluid_name, _object.fluidflow_network_id)
                                    if State.failed then
                                        connections[dir] = DISABLE
                                    else
                                        connections[dir] = CONNECT
                                    end
                                    break
                                end
                            end
                            if not connections[dir] then
                                connections[dir] = DISABLE
                            end
                        end
                    end
                end
            end
        end

    elseif typeobject.pipe_to_ground then
        for _, dir in ipairs(ALL_DIR) do
            if _connections[dir] then
                if not _connections[dir].ground then
                    connections[dir] = DISCONNECT
                else
                    connections[dir] = DISABLE
                end
            else
                local rdir = iprototype.opposite_dir(dir)
                if not _connections[rdir] then
                    connections[dir] = DISABLE
                else
                    assert(_connections[rdir].ground)
                    local succ, _x, _y = terrain:move_coord(pipe_object.x, pipe_object.y, dir, 1, 1)
                    if not succ then
                        connections[dir] = DISABLE
                    else
                        local _object = objects:coord(_x, _y)
                        if not _object then
                            connections[dir] = DISABLE
                        else
                            local State = {
                                failed = false,
                                fluid_name = pipe_object.fluid_name,
                                fluidflow_network_ids = {},
                            }

                            local _typeobject = iprototype.queryByName("entity", _object.prototype_name)
                            if _typeobject.pipe then
                                _update_fluid_name(State, _object.fluid_name, _object.fluidflow_network_id)
                                if State.failed then
                                    connections[dir] = DISABLE
                                else
                                    connections[dir] = CONNECT
                                end
                            elseif _typeobject.pipe_to_ground then
                                local conn = get_connections(_typeobject, _object.dir, _object.x, _object.y)[iprototype.opposite_dir(dir)]
                                if conn and not conn.ground then
                                    _update_fluid_name(State, _object.fluid_name, _object.fluidflow_network_id)
                                    if State.failed then
                                        connections[dir] = DISABLE
                                    else
                                        connections[dir] = CONNECT
                                    end
                                else
                                    connections[dir] = DISABLE
                                end
                            else
                                for _, v in ipairs(ifluid:get_fluidbox(_typeobject.name, _object.x, _object.y, _object.dir)) do
                                    if v.x == _x and v.y == _y and v.dir == iprototype.opposite_dir(dir) then
                                        _update_fluid_name(State, _object.fluid_name, _object.fluidflow_network_id)
                                        if State.failed then
                                            connections[dir] = DISABLE
                                        else
                                            connections[dir] = CONNECT
                                        end
                                        break
                                    end
                                end
                                if not connections[dir] then
                                    connections[dir] = DISABLE
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return connections
end

---------------
local M = {}
function M:create(object_id, left, top)
    return {
        object_id = object_id,
        left = ("%0.2fvmin"):format(math.max(left - 34, 0)),
        top = ("%0.2fvmin"):format(math.max(top - 34, 0)),
        connections = get_connections(object_id),
    }
end

function M:stage_ui_update(datamodel)
    --
    for _, _, _, dir, oper in pipe_edge_mb:unpack() do -- TODO: optimize, update fluidflow_network_id only when necessary
        print(datamodel.object_id, dir, oper)
        local pipe_object = objects:get(datamodel.object_id)
        local succ, x, y = terrain:move_coord(pipe_object.x, pipe_object.y, dir, 1)
        assert(succ)
        local object = assert(objects:coord(x, y))

        if oper == CONNECT then
            if iprototype.is_pipe(pipe_object.prototype_name) then
                --
                local pipe_edge = iflow_shape.prototype_name_to_state(pipe_object.prototype_name, pipe_object.dir)
                pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(dir), true)
                local shape, _dir = iflow_shape.to_type_dir(pipe_edge)
                assert(shape)
                pipe_object.prototype_name = iflow_shape.to_prototype_name(pipe_object.prototype_name, shape)
                pipe_object.dir = _dir

                if iprototype.is_pipe(object.prototype_name) then
                    local pipe_edge = iflow_shape.prototype_name_to_state(object.prototype_name, object.dir)
                    pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(iprototype.opposite_dir(dir)), true)
                    local shape, _dir = iflow_shape.to_type_dir(pipe_edge)
                    assert(shape)
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, shape)
                    object.dir = _dir

                elseif iprototype.is_pipe_to_ground(object.prototype_name) then
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JI")
                end

            elseif iprototype.is_pipe_to_ground(pipe_object.prototype_name) then
                pipe_object.prototype_name = iflow_shape.to_prototype_name(pipe_object.prototype_name, "JI")

                if iprototype.is_pipe(object.prototype_name) then
                    local pipe_edge = iflow_shape.prototype_name_to_state(object.prototype_name, object.dir)
                    pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(iprototype.opposite_dir(dir)), true)
                    local shape, _dir = iflow_shape.to_type_dir(pipe_edge)
                    assert(shape)
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, shape)
                    object.dir = _dir

                elseif iprototype.is_pipe_to_ground(object.prototype_name) then
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JI")
                end
            else
                assert(false)
            end

        elseif oper == DISCONNECT then
            if iprototype.is_pipe(pipe_object.prototype_name) then
                --
                local pipe_edge = iflow_shape.prototype_name_to_state(pipe_object.prototype_name, pipe_object.dir)
                pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(dir), false)
                local shape, _dir = iflow_shape.to_type_dir(pipe_edge)
                assert(shape)
                pipe_object.prototype_name = iflow_shape.to_prototype_name(pipe_object.prototype_name, shape)
                pipe_object.dir = _dir

                if iprototype.is_pipe(object.prototype_name) then
                    local pipe_edge = iflow_shape.prototype_name_to_state(object.prototype_name, object.dir)
                    pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(iprototype.opposite_dir(dir)), false)
                    local shape, _dir = iflow_shape.to_type_dir(pipe_edge)
                    assert(shape)
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, shape)
                    object.dir = _dir

                elseif iprototype.is_pipe_to_ground(object.prototype_name) then
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JU")
                end
            elseif iprototype.is_pipe_to_ground(pipe_object.prototype_name) then
                pipe_object.prototype_name = iflow_shape.to_prototype_name(pipe_object.prototype_name, "JU")

                if iprototype.is_pipe(object.prototype_name) then
                    local pipe_edge = iflow_shape.prototype_name_to_state(object.prototype_name, object.dir)
                    pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(iprototype.opposite_dir(dir)), false)
                    local shape, _dir = iflow_shape.to_type_dir(pipe_edge)
                    assert(shape)
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, shape)
                    object.dir = _dir

                elseif iprototype.is_pipe_to_ground(object.prototype_name) then
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JU")
                end
            else
                assert(false)
            end

        else
            assert(false)
        end

        datamodel.connections = get_connections(datamodel.object_id)
    end
end

return M