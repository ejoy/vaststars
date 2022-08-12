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
local global = require "global"
local iobject = ecs.require "object"
local iprototype = require "gameplay.interface.prototype"
local iflow_connector = require "gameplay.interface.flow_connector"
local objects = require "objects"
local terrain = ecs.require "terrain"
local inventory = global.inventory
local iui = ecs.import.interface "vaststars.gamerender|iui"

local EDITOR_CACHE_TEMPORARY = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}

local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR
local STATE_NONE  <const> = 0
local STATE_START <const> = 1

local function _endpoint_connect_skip(prototype_name)
    return iprototype.is_road(prototype_name)
end

local function _get_road_connections(prototype_name, x, y, dir)
    local typeobject = assert(iprototype.queryByName("entity", prototype_name))
    local result = {}
    if not typeobject.crossing then
        return result
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local dx, dy, dir = iprototype.rotate_fluidbox(conn.position, dir, typeobject.area)
        result[#result+1] = {x = x + dx, y = y + dy, dir = dir, ground = conn.ground}
    end
    return result
end

-- auto connect with a neighbor who has connection
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

        if _endpoint_connect_skip(object.prototype_name) then
            goto continue
        end

        for _, v in ipairs(_get_road_connections(object.prototype_name, object.x, object.y, object.dir)) do
            succ, _x, _y = terrain:move_coord(v.x, v.y, v.dir, 1)
            if succ and _x == x and _y == y then
                pipe_edge = set_shape_edge(pipe_edge, iprototype.dir_tonumber(dir), true)
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
        if not iprototype.is_road(object.prototype_name) then
            State.failed = true
        else
            pipe_edge = iflow_shape.prototype_name_to_state(object.prototype_name, object.dir)
        end
    end
    return pipe_edge
end

local function _get_distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

local function _get_covers_connections(object)
    local prototype_name
    if iprototype.is_road(object.prototype_name) then
        prototype_name = iflow_connector.covers(object.prototype_name, object.dir)
    else
        prototype_name = object.prototype_name
    end
    return _get_road_connections(prototype_name, object.x, object.y, object.dir)
end

local function _match_connections(connections, x, y, dir)
    local min = math.maxinteger
    local f
    for _, v in ipairs(connections) do
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
    local item_typeobject = iprototype.queryByName("item", iflow_connector.covers(self.prototype_name, DEFAULT_DIR))
    local item = assert(inventory:modity(item_typeobject.id)) -- promise by new_entity()

    local dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir, -- calculate the max distance according to the item count
        math.min(math.abs(from_x - to_x), item.count - 1),
        math.min(math.abs(from_y - to_y), item.count - 1)
    )
    dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y) -- recalc delta
    assert(succ)

    local prototype_name = self.prototype_name
    local dir_num = iprototype.dir_tonumber(iprototype.calc_dir(from_x, from_y, to_x, to_y))
    local reverse_dir_num = iprototype.dir_tonumber(iprototype.reverse_dir(dir))

    local map = {}
    local coord
    local State = {
        failed = false,
    }

    local x, y = from_x, from_y
    while true do
        coord = packcoord(x, y)

        if x == from_x and y == from_y then
            local _object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
            if _object then
                if iprototype.is_road(_object.prototype_name) then
                    local pipe_edge = _set_pipe(State, x, y)
                    pipe_edge = set_shape_edge(pipe_edge, dir_num, true)
                    map[coord] = pipe_edge

                else
                    -- entity is not a pipe or a pipe to ground, (from_x, from_y) is the connection coord of the entity
                    -- find the connection of the entity equal to (from_x, from_y) -- TODO: optimize
                    local fb = _match_connections(_get_road_connections(_object.prototype_name, _object.x, _object.y, _object.dir), from_x, from_y, dir)
                    if not fb then -- no connection in the direction of the entity
                        State.failed = true
                    else
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
                if iprototype.is_road(_object.prototype_name) then
                    local pipe_edge = _set_pipe(State, x, y)
                    pipe_edge = set_shape_edge(pipe_edge, reverse_dir_num, true)
                    map[coord] = pipe_edge

                else
                    local found = false
                    for _, v in ipairs(_get_road_connections(_object.prototype_name, _object.x, _object.y, _object.dir)) do
                        if v.dir == iprototype.reverse_dir(dir) and (from_x == v.x or from_y == v.y) then
                            found = true
                            break -- only one connection aligned with the start point
                        end
                    end
                    if not found then
                        State.failed = true
                    end
                    map[coord] = 0

                end
            else
                local pipe_edge = _set_endpoint_connect(State, x, y)
                pipe_edge = set_shape_edge(pipe_edge, reverse_dir_num, true)
                map[coord] = pipe_edge
            end
        else
            local pipe_edge = _set_pipe(State, x, y)
            pipe_edge = set_shape_edge(pipe_edge, dir_num, true)
            pipe_edge = set_shape_edge(pipe_edge, reverse_dir_num, true)
            map[coord] = pipe_edge
        end

        if x == to_x and y == to_y then
            break
        end
        x, y = x + delta.x, y + delta.y
    end

    local object_state = State.failed and "invalid_construct" or "construct"
    self.coord_indicator.state = object_state

    for coord, state in pairs(map) do
        local x, y = unpackcoord(coord)
        local shape, dir = iflow_shape.to_type_dir(state)
        local object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
        if object then
            if iprototype.is_road(object.prototype_name) then
                local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
                _object.prototype_name = iflow_shape.to_prototype_name(prototype_name, shape)
                _object.dir = dir
                _object.state = object_state
                objects:set(_object, EDITOR_CACHE_TEMPORARY[1])

            else
                local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
                _object.state = object_state
            end
        else
            object = iobject.new {
                prototype_name = iflow_shape.to_prototype_name(prototype_name, shape),
                dir = dir,
                x = x,
                y = y,
                state = object_state,
            }
            objects:set(object, EDITOR_CACHE_TEMPORARY[1])
            item.count = item.count - 1
            assert(item.count >= 0)
        end
    end

    datamodel.show_laying_road_confirm = not State.failed
    iui.update("construct.rml", "update_construct_inventory")
