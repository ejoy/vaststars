local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.require "ant.asset|material"

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

return events
