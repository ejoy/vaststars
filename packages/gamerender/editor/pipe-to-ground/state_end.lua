local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iobject = ecs.require "object"
local global = require "global"
local terrain = ecs.require "terrain"

local format_prototype_name = ecs.require "editor.pipe-to-ground.util".format_prototype_name
local show_dotted_line = ecs.require "editor.pipe-to-ground.util".show_dotted_line
local is_overlap = ecs.require "editor.pipe-to-ground.util".is_overlap
local show_failed = ecs.require "editor.pipe-to-ground.util".show_failed
local ifluid = require "gameplay.interface.fluid"
local flow_shape = require "gameplay.utility.flow_shape"

local EDITOR_CACHE_CONSTRUCTED = {"CONFIRM", "CONSTRUCTED"}
local EDITOR_CACHE_TEMPORARY   = {"TEMPORARY"}
local condition_pipe, condition_pipe_to_ground, condition_normal, condition_none

local function check_channel(self, datamodel, starting_object, to_x, to_y)
    local succ
    local x, y = starting_object.x, starting_object.y
    while true do
        succ, x, y = terrain:move_coord(x, y, starting_object.dir, 1)
        if not succ then
            show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
            return false
        end
        if x == to_x and y == to_y then
            break
        end

        local object = objects:coord(x, y, EDITOR_CACHE_CONSTRUCTED)
        if object then
            local typeobject = iprototype.queryByName("entity", object.prototype_name)
            if typeobject.pipe_to_ground then
                show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
                return false
            end
        end
    end
    return true
end

