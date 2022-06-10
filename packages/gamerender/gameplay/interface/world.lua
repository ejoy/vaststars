local gameplay = import_package "vaststars.gameplay"
local assembling = gameplay.interface "assembling"
local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"

local M = {}

function M:get_entity(world, eid)
    return world.entity[eid]
end

-- TODO
function M:get_headquater_entity(world)
    for e in world.ecs:select "id:in chest:in entity:in" do
        local typeobject = iprototype.queryById(e.entity.prototype)
        if typeobject.headquater then
            return world.entity[e.id]
        end
    end
end

function M:set_recipe(world, e, recipe_name)
    local typeobject = iprototype.queryById(e.entity.prototype)
    if not recipe_name then
        assembling.set_recipe(world, e, typeobject, recipe_name)
        log.info(("clean recipe success"))
        return true
    end

    local recipe_typeobject = iprototype.queryByName("recipe", recipe_name)
    assert(recipe_typeobject, ("can not found recipe `%s`"):format(recipe_name))
    local init_fluids = irecipe.get_init_fluids(recipe_typeobject)

    if init_fluids then
        if #typeobject.fluidboxes.input < #init_fluids.input then
            log.error(("failed to set recipe: input %s %s"):format(#typeobject.fluidboxes.input, #init_fluids.input))
            return false
        end
        if #typeobject.fluidboxes.output < #init_fluids.output then
            log.error(("failed to set recipe: output %s %s"):format(#typeobject.fluidboxes.output, #init_fluids.output))
            return false
        end
    end

    assembling.set_recipe(world, e, typeobject, recipe_name, init_fluids)
    -- m.sync("assembling:out fluidboxes:out fluidbox_changed?out", e)

    log.info(("set recipe success `%s`"):format(recipe_name))
    return true
end

return M