local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local ifluid = require "gameplay.interface.fluid"

local format_prototype_name = ecs.require "editor.pipe-to-ground.util".format_prototype_name
local get_ground = ecs.require "editor.pipe-to-ground.util".get_ground
local flow_shape = require "gameplay.utility.flow_shape"
local state_end = ecs.require "editor.pipe-to-ground.state_end"
local show_failed = ecs.require "editor.pipe-to-ground.util".show_failed
local iobject = ecs.require "object"
local is_overlap = ecs.require "editor.pipe-to-ground.util".is_overlap
local show_indicator = ecs.require "editor.pipe-to-ground.util".show_indicator

local EDITOR_CACHE_CONSTRUCTED = {"CONFIRM", "CONSTRUCTED"}
local EDITOR_CACHE_TEMPORARY   = {"TEMPORARY"}

local condition_pipe, condition_pipe_to_ground, condition_normal, condition_none

function condition_pipe(self, datamodel)
    local from_x, from_y = self.from_x, self.from_y
    local to_x, to_y = self.coord_indicator.x, self.coord_indicator.y
    local dir = iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local ground = get_ground(self.coord_indicator.prototype_name) - 1

    local succ
    succ, to_x, to_y = iprototype.move_coord(from_x, from_y, dir,
        math.min(math.abs(from_x - to_x), ground),
        math.min(math.abs(from_y - to_y), ground)
    )

    local starting_object = assert(objects:coord(from_x, from_y, EDITOR_CACHE_CONSTRUCTED))
    assert(iprototype.is_pipe(starting_object.prototype_name))

    local t = {
        [dir] = true,
        [iprototype.opposite_dir(dir)] = true,
    }
    for _, v in ipairs(ifluid:get_fluidbox(starting_object.prototype_name, starting_object.x, starting_object.y, starting_object.dir)) do
        if not t[v.dir] then
            show_failed(self, datamodel, from_x, from_y, dir, to_x, to_y)
            return
        end
    end

    if not succ then
        show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
        return
    end

    local shape
    if flow_shape:get_state(starting_object.prototype_name, starting_object.dir, iprototype.opposite_dir(dir)) then
        shape = "JI"
    else
        shape = "JU"
    end

    starting_object = iobject.clone(starting_object)
    starting_object.dir = dir
    starting_object.prototype_name = format_prototype_name(self.coord_indicator.prototype_name, shape)
    starting_object.fluid_name = starting_object.fluid_name
    starting_object.fluidflow_network_id = starting_object.fluidflow_network_id
    starting_object.state = "construct"
    objects:set(starting_object, EDITOR_CACHE_TEMPORARY[1])

    state_end(self, datamodel, starting_object, to_x, to_y, dir)
end

function condition_pipe_to_ground(self, datamodel)
    local from_x, from_y = self.from_x, self.from_y
    local to_x, to_y = self.coord_indicator.x, self.coord_indicator.y
    local starting_object = assert(objects:coord(from_x, from_y, EDITOR_CACHE_CONSTRUCTED))
    assert(iprototype.is_pipe_to_ground(starting_object.prototype_name))
    local ground = get_ground(self.coord_indicator.prototype_name) - 1

    local dir = iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local t = {
        [dir] = true,
        [iprototype.opposite_dir(dir)] = true,
    }
    for _, v in ipairs(ifluid:get_fluidbox(starting_object.prototype_name, starting_object.x, starting_object.y, starting_object.dir)) do
        if not t[v.dir] then
            local succ
            succ, to_x, to_y = iprototype.move_coord(starting_object.x, starting_object.y, dir, math.min(math.abs(starting_object.x - to_x), ground), math.min(math.abs(starting_object.y - to_y), ground))
            show_failed(self, datamodel, starting_object.x, starting_object.y, dir, to_x, to_y)
            return
        end
    end

    local succ
    succ, to_x, to_y = iprototype.move_coord(from_x, from_y, dir,
        math.min(math.abs(from_x - to_x), ground),
        math.min(math.abs(from_y - to_y), ground)
    )
    if not succ then
        local succ
        succ, to_x, to_y = iprototype.move_coord(starting_object.x, starting_object.y, dir, math.min(math.abs(starting_object.x - to_x), ground), math.min(math.abs(starting_object.y - to_y), ground))
        show_failed(self, datamodel, starting_object.x, starting_object.y, dir, to_x, to_y)
        return
    end

    starting_object = iobject.clone(starting_object)
    starting_object.state = "construct"
    objects:set(starting_object, EDITOR_CACHE_TEMPORARY[1])

    state_end(self, datamodel, starting_object, to_x, to_y)
