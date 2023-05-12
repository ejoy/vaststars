local ecs = ...
local world = ecs.world
local w = world.w

local itask = ecs.require "task"
local interval_call = ecs.require "engine.interval_call"
return interval_call(300, function()
    itask.update_progress("lorry_count")
    itask.update_progress("auto_complete_task")
    return false
end, false)