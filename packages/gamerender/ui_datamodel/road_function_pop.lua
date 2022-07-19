local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iconstant = require "gameplay.interface.constant"
local ALL_DIR = iconstant.ALL_DIR
local terrain = ecs.require "terrain"
local ieditor = ecs.require "editor.editor"
local iflow_connector = require "gameplay.interface.flow_connector"
local gameplay_core = require "gameplay.core"

local pipe_edge_mb = mailbox:sub {"pipe_edge"}
local leave_mb = mailbox:sub {"leave"}

-- see also: pipe_function_pop.rml
local CONNECT <const> = 1
local DISCONNECT <const> = 2
local DISABLE <const> = 3

-- TODO: duplicate code with roadbuilder.lua
local function _get_road_connections(prototype_name, dir, x, y)
    local typeobject = assert(iprototype.queryByName("entity", prototype_name))
    local result = {}
    if not typeobject.crossing then
        return result
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local dx, dy, dir = iprototype.rotate_fluidbox(conn.position, dir, typeobject.area)
        result[dir] = {x = x + dx, y = y + dy, dir = dir, ground = conn.ground}
    end
    return result
end

-- TODO: optimize
local function get_connections(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    assert(typeobject.crossing)

    local _connections = _get_road_connections(typeobject.name, object.dir, object.x, object.y)

    local connections = {}
    for _, dir in ipairs(ALL_DIR) do
        if _connections[dir] then
            connections[dir] = DISCONNECT
        else
            local succ, _x, _y = terrain:move_coord(object.x, object.y, dir, 1) -- assume the entity has connection
            if not succ then
                connections[dir] = DISABLE
            else
                local _object = objects:coord(_x, _y)
                if not _object then
                    connections[dir] = DISABLE
                else
                    local State = {
                        failed = false,
                    }

                    if iprototype.is_road(_object.prototype_name) then
                        connections[dir] = CONNECT
                    else
                        connections[dir] = DISABLE
                    end

                    for _, v in pairs(_get_road_connections(_object.prototype_name, _object.dir, _object.x, _object.y)) do
                        if v.x == _x and v.y == _y and v.dir == iprototype.reverse_dir(dir) then
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
    for _, _, _, dir, oper in pipe_edge_mb:unpack() do
        print(datamodel.object_id, dir, oper)
        local object = objects:get(datamodel.object_id)
        local succ, x, y = terrain:move_coord(object.x, object.y, dir, 1)
        assert(succ)
        local neighbor = assert(objects:coord(x, y))
        local connected

        if oper == CONNECT then
            connected = true
        elseif oper == DISCONNECT then
            connected = false
        else
            assert(false)
        end

        if iprototype.is_road(object.prototype_name) then
            object.prototype_name, object.dir = iflow_connector.set_connection(object.prototype_name, object.dir, dir, connected)
            assert(object.prototype_name)

            if iprototype.is_road(neighbor.prototype_name) then
                neighbor.prototype_name, neighbor.dir = iflow_connector.set_connection(neighbor.prototype_name, neighbor.dir, iprototype.reverse_dir(dir), connected)
                assert(neighbor.prototype_name)
            end
        else
            assert(false)
        end

        -- TODO: rebuild entity in builder.lua ?
        if object then
            if object.__change.prototype_name then
                gameplay_core.remove_entity(object.gameplay_eid)
                object.gameplay_eid = gameplay_core.create_entity(object)
            end
        end
        if neighbor then
            if neighbor.__change.prototype_name then
                gameplay_core.remove_entity(neighbor.gameplay_eid)
                neighbor.gameplay_eid = gameplay_core.create_entity(neighbor)
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