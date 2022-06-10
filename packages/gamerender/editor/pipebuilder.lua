local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local create_builder = ecs.require "editor.builder"
local DEFAULT_DIR <const> = 'N'
local terrain = ecs.require "terrain"
local camera = ecs.require "engine.camera"
local ifluid = require "gameplay.interface.fluid"
local math_abs = math.abs
local global = require "global"
local objects = require "objects"
local ieditor = ecs.require "editor.editor"
local ALL_DIR <const> = require("gameplay.interface.constant").ALL_DIR
local flow_shape = require "gameplay.utility.flow_shape"
local INDICATOR_CACHE_NAMES = {"INDICATOR", "TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local iobject = ecs.require "object"

local function get_distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

local function calc_dir(x1, y1, x2, y2)
    local dx = math_abs(x1 - x2)
    local dy = math_abs(y1 - y2)
    if dx > dy then
        if x1 < x2 then
            return "E"
        else
            return "W"
        end
    else
        if y1 < y2 then
            return "S"
        else
            return "N"
        end
    end
end

local function shift_pipe_prototype_name(prototype_name)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    if not typeobject.pipe then
        return prototype_name
    end
    return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format("X"))
end

local function get_starting_fluidbox_coord(starting_x, starting_y, x, y)
    local object = objects:coord(starting_x, starting_y, EDITOR_CACHE_NAMES)
    if not object then
        return starting_x, starting_y, "", 0, calc_dir(starting_x, starting_y, x, y)
    end

    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    if typeobject.pipe then
        return starting_x, starting_y, object.fluid_name, object.fluidflow_network_id, calc_dir(starting_x, starting_y, x, y)
    end

    local r
    for _, v in ipairs(ifluid:get_fluidbox(shift_pipe_prototype_name(object.prototype_name), object.x, object.y, object.dir, object.fluid_name)) do
        r = r or v
        if get_distance(r.x, r.y, x, y) > get_distance(v.x, v.y, x, y) then
            r = v
        end
    end
    return r.x, r.y, r.fluid_name, object.fluidflow_network_id, r.dir
end

local dir_vector = {
    N = {x = 0,  y = -1},
    S = {x = 0,  y = 1},
    W = {x = -1, y = 0},
    E = {x = 1,  y = 0},
}

local function get_ending_fluidbox_coord(starting_x, starting_y, starting_fluid_name, starting_fluidflow_network_id, starting_dir, x, y)
    local dx = math_abs(starting_x - x)
    local dy = math_abs(starting_y - y)
    x, y = ieditor:get_dir_coord(starting_x, starting_y, starting_dir, dx, dy)

    local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    if not object then
        return true, x, y, starting_fluid_name, starting_fluidflow_network_id
    end

    local r
    for _, v in ipairs(ifluid:get_fluidbox(shift_pipe_prototype_name(object.prototype_name), object.x, object.y, object.dir, object.fluid_name)) do
        local dx = math_abs(starting_x - v.x)
        local dy = math_abs(starting_y - v.y)
        local vec = assert(dir_vector[v.dir])
        if starting_x == v.x + vec.x * dx and starting_y == v.y + vec.y * dy then
            r = v
        end
    end

    if not r then
        return false, x, y, "", object.fluidflow_network_id
    end

    if starting_fluid_name ~= "" and r.fluid_name ~= "" and r.fluid_name ~= starting_fluid_name then
        return false, x, y, r.fluid_name, object.fluidflow_network_id
    end

    return true, r.x, r.y, r.fluid_name, object.fluidflow_network_id
end

local function show_starting_indicator(starting_x, starting_y, starting_fluid_name, starting_fluidflow_network_id, starting_dir, prototype_name, x, y)
    ieditor:revert_changes({"INDICATOR"})

    local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    if not object then
        return
    end
    objects:set(object, "INDICATOR")

    for _, v in ipairs(ifluid:get_fluidbox(shift_pipe_prototype_name(object.prototype_name), object.x, object.y, object.dir, object.fluid_name)) do
        local px, py = ieditor:get_dir_coord(v.x, v.y, v.dir)
        if get_ending_fluidbox_coord(starting_x, starting_y, starting_fluid_name, starting_fluidflow_network_id, starting_dir, px, py) then
            local indicator_object = iobject.new {
                prototype_name = flow_shape:get_init_prototype_name(prototype_name),
                dir = v.dir,
                x = px,
                y = py,
                fluid_name = "",
                fluidflow_network_id = 0,
                state = "indicator",
            }
            objects:set(indicator_object, "INDICATOR")
            ieditor:refresh_flow_shape({"INDICATOR"}, "INDICATOR", indicator_object, iprototype.opposite_dir(v.dir), px, py)
        end
    end