function condition_pipe(self, datamodel, starting_object, to_x, to_y, dir, max_to_x, max_to_y)
    dir = dir or starting_object.dir -- TODO
    local ending_object = assert(objects:coord(to_x, to_y, EDITOR_CACHE_CONSTRUCTED))

    if ending_object.fluid_name ~= "" then
        if starting_object.fluid_name ~= "" then
            if ending_object.fluid_name ~= starting_object.fluid_name then
                show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
                return
            end
        else
            starting_object.fluid_name = ending_object.fluid_name
            starting_object.fluidflow_id = 0
        end
    end

    local t = {
        [starting_object.dir] = true,
        [iprototype.reverse_dir(starting_object.dir)] = true,
    }
    for _, v in ipairs(ifluid:get_fluidbox(ending_object.prototype_name, ending_object.x, ending_object.y, ending_object.dir)) do
        if not t[v.dir] then
            show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
            return
        end
    end

    local succ
    local replace_pipe = true
    local x, y = starting_object.x, starting_object.y
    local pipe = {}
    while true do
        succ, x, y = terrain:move_coord(x, y, dir, 1)
        if not succ then
            show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
            return false
        end

        local object = objects:coord(x, y, EDITOR_CACHE_CONSTRUCTED)
        if object then
            local typeobject = iprototype.queryByName("entity", object.prototype_name)
            if typeobject.pipe_to_ground then
                show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
                return false
            end

            if typeobject.pipe then
                for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
                    if not t[v.dir] then
                        replace_pipe = false
                    end
                end

                pipe[#pipe+1] = object
            else
                replace_pipe = false
            end
        else
            replace_pipe = false
            break
        end

        if x == to_x and y == to_y then
            break
        end
    end

    if replace_pipe then
        for _, object in ipairs(pipe) do
            local clone = iobject.clone(object)
            iobject.remove(clone)
            objects:set(clone, EDITOR_CACHE_TEMPORARY[1])
        end

        --
        local prototype_name, typeobject, object
        typeobject = iprototype.queryByName("entity", starting_object.prototype_name)
        object = iobject.clone(starting_object)
        object.prototype_name = typeobject.name
        object.dir = starting_object.dir
        objects:set(object, EDITOR_CACHE_TEMPORARY[1])

        --
        local shape
        if flow_shape.get_state(ending_object.prototype_name, ending_object.dir, iprototype.reverse_dir(starting_object.dir)) then
            shape = "JI"
        else
            shape = "JU"
        end
        prototype_name = format_prototype_name(self.coord_indicator.prototype_name, shape)
        typeobject = iprototype.queryByName("entity", prototype_name)
        object = iobject.new {
            prototype_name = typeobject.name,
            dir = iprototype.reverse_dir(starting_object.dir),
            x = to_x,
            y = to_y,
            fluid_name = starting_object.fluid_name,
            fluidflow_id = starting_object.fluidflow_id,
            state = "construct",
        }
        objects:set(object, EDITOR_CACHE_TEMPORARY[1])

        show_dotted_line(self, starting_object.x, starting_object.y, dir, to_x, to_y)

        datamodel.show_laying_pipe_confirm = true
        datamodel.show_laying_pipe_cancel = true
        self.coord_indicator.state = "construct"
    else
        local prototype_name, typeobject, object

        typeobject = iprototype.queryByName("entity", starting_object.prototype_name)
        object = iobject.new {
            prototype_name = typeobject.name,
            dir = starting_object.dir,
            x = starting_object.x,
            y = starting_object.y,
            fluid_name = starting_object.fluid_name,
            fluidflow_id = starting_object.fluidflow_id,
            state = "construct",
        }
        objects:set(object, EDITOR_CACHE_TEMPORARY[1])

        --
        local shape
        if flow_shape.get_state(ending_object.prototype_name, ending_object.dir, iprototype.reverse_dir(starting_object.dir)) then
            shape = "JI"
        else
            shape = "JU"
        end
        prototype_name = format_prototype_name(self.coord_indicator.prototype_name, shape)
        object = iobject.clone(ending_object)
        object.prototype_name = prototype_name
        object.dir = iprototype.reverse_dir(starting_object.dir)
        object.fluid_name = starting_object.fluid_name
        object.fluidflow_id = starting_object.fluidflow_id
        objects:set(object, EDITOR_CACHE_TEMPORARY[1])

        show_dotted_line(self, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)

        datamodel.show_laying_pipe_confirm = true
        datamodel.show_laying_pipe_cancel = true
        self.coord_indicator.state = "construct"
    end
end

function condition_pipe_to_ground(self, datamodel, starting_object, to_x, to_y, max_to_x, max_to_y)
    local ending_object = assert(objects:coord(to_x, to_y, EDITOR_CACHE_CONSTRUCTED))
    if not check_channel(self, datamodel, starting_object, to_x, to_y) then
        return
    end

    if ending_object.dir ~= iprototype.reverse_dir(starting_object.dir) then
        show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
        return
    end

    if ending_object.fluid_name ~= "" then
        if starting_object.fluid_name ~= "" then
            if ending_object.fluid_name ~= starting_object.fluid_name then
                show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
                return
            end
        else
            starting_object.fluid_name = ending_object.fluid_name
            starting_object.fluidflow_id = 0
        end
    end

    local prototype_name, typeobject, object

    -- TODO
    typeobject = iprototype.queryByName("entity", starting_object.prototype_name)
    object = iobject.new {
        prototype_name = typeobject.name,
        dir = starting_object.dir,
        x = starting_object.x,
        y = starting_object.y,
        fluid_name = starting_object.fluid_name,
        fluidflow_id = starting_object.fluidflow_id,
        state = "construct",
    }
    objects:set(object, EDITOR_CACHE_TEMPORARY[1])

    --
    prototype_name = format_prototype_name(self.coord_indicator.prototype_name, flow_shape.get_shape(ending_object.prototype_name))
    typeobject = iprototype.queryByName("entity", prototype_name)
    object = iobject.new {
        prototype_name = typeobject.name,
        dir = iprototype.reverse_dir(starting_object.dir),
        x = to_x,
        y = to_y,
        fluid_name = starting_object.fluid_name,
        fluidflow_id = starting_object.fluidflow_id,
        state = "construct",
    }
    objects:set(object, EDITOR_CACHE_TEMPORARY[1])

    show_dotted_line(self, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)

    datamodel.show_laying_pipe_confirm = true
    datamodel.show_laying_pipe_cancel = true
    self.coord_indicator.state = "construct"
end

function condition_normal(self, datamodel, starting_object, to_x, to_y, max_to_x, max_to_y)
    local ending_object = assert(objects:coord(to_x, to_y, EDITOR_CACHE_CONSTRUCTED))

    local function get_fluidbox(x, y, dir, object)
        for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir, object.fluid_name)) do
            local succ, dx, dy = terrain:move_coord(x, y, dir,
                math.abs(x - v.x),
                math.abs(y - v.y)
            )
            if succ and dx == v.x and dy == v.y and v.dir == iprototype.reverse_dir(dir) then
                return v
            end
        end
    end
    local fluidbox = get_fluidbox(starting_object.x, starting_object.y, starting_object.dir, ending_object)
    if not fluidbox then
        show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
        return
    end

    if fluidbox.fluid_name ~= "" then
        if starting_object.fluid_name ~= "" then
            if fluidbox.fluid_name ~= starting_object.fluid_name then
                show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
                return
            end
        else
            starting_object.fluid_name = fluidbox.fluid_name
            starting_object.fluidflow_id = 0
        end
    else
        if starting_object.fluid_name ~= "" then
            for _, object in objects:selectall("fluidflow_id", ending_object.fluidflow_id, EDITOR_CACHE_CONSTRUCTED) do
                local o = iobject.clone(object)
                o.fluidflow_id = starting_object.fluidflow_id
                o.fluid_name = starting_object.fluid_name
                objects:set(o, EDITOR_CACHE_TEMPORARY[1])
            end
        end
    end

    local succ
    succ, to_x, to_y = terrain:move_coord(fluidbox.x, fluidbox.y, fluidbox.dir, 1)
    if not succ then
        show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
        return
    end

    local object = objects:coord(to_x, to_y, EDITOR_CACHE_CONSTRUCTED)
    if object then
        if iprototype.is_pipe(object.prototype_name) then
            condition_pipe(self, datamodel, starting_object, to_x, to_y)
        elseif iprototype.is_pipe_to_ground(object.prototype_name) then
            condition_pipe_to_ground(self, datamodel, starting_object, to_x, to_y)
        else
            show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
            return
        end
    else
        condition_none(self, datamodel, starting_object, to_x, to_y, max_to_x, max_to_y, "JI")
    end