end

local function state_init(self, datamodel)
    local coord_indicator = self.coord_indicator

    local function show_indicator(prototype_name, object)
        local succ, dx, dy, obj, _prototype_name, _dir
        for _, fb in ipairs(_get_covers_connections(object)) do
            succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
            if succ then
                obj = objects:coord(dx, dy, EDITOR_CACHE_TEMPORARY)
                if not obj then
                    _prototype_name, _dir = iflow_connector.set_connection(prototype_name, DEFAULT_DIR, iprototype.reverse_dir(fb.dir), true) -- TODO: why DEFAULT_DIR?
                    obj = iobject.new {
                        prototype_name = _prototype_name,
                        dir = _dir,
                        x = dx,
                        y = dy,
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
        return #_get_covers_connections(object) > 0
    end

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_laying_road_begin = true
        coord_indicator.state = "construct"

        local object = objects:coord(coord_indicator.x, coord_indicator.y, EDITOR_CACHE_TEMPORARY)
        if object then
            show_indicator(self.prototype_name, object)
        end
    else
        datamodel.show_laying_road_begin = false
        coord_indicator.state = "invalid_construct"
    end
end

local function state_start(self, datamodel)
    local starting_object = objects:coord(self.from_x, self.from_y, EDITOR_CACHE_TEMPORARY)
    local ending_object = objects:coord(self.coord_indicator.x, self.coord_indicator.y, EDITOR_CACHE_TEMPORARY)
    if starting_object then
        local connections = _get_covers_connections(starting_object)
        if #connections <= 0 then
            self.coord_indicator.state = "invalid_construct"
            datamodel.show_laying_road_confirm = false
            return
        end

        local dir = iprototype.calc_dir(self.from_x, self.from_y, self.coord_indicator.x, self.coord_indicator.y)
        table.sort(connections, function(a, b) -- TODO: sort by distance and direction
            local dist1 = _get_distance(a.x, a.y, self.coord_indicator.x, self.coord_indicator.y)
            local dist2 = _get_distance(b.x, b.y, self.coord_indicator.x, self.coord_indicator.y)
            if dist1 < dist2 then
                return true
            elseif dist1 > dist2 then
                return false
            end

            return ((a.dir == dir) and 0 or 1) < ((b.dir == dir) and 0 or 1)
        end)

        local from_x, from_y = connections[1].x, connections[1].y
        if ending_object then
            if starting_object.id == ending_object.id then
                self.coord_indicator.state = "invalid_construct"
                datamodel.show_laying_road_confirm = false
                return
            end

            for _, v in ipairs(_get_road_connections(ending_object.prototype_name, ending_object.x, ending_object.y, ending_object.dir)) do
                if v.dir == iprototype.reverse_dir(dir) and (from_x == v.x or from_y == v.y) then
                    state_end(self, datamodel, from_x, from_y, v.x, v.y)
                    return
                end
            end
        end

        local succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir, math.abs(self.coord_indicator.x - from_x), math.abs(self.coord_indicator.y - from_y))
        if not succ then -- TODO: check map boundary
            self.coord_indicator.state = "invalid_construct"
            datamodel.show_laying_road_confirm = false
            return
        end
        state_end(self, datamodel, from_x, from_y, to_x, to_y)
        return
    else
        if ending_object then
            local from_x, from_y = self.from_x, self.from_y
            local dir = iprototype.calc_dir(self.from_x, self.from_y, self.coord_indicator.x, self.coord_indicator.y)

            if iprototype.is_road(ending_object.prototype_name) then
                state_end(self, datamodel, from_x, from_y, self.coord_indicator.x, self.coord_indicator.y)
                return
            else
                for _, v in ipairs(_get_road_connections(ending_object.prototype_name, ending_object.x, ending_object.y, ending_object.dir)) do
                    if v.dir == iprototype.reverse_dir(dir) and (from_x == v.x or from_y == v.y) then
                        state_end(self, datamodel, from_x, from_y, v.x, v.y)
                        return
                    end
                end

                local succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir, math.abs(self.coord_indicator.x - from_x), math.abs(self.coord_indicator.y - from_y))
                if not succ then -- TODO: check map boundary
                    self.coord_indicator.state = "invalid_construct"
                    datamodel.show_laying_road_confirm = false
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
                datamodel.show_laying_road_confirm = false
                return
            end
            state_end(self, datamodel, from_x, from_y, to_x, to_y)
            return
        end
    end
