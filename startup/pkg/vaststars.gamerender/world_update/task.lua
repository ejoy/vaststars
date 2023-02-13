local ecs = ...
local world = ecs.world
local w = world.w

local itask = ecs.require "task"
local ltask = require "ltask"
local ltask_now = ltask.now


local function _gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end
local task_update; do
    local last_update_time
    function task_update()
        local current = _gettime()
        last_update_time = last_update_time or current
        if current - last_update_time < 300 then
            return
        end
        last_update_time = current
        itask.update_progress("lorry_count")
    end
end
return task_update