end

function condition_none(self, datamodel, starting_object, to_x, to_y, max_to_x, max_to_y, shape)
    local succ
    succ, to_x, to_y = terrain:move_coord(starting_object.x, starting_object.y, starting_object.dir, math.abs(starting_object.x - to_x), math.abs(starting_object.y - to_y))

    if not terrain:can_place(to_x, to_y) then
        show_failed(self, datamodel, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)
        return
    end

    if not check_channel(self, datamodel, starting_object, to_x, to_y) then
        return
    end

    local fluidflow_id, fluid_name
    if starting_object.fluid_name == "" then
        if starting_object.fluidflow_id == 0 then
            global.fluidflow_id = global.fluidflow_id + 1
            fluidflow_id = global.fluidflow_id

            starting_object.fluidflow_id = fluidflow_id
            fluid_name = ""
        else
            fluidflow_id = starting_object.fluidflow_id
            fluid_name = starting_object.fluid_name
        end
    else
        fluidflow_id = starting_object.fluidflow_id
        fluid_name = starting_object.fluid_name
    end

    local prototype_name, object

    --
    object = iobject.new {
        prototype_name = starting_object.prototype_name,
        dir = starting_object.dir,
        x = starting_object.x,
        y = starting_object.y,
        fluid_name = starting_object.fluid_name,
        fluidflow_id = starting_object.fluidflow_id,
        state = "construct",
    }
    objects:set(object, EDITOR_CACHE_TEMPORARY[1])

    --
    prototype_name = format_prototype_name(self.coord_indicator.prototype_name, shape or "JU")
    object = iobject.new {
        prototype_name = prototype_name,
        dir = iprototype.reverse_dir(starting_object.dir),
        x = to_x,
        y = to_y,
        fluid_name = fluid_name,
        fluidflow_id = fluidflow_id,
        state = "construct",
    }
    objects:set(object, EDITOR_CACHE_TEMPORARY[1])

    show_dotted_line(self, starting_object.x, starting_object.y, starting_object.dir, to_x, to_y)

    datamodel.show_laying_pipe_confirm = true
    datamodel.show_laying_pipe_cancel = true
    self.coord_indicator.state = "construct"

    if to_x == max_to_x and to_y == max_to_y then
        object.prototype_name = format_prototype_name(self.coord_indicator.prototype_name, "JI") -- auto connect to the end of the pipe
        local succ
        succ, self.from_x, self.from_y = terrain:move_coord(to_x, to_y, starting_object.dir, 1) -- TODO: check if this is correct, not starting_object.dir

        prototype_name = format_prototype_name(self.coord_indicator.prototype_name, "JI")
        object = iobject.new {
            prototype_name = prototype_name,
            dir = starting_object.dir,
            x = self.from_x,
            y = self.from_y,
            fluid_name = fluid_name,
            fluidflow_id = fluidflow_id,
            state = "construct",
        }
        objects:set(object, EDITOR_CACHE_TEMPORARY[1])

        for _, object in objects:all("TEMPORARY") do
            object.state = "confirm"
            object.PREPARE = true
        end
        objects:commit("TEMPORARY", "CONFIRM")

        self.shape = "JI" -- TODO: remove this line
        self.shape_dir = starting_object.dir -- TODO: remove this line
        self:touch_end(datamodel)
    end
end

return function(self, datamodel, starting_object, to_x, to_y, dir, max_to_x, max_to_y)
    if is_overlap(starting_object.x, starting_object.y, to_x, to_y) then
        datamodel.show_laying_pipe_begin = false
        self.coord_indicator.state = "invalid_construct"
        return
    end

    local object = objects:coord(to_x, to_y, EDITOR_CACHE_CONSTRUCTED)
    if object then
        if iprototype.is_pipe(object.prototype_name) then
            condition_pipe(self, datamodel, starting_object, to_x, to_y, dir, max_to_x, max_to_y)
        elseif iprototype.is_pipe_to_ground(object.prototype_name) then
            condition_pipe_to_ground(self, datamodel, starting_object, to_x, to_y, max_to_x, max_to_y)
        else
            condition_normal(self, datamodel, starting_object, to_x, to_y, max_to_x, max_to_y)
        end
    else
        condition_none(self, datamodel, starting_object, to_x, to_y, max_to_x, max_to_y)
    end

end