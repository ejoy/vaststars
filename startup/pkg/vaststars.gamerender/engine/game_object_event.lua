local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.require "ant.asset|material"
local iefk = ecs.require "ant.efk|efk"
local iplayback = ecs.require "ant.animation|playback"

local events = {}
events["material"] = function(prefab, method, ...)
    local exclude = {}
    for _, eid in ipairs(prefab.tag["no_color_factors"] or {}) do
        exclude[eid] = true
    end
    for _, eid in ipairs(prefab.tag["*"]) do
        if not exclude[eid] then
            local e <close> = world:entity(eid, "material?in")
            if e.material then
                imaterial[method](e, ...)
            end
        end
    end
end

events["stop_world"] = function(prefab)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = world:entity(eid, "animation?in efk?in")
        if e.animation then
            iplayback.set_play_all(e, false)
        end
        if e.efk then
            iefk.pause(e, true)
        end
    end
end

events["restart_world"] = function(prefab)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = world:entity(eid, "animation?in efk?in")
        if e.animation then
            iplayback.set_play_all(e, true)
        end
        if e.efk then
            iefk.pause(e, false)
        end
    end
end

return events