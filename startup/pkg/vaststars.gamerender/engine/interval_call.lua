local ecs = ...
local world = ecs.world
local w = world.w

local now = require "engine.time".now
return function(interval_ms, func)
    local last_update_time
    return function(...)
        local current = now()
        last_update_time = last_update_time or current
        if current - last_update_time < interval_ms then
            return
        end
        func(...)
        last_update_time = current
    end
end