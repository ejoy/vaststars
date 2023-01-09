local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"
local iconstant = require "gameplay.interface.constant"
local ALL_DIR = iconstant.ALL_DIR
local terrain = ecs.require "terrain"
local iflow_shape = require "gameplay.utility.flow_shape"
local set_shape_edge = iflow_shape.set_shape_edge
local iobject = ecs.require "object"
local ieditor = ecs.require "editor.editor"
local gameplay_core = require "gameplay.core"
local iflow_connector = require "gameplay.interface.flow_connector"
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"

local pipe_edge_mb = mailbox:sub {"pipe_edge"}
local leave_mb = mailbox:sub {"leave"}

-- see also: pipe_function_pop.rml
local CONNECT <const> = 1
local DISCONNECT <const> = 2
local DISABLE <const> = 3

-- TODO: duplicated in pipebuilder.lua
local function _update_fluid_name(State, fluid_name, fluidflow_id)
    if State.fluid_name ~= "" then
        if fluid_name ~= "" then
            if State.fluid_name ~= fluid_name then
                State.failed = true
            end
        else
            assert(fluidflow_id ~= 0)
            State.fluidflow_ids[fluidflow_id] = true
        end
    else
        if fluid_name ~= "" then
            State.fluid_name = fluid_name
        else
            assert(fluidflow_id ~= 0)
            State.fluidflow_ids[fluidflow_id] = true
        end
    end
end

-- TODO: optimize
local function get_connections(object_id)
    local pipe_object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName("entity", pipe_object.prototype_name)
    assert(typeobject.pipe or typeobject.pipe_to_ground)

    local function __get_connections(typeobject, dir, x, y)
        local connections = {}
        for _, conn in ipairs(typeobject.fluidbox.connections) do
            local dx, dy, dir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
            dx = dx + x
            dy = dy + y
            connections[dir] = {x = dx, y = dy, ground = conn.ground}
        end
        return connections
    end
    local _connections = __get_connections(typeobject, pipe_object.dir, pipe_object.x, pipe_object.y)

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
                            fluidflow_ids = {},
                        }

                        local _typeobject = iprototype.queryByName("entity", _object.prototype_name)
                        if _typeobject.pipe then
                            _update_fluid_name(State, _object.fluid_name, _object.fluidflow_id)
                            if State.failed then
                                connections[dir] = DISABLE
                            else
                                connections[dir] = CONNECT
                            end
                        elseif _typeobject.pipe_to_ground then
                            local conn = __get_connections(_typeobject, _object.dir, _object.x, _object.y)[dir]
                            if conn and conn.ground then
                                _update_fluid_name(State, _object.fluid_name, _object.fluidflow_id)
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
                                if v.x == _x and v.y == _y and v.dir == iprototype.reverse_dir(dir) then
                                    _update_fluid_name(State, _object.fluid_name, _object.fluidflow_id)
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
                local rdir = iprototype.reverse_dir(dir)
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
                                fluidflow_ids = {},
                            }

                            local _typeobject = iprototype.queryByName("entity", _object.prototype_name)
                            if _typeobject.pipe then
                                _update_fluid_name(State, _object.fluid_name, _object.fluidflow_id)
                                if State.failed then
                                    connections[dir] = DISABLE
                                else
                                    connections[dir] = CONNECT
                                end
                            elseif _typeobject.pipe_to_ground then
                                local conn = __get_connections(_typeobject, _object.dir, _object.x, _object.y)[iprototype.reverse_dir(dir)]
                                if conn and not conn.ground then
                                    _update_fluid_name(State, _object.fluid_name, _object.fluidflow_id)
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
                                    if v.x == _x and v.y == _y and v.dir == iprototype.reverse_dir(dir) then
                                        _update_fluid_name(State, _object.fluid_name, _object.fluidflow_id)
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

local EDITOR_CACHE_TEMPORARY = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}

---------------
local M = {}
function M:create(object_id, object_position, ui_x, ui_y)
    local pipe_object = assert(objects:get(object_id))
    local color = {
        [1] = "fluidflow_blue",
        [2] = "fluidflow_chartreuse",
        [3] = "fluidflow_chocolate",
        [4] = "fluidflow_darkviolet",
    }

    ieditor:revert_changes({"TEMPORARY"})
    local o = {}
    for _, dir in ipairs(ALL_DIR) do
        local succ, x, y = terrain:move_coord(pipe_object.x, pipe_object.y, dir, 1)
        if not succ then
            goto continue
        end

        local object = objects:coord(x, y)
        if not object then
            goto continue
        end

        if not object.fluidflow_id then
            goto continue
        end

        o[object.fluid_name] = o[object.fluid_name] or {}
        for _, _object in objects:selectall("fluidflow_id", object.fluidflow_id, EDITOR_CACHE_TEMPORARY) do
            if _object.id ~= pipe_object.id then
                assert(object.fluid_name == _object.fluid_name)
                table.insert(o[object.fluid_name], objects:modify(_object.x, _object.y, EDITOR_CACHE_TEMPORARY, iobject.clone))
            end
        end
        ::continue::
    end
    local idx = 0
    for _, v in pairs(o) do
        idx = idx + 1
        for _, object in ipairs(v) do
            object.state = assert(color[idx])
        end
    end
    iobject.flush()

    return {
        object_id = object_id,
        object_position = object_position,
        left = ui_x,
        top = ui_y,
        connections = get_connections(object_id),
    }
end