end

local function is_valid_starting(x, y)
    local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
    if not object then
        return true
    end

    local t = ifluid:get_fluidbox(shift_pipe_prototype_name(object.prototype_name), object.x, object.y, object.dir, object.fluid_name)
    return #t > 0
end

local function prepare_starting(self, datamodel)
    local coord_indicator = self.coord_indicator

    if is_valid_starting(coord_indicator.x, coord_indicator.y) then
        datamodel.show_laying_pipe_begin = true
        coord_indicator.state = "construct"

        local object = objects:coord(coord_indicator.x, coord_indicator.y, EDITOR_CACHE_NAMES)
        if object then
            local starting_fluidbox_x, starting_fluidbox_y, starting_fluid_name, starting_fluidflow_network_id, starting_dir = get_starting_fluidbox_coord(coord_indicator.x, coord_indicator.y, coord_indicator.x, coord_indicator.y)
            show_starting_indicator(starting_fluidbox_x, starting_fluidbox_y, starting_fluid_name, starting_fluidflow_network_id, starting_dir, self.prototype_name, object.x, object.y)
        end
    else
        datamodel.show_laying_pipe_begin = false
        coord_indicator.state = "invalid_construct"
    end
end

-- FLUIDTODO
local function show_pipe_indicator(cache_names_r, cache_name_w, prototype_name, starting_x, starting_y, starting_dir, ending_x, ending_y, vsobject_type, fluid_name, fluidflow_network_id)
    local step_x
    if starting_x > ending_x then
        step_x = -1
    else
        step_x = 1
    end

    local step_y
    if starting_y > ending_y then
        step_y = -1
    else
        step_y = 1
    end

    local refresh = false -- todo
    for x = starting_x, ending_x, step_x do -- todo
        for y = starting_y, ending_y, step_y do
            local object = objects:coord(x, y, cache_names_r)
            if not object then
                object = iobject.new {
                    prototype_name = flow_shape:get_init_prototype_name(prototype_name),
                    dir = DEFAULT_DIR,
                    x = x,
                    y = y,
                    fluid_name = fluid_name,
                    fluidflow_network_id = fluidflow_network_id,
                    state = vsobject_type,
                }
                objects:set(object, cache_name_w)
            else
                if object.fluidflow_network_id ~= 0 then
                    for _, object in objects:selectall("fluidflow_network_id", object.fluidflow_network_id, cache_names_r) do
                        local o = iobject.clone(object)
                        o.fluidflow_network_id = fluidflow_network_id
                        o.fluid_name = fluid_name
                        objects:set(o, cache_name_w)
                    end
                end
            end

            if refresh then
                ieditor:refresh_flow_shape(cache_names_r, cache_name_w, object, iprototype.opposite_dir(starting_dir), x, y)
            end
            refresh = true
        end
    end
end

-- TODO
local function has_object(starting_coord_x, starting_coord_y, cur_x, cur_y, starting_fluid_name)
    local dx = math_abs(starting_coord_x - cur_x)
    local dy = math_abs(starting_coord_y - cur_y)
    local step

    local find_id = {}
    local starting_object = objects:coord(starting_coord_x, starting_coord_y, EDITOR_CACHE_NAMES)
    if starting_object then
        find_id[starting_object.id] = true
    end
    local ending_object = objects:coord(cur_x, cur_y, EDITOR_CACHE_NAMES)
    if ending_object then
        find_id[ending_object.id] = true
    end

    if dx >= dy then
        if starting_coord_x <= cur_x then
            step = 1
        else
            step = -1
        end

        for vx = starting_coord_x + step, cur_x, step do
            local object = objects:coord(vx, starting_coord_y, EDITOR_CACHE_NAMES)
            if object and not find_id[object.id] then
                local typeobject = iprototype.queryByName("entity", object.prototype_name)
                if not typeobject.pipe then
                    return true
                end
                if object.fluid_name ~= "" and starting_fluid_name ~= "" and object.fluid_name ~= starting_fluid_name then
                    return true
                end
            end
        end
        return false
    else
        if starting_coord_y <= cur_y then
            step = 1
        else
            step = -1
        end

        for vy = starting_coord_y, cur_y, step do
            local object = objects:coord(starting_coord_x, vy, EDITOR_CACHE_NAMES)
            if object and not find_id[object.id] then
                local typeobject = iprototype.queryByName("entity", object.prototype_name)
                if not typeobject.pipe then
                    return true
                end
                if object.fluid_name ~= "" and object.fluid_name ~= starting_fluid_name then
                    return true
                end
            end
        end
        return false
    end
