local ecs = ...
local world = ecs.world
local w = world.w

local math_abs = math.abs
local iprototype = require "gameplay.interface.prototype"
local terrain = ecs.require "terrain"
local objects = require "objects"
local EDITOR_CACHE_CONSTRUCTED = {"CONFIRM", "CONSTRUCTED"}
local EDITOR_CACHE_TEMPORARY   = {"TEMPORARY", "INDICATOR"}
local iobject = ecs.require "object"
local ifluid = require "gameplay.interface.fluid"

local M = {}

function M.show_dotted_line(self, from_x, from_y, dir, to_x, to_y)
    local succ
    succ, from_x, from_y = terrain:move_coord(from_x, from_y, dir, 1)
    if not succ then
        return
    end

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

    local position = terrain:get_position_by_coord(from_x, from_y, 1, 1)
    self.dotted_line:update(position, quad_num, dir)
    self.dotted_line:show(true)
end

function M.show_failed(self, datamodel, from_x, from_y, dir, to_x, to_y)
    local prototype_name = M.format_prototype_name(self.coord_indicator.prototype_name, "JU")

    local object
    object = iobject.new {
        prototype_name = prototype_name,
        dir = dir,
        x = from_x,
        y = from_y,
        fluid_name = "",
        state = "invalid_construct",
    }
    objects:set(object, EDITOR_CACHE_TEMPORARY[1])

    object = iobject.new {
        prototype_name = prototype_name,
        dir = iprototype.reverse_dir(dir),
        x = to_x,
        y = to_y,
        fluid_name = "",
        state = "construct",
    }
    objects:set(object, EDITOR_CACHE_TEMPORARY[1])

    M.show_dotted_line(self, from_x, from_y, dir, to_x, to_y)

    datamodel.show_laying_pipe_confirm = false
    datamodel.show_laying_pipe_cancel = true
    self.coord_indicator.state = "construct"
end

function M.format_prototype_name(prototype_name, shape)
    assert(prototype_name:match("(.*%-)(J%u)(.*)"))
    return prototype_name:gsub("(.*%-)(J%u)(.*)", ("%%1%s%%3"):format(shape))
end

function M.get_ground(prototype_name)
    local typeobject = assert(iprototype.queryByName("entity", prototype_name))
    assert(typeobject.fluidbox)
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        if connection.ground then
            return connection.ground
        end
    end
    assert(false)
end

function M.is_overlap(from_x, from_y, to_x, to_y)
    local from_object = objects:coord(from_x, from_y, EDITOR_CACHE_CONSTRUCTED)
    if from_object then
        local to_object = objects:coord(to_x, to_y, EDITOR_CACHE_CONSTRUCTED)
        if not to_object then
            return false
        end
        return from_object.id == to_object.id
    end

    return from_x == to_x and from_y == to_y
end

function M.show_indicator(prototype_name, object)
    local succ, dx, dy, obj
    for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
        succ, dx, dy = terrain:move_coord(v.x, v.y, v.dir, 1)
        if succ then
            obj = objects:coord(dx, dy, EDITOR_CACHE_CONSTRUCTED)
            if not obj then
                obj = iobject.new {
                    prototype_name = prototype_name,
                    dir = v.dir,
                    x = dx,
                    y = dy,
                    fluid_name = "",
                    fluidflow_id = "",
                    state = "indicator",
                }
                objects:set(obj, EDITOR_CACHE_TEMPORARY[2])
            end
        end
    end
end

return M