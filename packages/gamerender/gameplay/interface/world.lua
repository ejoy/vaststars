local gameplay = import_package "vaststars.gameplay"
local assembling = gameplay.interface "assembling"
local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"

local M = {}

function M:get_entity(world, eid)
    return world.entity[eid]
end

function M:get_headquater_entity(world)
    for e in world.ecs:select "id:in chest:in entity:in" do
        local typeobject = iprototype:query(e.entity.prototype)
        if typeobject.headquater then
            return world.entity[e.id]
        end
    end
end

function M:set_recipe(world, e, recipe_name)
    local recipe_typeobject = iprototype:queryByName("recipe", recipe_name)
    assert(recipe_typeobject, ("can not found recipe `%s`"):format(recipe_name))

    local typeobject = iprototype:query(e.entity.prototype)
    local init_fluids = irecipe:get_init_fluids(recipe_typeobject)

    if init_fluids then
        if #typeobject.fluidboxes.input < #init_fluids.input then
            log.error(("failed to set recipe: input %s %s"):format(#typeobject.fluidboxes.input, #init_fluids.input))
            return
        end
        if #typeobject.fluidboxes.output < #init_fluids.output then
            log.error(("failed to set recipe: output %s %s"):format(#typeobject.fluidboxes.output, #init_fluids.output))
            return
        end
    end

    assembling.set_recipe(world, e, typeobject, recipe_name, init_fluids)
    -- m.sync("assembling:out fluidboxes:out fluidbox_changed?out", e)

    log.info(("set recipe success `%s`"):format(recipe_name))
end

return M