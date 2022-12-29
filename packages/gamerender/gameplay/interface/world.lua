local gameplay = import_package "vaststars.gameplay"
local assembling = gameplay.interface "assembling"
local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"

local M = {}

function M.get_entity(world, eid)
    return world.entity[eid]
end

function M.chest_get(world, chest, i)
    local slot = world:container_get(chest, i)
    if slot then
        return slot.item, slot.amount
    end
end

function M.chest_pickup(world, chest, id, count)
    return world:container_pickup(chest, id, count)
end

function M.chest_place(world, chest, id, count)
    return world:container_place(chest, id, count)
end

function M.base_chest_place(world, prototype, count)
    local e = assert(world.ecs:first("base chest:in"))
    world:container_place(e.chest, prototype, count)
end

-- prototype, count
function M.base_chest_pickup(world, ...)
    local e = assert(world.ecs:first("base chest:in"))
    return world:container_pickup(e.chest, ...)
end

function M.base_chest(world)
    local chest = {}
    local ecs = world.ecs
    for v in ecs:select "base entity:in chest:in" do
        local typeobject = iprototype.queryById(v.entity.prototype)
        for i = 1, typeobject.slots do
            local slot = world:container_get(v.chest, i)
            if slot and slot.item ~= 0 then
                chest[slot.item] = chest[slot.item] or 0
                chest[slot.item] = chest[slot.item] + slot.amount
            end
        end
        break
    end
    return chest
end

function M.set_recipe(world, e, recipe_name)
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
    log.info(("set recipe success `%s`"):format(recipe_name))
    return true
end

function M.get_storage(world)
    world.storage = world.storage or {}
    return world.storage
end

return M