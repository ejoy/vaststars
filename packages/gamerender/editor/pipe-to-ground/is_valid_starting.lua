local ecs = ...
local world = ecs.world
local w = world.w

local terrain = ecs.require "terrain"
local objects = require "objects"
local ifluid = require "gameplay.interface.fluid"
local iprototype = require "gameplay.interface.prototype"

local EDITOR_CACHE_CONSTRUCTED = {"CONFIRM", "CONSTRUCTED"}

local function is_valid_starting(x, y)
    local object = objects:coord(x, y, EDITOR_CACHE_CONSTRUCTED)
    if not object then
        return terrain:can_place(x, y)
    end

    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    if typeobject.pipe or typeobject.pipe_to_ground then
        return true
    end

    local function can_replace_pipe(prototype_name, fluidbox_dir)
        local typeobject = iprototype.queryByName("entity", prototype_name)
        assert(typeobject.pipe and typeobject.fluidbox)
        local t = {
            N = {N = true, S = true},
            S = {N = true, S = true},
            W = {W = true, E = true},
            E = {W = true, E = true},
        }
        for _, connection in ipairs(typeobject.fluidbox.connections) do
            if not t[fluidbox_dir][connection.position[3]] then
                return false
            end
        end
        return true
    end

    local succ, dx, dy, obj
    for _, v in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
        succ, dx, dy = terrain:move_coord(v.x, v.y, v.dir, 1)
        if succ then
            obj = objects:coord(dx, dy, EDITOR_CACHE_CONSTRUCTED)
            if not obj and terrain:can_place(dx, dy) then
                return true
            end
            if obj.pipe and can_replace_pipe(obj.prototype_name) then
                return true
            end
            if obj.pipe_to_ground then
                return true
            end
        end
    end
    return false
end
return is_valid_starting