local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local ichest = require "gameplay.interface.chest"

local M = {}

function M.collect_item(world, e)
    local r = {}

    if not e.assembling then
        log.error("not assembling")
        return r
    end

    local recipe = e.assembling.recipe
    if recipe == 0 then
        return r
    end

    local typeobject = iprototype.queryById(recipe)
    local recipe_ingredients = irecipe.get_elements(typeobject.ingredients)
    local recipe_results = irecipe.get_elements(typeobject.results)

    for i = 1, #recipe_ingredients do
        local slot = ichest.chest_get(world, e.chest, i)
        if slot then
            local item_typeobject = iprototype.queryById(slot.item)
            r[item_typeobject.name] = slot.amount
        end
    end

    for i = 1, #recipe_results do
        local slot = ichest.chest_get(world, e.chest, i)
        if slot then
            local item_typeobject = iprototype.queryById(slot.item)
            r[item_typeobject.name] = slot.amount
        end
    end
    return r
end

return M
