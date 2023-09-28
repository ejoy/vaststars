local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.require "ant.asset|material"
local iani = ecs.require "ant.animation|state_machine"
local iefk = ecs.require "ant.efk|efk"

local events = {}
events["material"] = function(prefab, method, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = world:entity(eid, "material?in")
        if e.material then
            imaterial[method](e, ...)
        end
    end
end

events["stop_world"] = function(prefab, method, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = world:entity(eid, "anim_ctrl?in efk?in")
        if e.anim_ctrl then
            iani.pause(eid, false)
        end
        if e.efk then
            iefk.pause(e, false)
        end
    end
end

events["restart_world"] = function(prefab, method, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = world:entity(eid, "anim_ctrl?in efk?in")
        if e.anim_ctrl then
            iani.pause(eid, true)
        end
        if e.efk then
            iefk.pause(e, true)
        end
    end
end

return events