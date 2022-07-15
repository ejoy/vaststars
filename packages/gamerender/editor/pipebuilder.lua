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
local ipipe_connector = require "gameplay.interface.pipe_connector"
local objects = require "objects"
local terrain = ecs.require "terrain"
local construct_inventory = global.construct_inventory
local _VASTSTARS_DEBUG_INFINITE_ITEM <const> = world.args.ecs.VASTSTARS_DEBUG_INFINITE_ITEM or require("debugger").infinite_item()
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"
local gameplay_core = require "gameplay.core"

local EDITOR_CACHE_TEMPORARY = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}

local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR
local STATE_NONE  <const> = 0
local STATE_START <const> = 1

-- fluidflow_id may be nil, such as fluidboxes
local function _update_fluid_name(State, fluid_name, fluidflow_id)
    if State.fluid_name ~= "" then
        if fluid_name ~= "" then
            if State.fluid_name ~= fluid_name then
                State.failed = true
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
                _update_fluid_name(State, v.fluid_name, object.fluidflow_id)
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
            _update_fluid_name(State, object.fluid_name, object.fluidflow_id)
        end
    end
    return pipe_edge
end

local function _get_distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

local function _get_covers_fluidbox(object)
    local prototype_name
    if iprototype.is_pipe(object.prototype_name) then
        prototype_name = ipipe_connector.covers(object.prototype_name, object.dir)
    else
        prototype_name = object.prototype_name
    end
    return ifluid:get_fluidbox(prototype_name, object.x, object.y, object.dir, object.fluid_name)
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

local function _debug_fluid_name(object)
    print(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)
end

local function state_end(self, datamodel, from_x, from_y, to_x, to_y)
    local function _clone_item(item)
        local new = {}
        new.prototype = item.prototype
        new.count = item.count
        return new
    end
    local item_typeobject = iprototype.queryByName("item", ipipe_connector.covers(self.prototype_name, DEFAULT_DIR))
    local item = construct_inventory:modify({"TEMPORARY", "CONFIRM"}, item_typeobject.id, _clone_item) -- TODO: define cache name as constant
    if not item then -- TODO: clean up the builder?
        if _VASTSTARS_DEBUG_INFINITE_ITEM then
            item = {prototype = item_typeobject.id, count = 999}
        else
            self:clean(datamodel)
            return
        end
    end

    local dir, delta = iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local succ, to_x, to_y = terrain:move_coord(from_x, from_y, dir,
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
        fluid_name = "",
        fluidflow_ids = {},
    }

    local x, y = from_x, from_y
    while true do
        coord = packcoord(x, y)
        item.count = item.count - 1

        if x == from_x and y == from_y then
            local _object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
            if _object then
                if iprototype.is_pipe(_object.prototype_name) then
                    local pipe_edge = _set_pipe(State, x, y)
                    pipe_edge = set_shape_edge(pipe_edge, dir_num, true)
                    map[coord] = pipe_edge

                elseif iprototype.is_pipe_to_ground(_object.prototype_name) then
                    for _, v in ipairs(ifluid:get_fluidbox(_object.prototype_name, _object.x, _object.y, _object.dir, _object.fluid_name)) do
                        if v.ground and v.dir == iprototype.reverse_dir(dir) then
                            _update_fluid_name(State, _object.fluid_name, _object.fluidflow_id)
                            break -- pipe to ground only has one fluidbox in one direction
                        end
                    end
                    map[coord] = 0

                else
                    -- entity is not a pipe or a pipe to ground, (from_x, from_y) is the fluidbox coord of the entity
                    -- find the fluidbox of the entity equal to (from_x, from_y) -- TODO: optimize
                    local fb = _match_fluidbox(ifluid:get_fluidbox(_object.prototype_name, _object.x, _object.y, _object.dir, _object.fluid_name), from_x, from_y, dir)
                    if not fb then -- no fluidbox in the direction of the entity
                        State.failed = true
                    else
                        _update_fluid_name(State, fb.fluid_name, _object.fluidflow_id)
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
                    pipe_edge = set_shape_edge(pipe_edge, reverse_dir_num, true)
                    map[coord] = pipe_edge

                elseif iprototype.is_pipe_to_ground(_object.prototype_name) then
                    local found = false
                    for _, v in ipairs(ifluid:get_fluidbox(_object.prototype_name, _object.x, _object.y, _object.dir, _object.fluid_name)) do
                        if v.ground and v.dir == dir then
                            _update_fluid_name(State, v.fluid_name, _object.fluidflow_id)
                            found = true
                            break -- pipe to ground only has one fluidbox in one direction
                        end
                    end
                    if not found then
                        State.failed = true
                    end
                    map[coord] = 0

                else
                    local found = false
                    for _, v in ipairs(ifluid:get_fluidbox(_object.prototype_name, _object.x, _object.y, _object.dir, _object.fluid_name)) do
                        if v.dir == iprototype.reverse_dir(dir) and (from_x == v.x or from_y == v.y) then
                            _update_fluid_name(State, v.fluid_name, _object.fluidflow_id)
                            found = true
                            break -- only one fluidbox aligned with the start point
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

    iui.update("construct.rml", "update_construct_inventory")

    local fluidflow_id = 0
    if not State.failed then -- TODO: when there are multiple fluidflow id, we should merge them
        global.fluidflow_id = global.fluidflow_id + 1
        fluidflow_id = global.fluidflow_id
    end
    local object_state = State.failed and "invalid_construct" or "construct"
    self.coord_indicator.state = object_state

    for coord, state in pairs(map) do
        local x, y = unpackcoord(coord)
        local shape, dir = iflow_shape.to_type_dir(state)
        local object = objects:coord(x, y, EDITOR_CACHE_TEMPORARY)
        if object then
            if iprototype.is_pipe(object.prototype_name) then
                local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
                _object.prototype_name = iflow_shape.to_prototype_name(prototype_name, shape)
                _object.dir = dir
                _object.state = object_state
                objects:set(_object, EDITOR_CACHE_TEMPORARY[1])
            elseif iprototype.is_pipe_to_ground(object.prototype_name) then
                local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
                _object.prototype_name = iflow_shape.to_prototype_name(object.prototype_name, "JI")
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
                fluid_name = State.fluid_name,
                fluidflow_id = fluidflow_id,
                state = object_state,
            }
            objects:set(object, EDITOR_CACHE_TEMPORARY[1])
            _debug_fluid_name(object) -- TODO: remove this line
        end
    end

    for fluidflow_id in pairs(State.fluidflow_ids) do
        for _, object in objects:selectall("fluidflow_id", fluidflow_id, EDITOR_CACHE_TEMPORARY) do
            local _object = objects:modify(object.x, object.y, EDITOR_CACHE_TEMPORARY, iobject.clone)
            assert(iprototype.has_type(iprototype.queryByName("entity", _object.prototype_name).type, "fluidbox"))
            _object.fluid_name = State.fluid_name
            _object.fluidflow_id = fluidflow_id
            _debug_fluid_name(_object) -- TODO: remove this line
        end
    end

    datamodel.show_laying_pipe_confirm = not State.failed
