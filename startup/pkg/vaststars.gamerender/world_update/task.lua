local ecs = ...
local world = ecs.world
local w = world.w

local now = require "engine.time".now
local itask = ecs.require "task"

local task_update; do
    local last_update_time
    function task_update()
        local current = now()
        last_update_time = last_update_time or current
        if current - last_update_time < 300 then
            return
        end
        last_update_time = current
        itask.update_progress("lorry_count")
        itask.update_progress("auto_complete_task")
    end
end
return task_update