function M:stage_ui_update(datamodel)
    local function _update_fluidflow(fluidflow_id, new_fluidflow_id, new_fluid_name)
        for _, object in objects:selectall("fluidflow_id", fluidflow_id, EDITOR_CACHE_TEMPORARY) do
            local _object = objects:coord(object.x, object.y, {"CONSTRUCTED"})
            assert(iprototype.has_type(iprototype.queryByName("entity", _object.prototype_name).type, "fluidbox"))
            _object.fluid_name = new_fluid_name
            _object.fluidflow_id = new_fluidflow_id
            ifluid:update_fluidbox(gameplay_core.get_entity(_object.gameplay_eid), _object.fluid_name) -- TODO: do it in a better way?
            igameplay.update_chimney_recipe(_object)
            objects:sync("CONSTRUCTED", _object, "fluid_name", "fluidflow_id")
            print(("_update_fluidflow %s (%s,%s): %s %s"):format(_object.prototype_name, _object.x, _object.y, _object.fluid_name, _object.fluidflow_id))

            if not iprototype.is_pipe(_object.prototype_name) and not iprototype.is_pipe_to_ground(_object.prototype_name) then
                _object.fluid_icon = true
            end
        end
    end

    --
    for _, _, _, dir, oper in pipe_edge_mb:unpack() do
        print(datamodel.object_id, dir, oper)
        local pipe_object = objects:get(datamodel.object_id)
        local succ, x, y = terrain:move_coord(pipe_object.x, pipe_object.y, dir, 1)
        assert(succ)
        local object = assert(objects:coord(x, y))

        local function _get_covers_fluidbox(object) -- TODO: optimize
            local _prototype_name
            if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
                _prototype_name = iflow_connector.covers(object.prototype_name, object.dir)
            else
                _prototype_name = object.prototype_name
            end

            return ifluid:get_fluidbox(_prototype_name, object.x, object.y, object.dir, object.fluid_name)
        end

        local function _get_fluid_name(object, x, y) -- TODO: optimize
            for _, v in ipairs(_get_covers_fluidbox(object)) do
                local succ, dx, dy = terrain:move_coord(v.x, v.y, v.dir, 1)
                if succ and dx == x and dy == y then
                    return v.fluid_name
                end
            end
        end

        if oper == CONNECT then
            local fluid_name = pipe_object.fluid_name
            if pipe_object.fluid_name == "" then
                _update_fluidflow(pipe_object.fluidflow_id, object.fluidflow_id, _get_fluid_name(object, pipe_object.x, pipe_object.y))
            end

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
                    pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(iprototype.reverse_dir(dir)), true)
                    local shape, _dir = iflow_shape.to_type_dir(pipe_edge)
                    assert(shape)
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, shape)
                    object.dir = _dir
                    _update_fluidflow(object.fluidflow_id, pipe_object.fluidflow_id, pipe_object.fluid_name)

                elseif iprototype.is_pipe_to_ground(object.prototype_name) then
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JI")
                    object.fluid_name = fluid_name
                    object.fluidflow_id = pipe_object.fluidflow_id
                    _update_fluidflow(object.fluidflow_id, pipe_object.fluidflow_id, pipe_object.fluid_name)
                else
                    _update_fluidflow(object.fluidflow_id, pipe_object.fluidflow_id, pipe_object.fluid_name)
                end

            elseif iprototype.is_pipe_to_ground(pipe_object.prototype_name) then
                pipe_object.prototype_name = iflow_shape.to_prototype_name(pipe_object.prototype_name, "JI")

                if iprototype.is_pipe(object.prototype_name) then
                    local pipe_edge = iflow_shape.prototype_name_to_state(object.prototype_name, object.dir)
                    pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(iprototype.reverse_dir(dir)), true)
                    local shape, _dir = iflow_shape.to_type_dir(pipe_edge)
                    assert(shape)
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, shape)
                    object.dir = _dir
                    _update_fluidflow(object.fluidflow_id, pipe_object.fluidflow_id, pipe_object.fluid_name)

                elseif iprototype.is_pipe_to_ground(object.prototype_name) then
                    object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JI")
                    _update_fluidflow(object.fluidflow_id, pipe_object.fluidflow_id, pipe_object.fluid_name)

                else
                    local typeobject = iprototype.queryByName("entity", object.prototype_name)
                    if iprototype.has_type(typeobject.type, "fluidbox") then
                        object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JI")
                        _update_fluidflow(object.fluidflow_id, pipe_object.fluidflow_id, pipe_object.fluid_name)
                    end
                end
            else
                assert(false)
            end

        elseif oper == DISCONNECT then -- TODO: update fluidflow_id when disconnecting? 
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
                    pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(iprototype.reverse_dir(dir)), false)
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
                    pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(iprototype.reverse_dir(dir)), false)
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

        -- TODO: rebuild entity in builder.lua ?
        if pipe_object then
            if pipe_object.__change_keys.prototype_name then
                igameplay.remove_entity(pipe_object.gameplay_eid)
                pipe_object.gameplay_eid = igameplay.create_entity(pipe_object)
            end
        end
        if object then
            if object.__change_keys.prototype_name then
                igameplay.remove_entity(object.gameplay_eid)
                object.gameplay_eid = igameplay.create_entity(object)
            end
        end
        gameplay_core.build()
        datamodel.connections = get_connections(datamodel.object_id)
    end

    for _ in leave_mb:unpack() do
        ieditor:revert_changes({"TEMPORARY"})
    end
end

return M