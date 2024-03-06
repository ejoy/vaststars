local ecs = ...
local world = ecs.world
local w = world.w

local ivs = ecs.require "ant.render|visible_state"
local imaterial = ecs.require "ant.asset|material"
local iefk = ecs.require "ant.efk|efk"
local iplayback = ecs.require "ant.animation|playback"
local message = ecs.require "message"

message:sub("show", function(instance, visible)
    for _, eid in ipairs(instance.tag['*']) do
        local e <close> = world:entity(eid, "visible_state?in")
        if e.visible_state then
            ivs.set_state(e, "main_view", visible)
        end
    end
end)

message:sub("material", function(instance, method, ...)
    local exclude = {}
    for _, eid in ipairs(instance.tag["no_color_factors"] or {}) do
        exclude[eid] = true
    end
    for _, eid in ipairs(instance.tag["*"]) do
        if not exclude[eid] then
            local e <close> = world:entity(eid, "material?in")
            if e.material then
                imaterial[method](e, ...)
            end
        end
    end
end)

message:sub("stop_world", function(instance)
    for _, eid in ipairs(instance.tag["*"]) do
        local e <close> = world:entity(eid, "animation?in efk?in")
        if e.animation then
            iplayback.set_play_all(e, false)
        end
        if e.efk then
            iefk.pause(e, true)
        end
    end
end)

message:sub("restart_world", function(instance)
    for _, eid in ipairs(instance.tag["*"]) do
        local e <close> = world:entity(eid, "animation?in efk?in")
        if e.animation then
            iplayback.set_play_all(e, true)
        end
        if e.efk then
            iefk.pause(e, false)
        end
    end
end)

return message
