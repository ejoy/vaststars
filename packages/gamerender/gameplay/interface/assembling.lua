local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local iworld = require "gameplay.interface.world"

local M = {}

function M.item_counts(world, e)
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
        local c, n = iworld.chest_get(world, e.chest, i)
        if c then
            local item_typeobject = iprototype.queryById(c)
            r[item_typeobject.name] = n
        end
    end

    for i = 1, #recipe_results do
        local c, n = iworld.chest_get(world, e.chest, i)
        if c then
            local item_typeobject = iprototype.queryById(c)
            r[item_typeobject.name] = n
        end
    end
    return r
end

function M.has_result(world, e)
    if not e.assembling then
        log.error("not assembling")
        return
    end

    local recipe = e.assembling.recipe
    if recipe == 0 then
        return false
    end

    local typeobject = iprototype.queryById(recipe)
    local recipe_results = irecipe.get_elements(typeobject.results)

    for i = 1, #recipe_results do
        if iworld.chest_get(world, e.chest, i) then
            return true
        end
    end
    return false
end

function M.need_ingredients(world, e)
    if not e.assembling then
        log.error("not assembling")
        return
    end

    local recipe = e.assembling.recipe
    if recipe == 0 then
        return false
    end

    local typeobject = iprototype.queryById(recipe)
    local recipe_ingredients = irecipe.get_elements(typeobject.ingredients)

    local headquater_item_counts = iworld.base_chest(world)
    for i = 1, #recipe_ingredients do
        local id, c = iworld.chest_get(world, e.chest, i)
        if not id then
            if headquater_item_counts[recipe_ingredients[i].id] then
                return true
            end
        else
            if c < recipe_ingredients[i].count and headquater_item_counts[id] then
                return true
            end
        end
    end
    return false
end

return M
