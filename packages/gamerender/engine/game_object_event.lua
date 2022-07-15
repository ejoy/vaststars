local ecs = ...
local world = ecs.world
local w = world.w

local iani = ecs.import.interface "ant.animation|ianimation"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local imodifier = ecs.import.interface "ant.modifier|imodifier"


local events = {}
events["animation_play"] = function(prefab, binding, animation)
    if binding.animation_eid ~= 0 then
        iani.play(binding.animation_eid, animation)
    end
end

events["animation_set_time"] = function(prefab, binding, animation_name, process)
    if binding.animation_eid ~= 0 then
        iani.set_time(binding.animation_eid, iani.get_duration(binding.animation_eid, animation_name) * process)
    end
end

events["set_material_property"] = function(prefab, binding, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = assert(world:entity(eid))
        if e.material then
            imaterial.set_property(e, ...)
        end
    end
end

events["modifier"] = function(prefab, binding, oper, ...)
    -- imodifier[oper](...)
end

return events