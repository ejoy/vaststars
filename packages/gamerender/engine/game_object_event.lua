local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.import.interface "ant.asset|imaterial"

local events = {}
events["set_material_property"] = function(prefab, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = assert(world:entity(eid))
        if e.material then
            imaterial.set_property(e, ...)
        end
    end
end

return events