end

-- TODO
local function is_pipe(object)
    if not object then
        return true
    end

    return iprototype.is_pipe(object.prototype_name)
end

local function start(self, datamodel)
    local coord_indicator = self.coord_indicator
    local starting_fluidbox_x, starting_fluidbox_y, starting_fluid_name, starting_fluidflow_network_id, starting_dir = get_starting_fluidbox_coord(self.starting_coord.x, self.starting_coord.y, coord_indicator.x, coord_indicator.y)
    local success, ending_fluidbox_x, ending_fluidbox_y, ending_fluid_name, ending_fluidflow_network_id = get_ending_fluidbox_coord(starting_fluidbox_x, starting_fluidbox_y, starting_fluid_name, starting_fluidflow_network_id, starting_dir, coord_indicator.x, coord_indicator.y)
    if not success then
        datamodel.show_laying_pipe_confirm = false
        datamodel.show_laying_pipe_cancel = false
        show_pipe_indicator(INDICATOR_CACHE_NAMES, "INDICATOR", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "invalid_construct", "", 0)
        return
    end

    if has_object(starting_fluidbox_x, starting_fluidbox_y, ending_fluidbox_x, ending_fluidbox_y, starting_fluid_name) then
        datamodel.show_laying_pipe_confirm = false
        datamodel.show_laying_pipe_cancel = false
        show_pipe_indicator(INDICATOR_CACHE_NAMES, "INDICATOR", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "invalid_construct", "", 0)
        return
    end

    local starting_object = objects:coord(starting_fluidbox_x, starting_fluidbox_y, EDITOR_CACHE_NAMES)
    local ending_object = objects:coord(ending_fluidbox_x, ending_fluidbox_y, EDITOR_CACHE_NAMES)

    -- the case where there is no building at one of the starting and ending points
    if not starting_object or not ending_object then
        datamodel.show_laying_pipe_confirm = true
        datamodel.show_laying_pipe_cancel = true
        local object, fluid_name
        if starting_object then
            object = starting_object
            fluid_name = starting_fluid_name
        else
            object = starting_object or ending_object
            fluid_name = ending_fluid_name
        end

        local fluidflow_network_id
        if object then
            if not is_pipe(object) and fluid_name == "" then
                global.fluidflow_network_id = global.fluidflow_network_id + 1
                fluidflow_network_id = global.fluidflow_network_id
            else
                fluidflow_network_id = object.fluidflow_network_id
            end
        else
            global.fluidflow_network_id = global.fluidflow_network_id + 1
            fluid_name = ""
            fluidflow_network_id = global.fluidflow_network_id
        end
        show_pipe_indicator(EDITOR_CACHE_NAMES, "TEMPORARY", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "construct", fluid_name, fluidflow_network_id)
        return
    end

    if starting_object.id == ending_object.id then
        datamodel.show_laying_pipe_confirm = false
        datamodel.show_laying_pipe_cancel = false
        show_pipe_indicator(INDICATOR_CACHE_NAMES, "INDICATOR", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "invalid_construct", "", 0)
        return
    end

    -- the start point and end point are not pipes and adjacent buildings
    if not is_pipe(starting_object) and not is_pipe(ending_object) then
        for _, dir in ipairs(ALL_DIR) do
            local x, y = ieditor:get_dir_coord(starting_fluidbox_x, starting_fluidbox_y, dir)
            if x == ending_fluidbox_x and y == ending_fluidbox_y then
                datamodel.show_laying_pipe_confirm = false
                datamodel.show_laying_pipe_cancel = false
                show_pipe_indicator(INDICATOR_CACHE_NAMES, "INDICATOR", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "invalid_construct", "", 0)
                return
            end
        end
    end

    datamodel.show_laying_pipe_confirm = true
    datamodel.show_laying_pipe_cancel = true

    local fluid_name, fluidflow_network_id
    if starting_fluidflow_network_id ~= 0 or ending_fluidflow_network_id ~= 0 then
        local objecta, objectb
        if starting_fluidflow_network_id == 0 then
            objecta, objectb = starting_object, ending_object
            fluid_name = starting_fluid_name
        else
            objecta, objectb = ending_object, starting_object
            fluid_name = ending_fluid_name
        end
        local typeobject = iprototype.queryByName("entity", objecta.prototype_name)
        if iprototype.has_type(typeobject.type, "fluidbox") then
            for _, object in objects:selectall("fluidflow_network_id", objectb.fluidflow_network_id, EDITOR_CACHE_NAMES) do
                local o = iobject.clone(object)
                o.fluidflow_network_id = objecta.fluidflow_network_id
                o.fluid_name = fluid_name
                objects:set(o, "TEMPORARY")
            end
        else
            assert(iprototype.has_type(typeobject.type, "fluidboxes"))
        end
        fluid_name, fluidflow_network_id = fluid_name, objecta.fluidflow_network_id
    else
        fluid_name, fluidflow_network_id = starting_fluid_name, 0
    end

    show_pipe_indicator(EDITOR_CACHE_NAMES, "TEMPORARY", coord_indicator.prototype_name, starting_fluidbox_x, starting_fluidbox_y, starting_dir, ending_fluidbox_x, ending_fluidbox_y, "construct", fluid_name, fluidflow_network_id)
