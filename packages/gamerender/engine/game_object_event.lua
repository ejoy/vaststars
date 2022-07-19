local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.import.interface "ant.asset|imaterial"
local imodifier = ecs.import.interface "ant.modifier|imodifier"

local events = {}
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