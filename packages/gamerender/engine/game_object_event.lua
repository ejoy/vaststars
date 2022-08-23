local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.import.interface "ant.asset|imaterial"

local events = {}
events["set_material_property"] = function(prefab, inner, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = w:entity(eid, "material?in")
        if e.material then
            imaterial.set_property(e, ...)
        end
    end
end

events["set_tag_material_property"] = function(prefab, inner, tag, ...)
    for _, eid in ipairs(inner.tags[tag] or {}) do
        local e <close> = w:entity(eid, "material?in")
        if e.material then
            imaterial.set_property(e, ...)
        end
    end
end

return events