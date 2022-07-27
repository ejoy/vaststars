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
local inventory = global.inventory
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"
local gameplay_core = require "gameplay.core"
local math_abs = math.abs
local math_min = math.min
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}

local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR
local STATE_NONE  <const> = 0
local STATE_START <const> = 1

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
                _update_fluid_name(State, fb.fluid_name, object.fluidflow_id)
                goto continue -- only one fluidbox can be connected to the endpoint
            end
        end
        ::continue::
    end
    return prototype_name, dir
end

local function _get_covers_fluidbox(object)
    local prototype_name
    if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        prototype_name = iflow_connector.covers(object.prototype_name, object.dir)
    else
        prototype_name = object.prototype_name
    end

    local t = {}
    for _, fb in ipairs(ifluid:get_fluidbox(prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
        if fb.ground then
            goto continue
        end

        t[#t+1] = fb
        ::continue::
    end
    return t
end

local function _set_endpoint_connection(State, object, fluidbox, forward_dir)
    if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        _update_fluid_name(State, object.fluid_name, object.fluidflow_id)
        return iflow_connector.set_connection(object.prototype_name, object.dir, forward_dir, true)
    else
        if not fluidbox then
            State.succ = false
        else
            _update_fluid_name(State, fluidbox.fluid_name, object.fluidflow_id)
        end
        return object.prototype_name, object.dir
    end
end

local function _builder_end(self, datamodel, State, dir, dir_delta)
    local reverse_dir = iprototype.reverse_dir(dir)
    local prototype_name = self.prototype_name
    local item_typeobject = iprototype.queryByName("item", iflow_connector.covers(self.prototype_name, DEFAULT_DIR))
    local item = assert(inventory:modity(item_typeobject.id)) -- promise by new_entity()
    local map = {}

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

    while true do
        local coord = packcoord(x, y)
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        item.count = item.count - 1

        if x == from_x and y == from_y then
            if object then
                map[coord] = {_set_endpoint_connection(State, object, State.starting_fluidbox, dir)}
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
                map[coord] = {_set_endpoint_connection(State, object, State.ending_fluidbox, reverse_dir)}
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

    iui.update("construct.rml", "update_construct_inventory")

    local new_fluidflow_id = 0
    if State.succ then
        global.fluidflow_id = global.fluidflow_id + 1
        new_fluidflow_id = global.fluidflow_id
    end
    local object_state = State.succ and "construct" or "invalid_construct"
    self.coord_indicator.state = object_state

    for coord, v in pairs(map) do
        local x, y = unpackcoord(coord)
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if object then
            object = objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone)
            object.prototype_name = v[1]
            object.dir = v[2]
            object.state = object_state
        else
            object = iobject.new {
                prototype_name = v[1],
                dir = v[2],
                x = x,
                y = y,
                fluid_name = State.fluid_name,
                fluidflow_id = new_fluidflow_id,
                state = object_state,
            }
            objects:set(object, EDITOR_CACHE_NAMES[1])
        end
    end

    for fluidflow_id in pairs(State.fluidflow_ids) do
        for _, object in objects:selectall("fluidflow_id", fluidflow_id, EDITOR_CACHE_NAMES) do
            local _object = objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone)
            assert(iprototype.has_type(iprototype.queryByName("entity", _object.prototype_name).type, "fluidbox"))
            _object.fluid_name = State.fluid_name
            _object.fluidflow_id = new_fluidflow_id
        end
    end

    datamodel.show_laying_pipe_confirm = State.succ
end

local function _builder_init(self, datamodel)
    local coord_indicator = self.coord_indicator

    local function show_indicator(prototype_name, object)
        local succ, dx, dy, obj, _prototype_name, _dir
        for _, fb in ipairs(_get_covers_fluidbox(object)) do
            succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
            if not succ then
                goto continue
            end
            if not self:check_construct_detector(prototype_name, dx, dy, DEFAULT_DIR) then
                goto continue
            end

            obj = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
            if not obj then
                _prototype_name, _dir = iflow_connector.set_connection(prototype_name, DEFAULT_DIR, iprototype.reverse_dir(fb.dir), true) -- TODO: fb.dir may be invalid, assert by iflow_connector.set_connection()
                if _prototype_name then
                    obj = iobject.new {
                        prototype_name = _prototype_name,
                        dir = _dir,
                        x = dx,
                        y = dy,
                        fluid_name = "",
                        state = "indicator",
                    }
                    objects:set(obj, "INDICATOR")
                end
            end
            ::continue::
        end
    end

    local function is_valid_starting(x, y)
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        if not object then
            return true
        end
        return #_get_covers_fluidbox(object) > 0
    end

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_laying_pipe_begin = true
        coord_indicator.state = "construct"

        local object = objects:coord(coord_indicator.x, coord_indicator.y, EDITOR_CACHE_NAMES)
        if object then
            show_indicator(self.prototype_name, object)
        end
    else
        datamodel.show_laying_pipe_begin = false
        coord_indicator.state = "invalid_construct"
    end
end

-- sort by distance and direction
local function _find_starting_fluidbox(object, dx, dy, dir)
    local fluidboxes = _get_covers_fluidbox(object)
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
    local prototype_name = self.coord_indicator.prototype_name
    local starting = objects:coord(from_x, from_y, EDITOR_CACHE_NAMES)
    local dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local item_typeobject = iprototype.queryByName("item", iflow_connector.covers(self.prototype_name, DEFAULT_DIR))
    local item = assert(inventory:modity(item_typeobject.id)) -- promise by new_entity()

    local State = {
        succ = true,
        fluid_name = "",
        fluidflow_ids = {},
        starting_fluidbox = nil,
        starting_fluidflow_id = nil,
        ending_fluidbox = nil,
        ending_fluidflow_id = nil,
        from_x = from_x,
        from_y = from_y,
        to_x = to_x,
        to_y = to_y,
    }

    if starting then
        -- starting object should at least have one fluidbox, promised by _builder_init()
        local fluidbox = _find_starting_fluidbox(starting, to_x, to_y, dir)
        State.starting_fluidbox, State.starting_fluidflow_id = fluidbox, starting.fluidflow_id
        if fluidbox.dir ~= dir then
            State.succ = false
        end

        local succ
        succ, to_x, to_y = terrain:move_coord(fluidbox.x, fluidbox.y, dir,
            math_min(math_abs(to_x - fluidbox.x), item.count - 1),
            math_min(math_abs(to_y - fluidbox.y), item.count - 1)
        )
        if not succ then
            State.succ = false
        end

        local ending = objects:coord(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            if starting.id == ending.id then
                State.succ = false
                State.ending_fluidbox, State.ending_fluidflow_id = fluidbox, ending.fluidflow_id
            else
                for _, another in ipairs(_get_covers_fluidbox(ending)) do
                    if another.dir == iprototype.reverse_dir(dir) and (fluidbox.x == another.x or fluidbox.y == another.y) then
                        dir, delta = iprototype.calc_dir(fluidbox.x, fluidbox.y, another.x, another.y)
                        State.ending_fluidbox, State.ending_fluidflow_id = another, ending.fluidflow_id
                        _builder_end(self, datamodel, State, dir, delta)
                        return
                    end
                end
                State.succ = false
            end
        end

        if not self:check_construct_detector(prototype_name, to_x, to_y, DEFAULT_DIR) then
            State.succ = false
        end
        State.to_x, State.to_y = to_x, to_y
        dir, delta = iprototype.calc_dir(fluidbox.x, fluidbox.y, to_x, to_y)
        _builder_end(self, datamodel, State, dir, delta)
        return
    else
        if not self:check_construct_detector(prototype_name, from_x, from_y, DEFAULT_DIR) then
            State.succ = false
        end
        State.from_x, State.from_y = from_x, from_y

        local ending = objects:coord(to_x, to_y, EDITOR_CACHE_NAMES)
        if ending then
            for _, fluidbox in ipairs(_get_covers_fluidbox(ending)) do
                if fluidbox.dir == iprototype.reverse_dir(dir) and (from_x == fluidbox.x or from_y == fluidbox.y) then
                    State.ending_fluidbox, State.ending_fluidflow_id = fluidbox, ending.fluidflow_id
                    dir, delta = iprototype.calc_dir(from_x, from_y, fluidbox.x, fluidbox.y)
                    _builder_end(self, datamodel, State, dir, delta)
                    return
                end
            end
            State.succ = false
        end

        --
        local succ
        succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir,
            math_min(math_abs(to_x - from_x), item.count - 1),
            math_min(math_abs(to_y - from_y), item.count - 1)
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

--------------------------------------------------------------------------------------------------
local function new_entity(self, datamodel, typeobject)
    -- check if item is in the inventory
    local item_typeobject = iprototype.queryByName("item", typeobject.name)
    local item = inventory:get(item_typeobject.id)
    if item.count <= 0 then
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
        fluid_name = "",
        state = "construct"
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
    iobject.align(self.coord_indicator)
    self:revert_changes({"INDICATOR", "TEMPORARY"})
    inventory:revert()

    if self.state ~= STATE_START then
        _builder_init(self, datamodel)
    else
        _builder_start(self, datamodel)
    end
end

local function complete(self, datamodel)
    local gameplay_world = gameplay_core.get_world()
    local e = iworld:get_headquater_entity(gameplay_world)
    if not e then
        log.error("can not find headquater entity")
        return
    end

    if not inventory:complete() then
        return
    end

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

    _builder_start(self, datamodel)
end

local function laying_pipe_cancel(self, datamodel)
    inventory:revert()
    iui.update("construct.rml", "update_construct_inventory")

    self:revert_changes({"INDICATOR", "TEMPORARY"})
    local typeobject = iprototype.queryByName("entity", self.coord_indicator.prototype_name)
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
    inventory:confirm()

    local typeobject = iprototype.queryByName("entity", self.coord_indicator.prototype_name)
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
    M.laying_pipe_begin = laying_pipe_begin
    M.laying_pipe_cancel = laying_pipe_cancel
    M.laying_pipe_confirm = laying_pipe_confirm
    return M
end
return create