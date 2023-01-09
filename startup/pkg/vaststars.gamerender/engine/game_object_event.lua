local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.import.interface "ant.asset|imaterial"

local events = {}
events["material"] = function(prefab, inner, method, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = w:entity(eid, "material?in")
        if e.material then
            imaterial[method](e, ...)
        end
    end
end

events["material_tag"] = function(prefab, inner, method, tag, ...)
    for _, eid in ipairs(inner.tags[tag] or {}) do
        local e <close> = w:entity(eid, "material?in")
        if e.material then
            imaterial[method](e, ...)
        end
    end
end

return events