end

function condition_normal(self, datamodel)
    local from_x, from_y = self.from_x, self.from_y
    local to_x, to_y = self.coord_indicator.x, self.coord_indicator.y
    local starting_object = assert(objects:coord(from_x, from_y, EDITOR_CACHE_CONSTRUCTED))

    if is_overlap(from_x, from_y, to_x, to_y) then
        show_indicator(self.coord_indicator.prototype_name, starting_object)
        return
    end


    local function get_fluidbox(x, y, dir, object)
        local r = {}
        for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
            if dir == v.dir then
                r[#r+1] = v
            end
        end
        local function get_distance(x1, y1, x2, y2)
            return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
        end
        table.sort(r, function(a, b)
           return get_distance(a.x, a.y, x, y) < get_distance(b.x, b.y, x, y)
        end)
        return r[1]
    end
    local dir = iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local fluidbox = get_fluidbox(to_x, to_y, dir, starting_object)
    if not fluidbox then
        show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
        return
    end

    local succ
    succ, from_x, from_y = iprototype.move_coord(fluidbox.x, fluidbox.y, fluidbox.dir, 1)
    if not succ then
        show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
        return
    end

    local object = objects:coord(from_x, from_y, EDITOR_CACHE_CONSTRUCTED)
    if object then
        assert(false)
        if iprototype.is_pipe(object.prototype_name) then
            condition_pipe(self, datamodel)
        elseif iprototype.is_pipe_to_ground(object.prototype_name) then
            condition_pipe_to_ground(self, datamodel)
        else
            condition_normal(self, datamodel)
        end
    else
        condition_none(self, datamodel, "JI", from_x, from_y, dir, fluidbox.fluid_name, starting_object.fluidflow_network_id)
    end
end

function condition_none(self, datamodel, shape, from_x, from_y, dir, fluid_name, fluidflow_network_id)
    from_x, from_y = from_x or self.from_x, from_y or self.from_y
    local to_x, to_y = self.coord_indicator.x, self.coord_indicator.y
    local dir = dir or iprototype.calc_dir(from_x, from_y, to_x, to_y)
    local prototype_name = format_prototype_name(self.coord_indicator.prototype_name, shape or "JU")
    local ground = get_ground(prototype_name)

    local succ
    succ, to_x, to_y = iprototype.move_coord(from_x, from_y, dir,
        math.min(math.abs(from_x - to_x), ground),
        math.min(math.abs(from_y - to_y), ground)
    )
    if not succ then
        show_failed(self, datamodel, from_x, from_y, dir, to_x, to_y)
        return
    end

    local starting_object = {
        prototype_name = format_prototype_name(self.coord_indicator.prototype_name, shape or "JU"),
        dir = dir,
        x = from_x,
        y = from_y,
        fluid_name = fluid_name or "",
        fluidflow_network_id = fluidflow_network_id or 0,
        state = "construct",
    }

    state_end(self, datamodel, starting_object, to_x, to_y)
end

return function(self, datamodel)
    local from_x, from_y = self.from_x, self.from_y
    local object = objects:coord(from_x, from_y, EDITOR_CACHE_CONSTRUCTED)
    if object then
        if iprototype.is_pipe(object.prototype_name) then
            condition_pipe(self, datamodel)
        elseif iprototype.is_pipe_to_ground(object.prototype_name) then
            condition_pipe_to_ground(self, datamodel)
        else
            condition_normal(self, datamodel)
        end
    else
        condition_none(self, datamodel)
    end
end