local ecs = ...
local world = ecs.world
local w = world.w

local ivs = ecs.require "ant.render|visible_state"
local message = ecs.require "message"

message:sub("show", function(instance, visible)
    for _, eid in ipairs(instance.tag['*']) do
        local e <close> = world:entity(eid, "visible_state?in")
        if e.visible_state then
            ivs.set_state(e, "main_view", visible)
        end
    end
end)

return message