end

--------------------------------------------------------------------------------------------------
local function new_entity(self, datamodel, typeobject)
    iobject.remove(self.coord_indicator)

    local dir = DEFAULT_DIR
    local x, y = iobject.central_coord(typeobject.name, dir)
    self.prototype_name = typeobject.name
    self.coord_indicator = iobject.new {
        prototype_name = typeobject.name,
        dir = DEFAULT_DIR,
        x = x,
        y = y,
        fluid_name = "",
        fluidflow_network_id = 0,
        state = "construct"
    }

    --
    prepare_starting(self, datamodel)
end

local function touch_move(self, datamodel, delta_vec)
    iobject.move_delta(self.coord_indicator, delta_vec)
end

local function touch_end(self, datamodel)
    local coord_indicator = assert(self.coord_indicator)
    local coord = terrain.adjust_position(camera.get_central_position(), 1, 1) -- 1, 1 水管 / 路块的 width & height
    if not coord then
        return
    end
    coord_indicator.x, coord_indicator.y = coord[1], coord[2]

    --
    ieditor:revert_changes({"INDICATOR", "TEMPORARY"})

    if not self.starting_coord then
        prepare_starting(self, datamodel)
        return
    end

    start(self, datamodel)
end

local function complete(self, datamodel)
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
    assert(self.starting_coord == nil)
    local coord_indicator = assert(self.coord_indicator)
    self.starting_coord = {x = coord_indicator.x, y = coord_indicator.y}

    --
    datamodel.show_laying_pipe_begin = false
    start(self, datamodel)
end

local function laying_pipe_cancel(self, datamodel)
    self:revert_changes({"INDICATOR", "TEMPORARY"})
    local typeobject = iprototype.queryByName("entity", self.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.starting_coord = nil
    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = false
    datamodel.show_construct_complete = true
end

local function laying_pipe_confirm(self, datamodel)
    for _, object in objects:all("TEMPORARY") do
        object.state = "confirm"
    end
    objects:commit("TEMPORARY", "CONFIRM")

    local typeobject = iprototype.queryByName("entity", self.prototype_name)
    self:new_entity(datamodel, typeobject)

    self.starting_coord = nil
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
    -- M.starting_coord = {x = xx, y = xx}
    M.laying_pipe_begin = laying_pipe_begin
    M.laying_pipe_cancel = laying_pipe_cancel
    M.laying_pipe_confirm = laying_pipe_confirm
    return M
end
return create