local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.require "ant.asset|material"

local events = {}
events["material"] = function(prefab, method, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = world:entity(eid, "material?in")
        if e.material then
            imaterial[method](e, ...)
        end
    end
end
return events