local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"

local function update_world(world, get_object_func)
    local t = {}
    for e in world.ecs:select "assembling:in entity:in fluidbox?in fluidboxes?in" do
        local vsobject = get_object_func(e.entity.x, e.entity.y)
        local typeobject = iprototype.queryById(e.entity.prototype)
        if typeobject.assembling_slot then
            local assembling = e.assembling
            if assembling.recipe ~= 0 then -- TODO: not need to attach every frame
                local typeobject_recipe = iprototype.queryById(assembling.recipe)
                local recipe_fluids = irecipe.get_init_fluids(typeobject_recipe)
                if recipe_fluids then
                    for i = 1, #recipe_fluids.input do
                        vsobject:attach(typeobject.assembling_slot.input[i], "prefabs/pipe-joint.prefab")
                    end
                    for i = 1, #recipe_fluids.output do
                        vsobject:attach(typeobject.assembling_slot.output[i], "prefabs/pipe-joint.prefab")
                    end
                else
                    vsobject:detach()
                end
            else
                vsobject:detach()
            end
        end
    end
    return t
end
return update_world