end

--------------------------------------------------------------------------------------------------
local function new_entity(self, datamodel, typeobject)
    -- check if item is in the inventory
    local item_typeobject = iprototype.queryByName("item", typeobject.name)
    local item = inventory:get(item_typeobject.id)
    if item.count <= 0 then
        log.error("Lack of item: " .. typeobject.name) -- TODO: show error message?
        self:clean(datamodel)
        return
    end

    iobject.remove(self.coord_indicator)
    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir)
    self.prototype_name = iflow_connector.cleanup(typeobject.name, dir)
    self.coord_indicator = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        state = "construct"
    }

    --
    state_init(self, datamodel)
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
    iobject.align(self.coord_indicator)
    self:revert_changes({"INDICATOR", "TEMPORARY"})
    inventory:revert()

    if self.state ~= STATE_START then
        state_init(self, datamodel)
    else
        state_start(self, datamodel)
    end
end

local function complete(self, datamodel)
    if not inventory:complete() then
        return
    end

    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    self:revert_changes({"INDICATOR", "TEMPORARY"})

    datamodel.show_rotate = false
    datamodel.show_laying_road_confirm = false
    datamodel.show_laying_road_cancel = false

    self.super.complete(self)

    datamodel.show_laying_road_begin = false
    datamodel.show_construct_complete = false
end

local function laying_pipe_begin(self, datamodel)
    iobject.align(self.coord_indicator)
    self:revert_changes({"INDICATOR", "TEMPORARY"})
    datamodel.show_laying_road_begin = false
    datamodel.show_laying_road_cancel = true

    self.state = STATE_START
    self.from_x = self.coord_indicator.x
    self.from_y = self.coord_indicator.y

    state_start(self, datamodel)
end

local function laying_pipe_cancel(self, datamodel)
    inventory:revert()
    iui.update("construct.rml", "update_construct_inventory")

    self:revert_changes({"INDICATOR", "TEMPORARY"})
    local typeobject = iprototype.queryByName("entity", self.coord_indicator.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.state = STATE_NONE
    datamodel.show_laying_road_confirm = false
    datamodel.show_laying_road_cancel = false
    datamodel.show_construct_complete = true
end

local function laying_pipe_confirm(self, datamodel)
    for _, object in objects:all("TEMPORARY") do
        object.state = "confirm"
        object.PREPARE = true
    end
    objects:commit("TEMPORARY", "CONFIRM")
    inventory:confirm()

    local typeobject = iprototype.queryByName("entity", self.coord_indicator.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.state = STATE_NONE
    datamodel.show_laying_road_confirm = false
    datamodel.show_laying_road_cancel = false
    datamodel.show_construct_complete = true
end

local function clean(self, datamodel)
    iobject.remove(self.coord_indicator)
    self.coord_indicator = nil

    self:revert_changes({"INDICATOR", "TEMPORARY"})
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
    -- M.from_x
    -- M.from_y
    M.laying_pipe_begin = laying_pipe_begin
    M.laying_pipe_cancel = laying_pipe_cancel
    M.laying_pipe_confirm = laying_pipe_confirm
    return M
end
return create