end

local function state_init(self, datamodel)
    local coord_indicator = self.coord_indicator

    local function show_indicator(prototype_name, object)
        local succ, dx, dy, obj, _prototype_name, _dir
        for _, fb in ipairs(_get_covers_fluidbox(object)) do
            succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
            if succ then
                obj = objects:coord(dx, dy, EDITOR_CACHE_TEMPORARY)
                if not obj then
                    _prototype_name, _dir = ipipe_connector.set_connection(prototype_name, DEFAULT_DIR, iprototype.reverse_dir(fb.dir), true) -- TODO: why DEFAULT_DIR?
                    obj = iobject.new {
                        prototype_name = _prototype_name,
                        dir = _dir,
                        x = dx,
                        y = dy,
                        fluid_name = "",
                        fluidflow_id = "",
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
        return #_get_covers_fluidbox(object) > 0
    end

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_laying_pipe_begin = true
        coord_indicator.state = "construct"

        local object = objects:coord(coord_indicator.x, coord_indicator.y, EDITOR_CACHE_TEMPORARY)
        if object then
            show_indicator(self.prototype_name, object)
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
        local fluidboxes = _get_covers_fluidbox(starting_object)
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
                if v.dir == iprototype.reverse_dir(dir) and (from_x == v.x or from_y == v.y) then
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
                    if v.dir == iprototype.reverse_dir(dir) and (from_x == v.x or from_y == v.y) then
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
    if not _VASTSTARS_DEBUG_INFINITE_ITEM then
        -- check if item is in the inventory
        local item_typeobject = iprototype.queryByName("item", typeobject.name)
        local item = construct_inventory:get({"TEMPORARY", "CONFIRM"}, item_typeobject.id)
        if not item or item.count <= 0 then
            log.error("Lack of item: " .. typeobject.name)
            return
        end
    end

    iobject.remove(self.coord_indicator)
    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir)
    self.prototype_name = ipipe_connector.cleanup(typeobject.name, dir)
    self.coord_indicator = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        fluid_name = "",
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
    construct_inventory:clear({"TEMPORARY"})

    if self.state ~= STATE_START then
        state_init(self, datamodel)
    else
        state_start(self, datamodel)
    end
end

local function complete(self, datamodel)
    local gameplay_world = gameplay_core.get_world()
    local e = iworld:get_headquater_entity(gameplay_world)
    if not e then
        log.error("can not find headquater entity")
        return
    end

    local failed = false
    for _, item in construct_inventory:all("TEMPORARY") do
        local old_item = assert(construct_inventory:get({"CONFIRM"}, item.prototype))
        assert(old_item.count >= item.count)
        local decrease = old_item.count - item.count
        print(iprototype.queryById(item.prototype).name, decrease)
        if not gameplay_world:container_pickup(e.chest.container, item.prototype, decrease) then
            log.error("can not pickup item", iprototype.queryById(item.prototype).name, decrease)
            failed = true
        end
    end
    if failed then
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

    state_start(self, datamodel)
end

local function laying_pipe_cancel(self, datamodel)
    construct_inventory:clear({"TEMPORARY"})
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