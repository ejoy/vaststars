local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local iworld = require "gameplay.interface.world"

local M = {}

-- 成品取出
function M.pickup_material(world, e)
    if not e.assembling then
        log.error("not assembling")
        return
    end

    local recipe = e.assembling.recipe
    if recipe == 0 then
        log.error("the recipe hasn't been set")
        return
    end

    local recipe = e.assembling.recipe
    local typeobject = iprototype.queryById(recipe)
    local recipe_results = irecipe.get_elements(typeobject.results)

    local items = {}
    for i = 1, #recipe_results do
        local c, n = iworld.chest_get(world, e.chest.chest_out, i)
        if c then
            local item_typeobject = iprototype.queryById(c)
            if iprototype.queryByName("item", item_typeobject.name) then
                if not iworld.chest_pickup(world, e.chest.chest_out, c, n) then
                    log.error(("failed to pickup `%s` `%s`"):format(c, n))
                else
                    local r = iworld.base_chest_place(world, c, n)
                    if r ~= 0 then
                        log.error(("failed to place `%s` `%s` `%s`"):format(n, c, r))
                    else
                        items[#items + 1] = {name = item_typeobject.name, count = n, icon = item_typeobject.icon}
                    end
                end
            end
        end
    end
    world:build()
    return items
end

-- 原料添加
function M.place_material(world, e)
    if not e.assembling then
        log.error("not assembling")
        return
    end

    local recipe = e.assembling.recipe
    if recipe == 0 then
        log.error("the recipe hasn't been set")
        return
    end

    local typeobject = iprototype.queryById(recipe)
    local recipe_ingredients = irecipe.get_elements(typeobject.ingredients)

    local assembling_item_counts = {}
    for i, v in ipairs(recipe_ingredients) do
        local c, n = iworld.chest_get(world, e.chest.chest_in, i)
        if c then
            local count = v.count
            if n < count then
                assembling_item_counts[c] = count - n
            end
        else
            assembling_item_counts[v.id] = v.count
        end
    end

    if not next(assembling_item_counts) then
        log.error("no material place")
        return
    end

    local headquater_item_counts = iworld.base_chest(world)
    for id, count in pairs(assembling_item_counts) do
        if headquater_item_counts[id] then
            local c = math.min(headquater_item_counts[id], count)
            if c > 0 then
                if not iworld.base_chest_pickup(world, id, c) then
                    log.error(("failed to pickup `%s` `%s`"):format(id, c))
                else
                    local r = iworld.chest_place(world, e.chest.chest_in, id, c)
                    if r ~= 0 then
                        log.error(("failed to place `%s` `%s` `%s`"):format(id, c, r))
                    end
                end
            end
        end
    end
    world:build()
end

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
        local c, n = iworld.chest_get(world, e.chest.chest_in, i)
        if c then
            local item_typeobject = iprototype.queryById(c)
            r[item_typeobject.name] = n
        end
    end

    for i = 1, #recipe_results do
        local c, n = iworld.chest_get(world, e.chest.chest_out, i)
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
        if iworld.chest_get(world, e.chest.chest_out, i) then
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
        local id, c = iworld.chest_get(world, e.chest.chest_in, i)
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
