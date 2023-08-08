local ecs = ...
local world = ecs.world

local objects = require "objects"
local iobject = ecs.require "object"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS

--
local M = {}

function M:revert_changes(revert_cache_names)
    local t = {}
    for _, cache_name in ipairs(revert_cache_names) do
        for id, object in objects:all(cache_name) do
            t[id] = object
        end
    end
    objects:clear(revert_cache_names)

    for id, object in pairs(t) do
        local old_object = objects:get(id, {"CONFIRM", "CONSTRUCTED"})
        if old_object then
            object.prototype_name = old_object.prototype_name
            object.dir = old_object.dir
            object.srt.r = ROTATORS[object.dir]
            object.fluid_name = old_object.fluid_name
        else
            iobject.remove(object)
        end
    end
    iobject.flush() -- object is removed from cache, so we need to flush it, else it will keep the old state
end

return M