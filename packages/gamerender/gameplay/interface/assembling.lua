local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local iworld = require "gameplay.interface.world"
local ichest = require "gameplay.interface.chest"

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

    local headquater_e = iworld:get_headquater_entity(world)
    if not headquater_e then
        log.error("no headquater")
        return
    end

    local recipe = e.assembling.recipe
    local typeobject = iprototype.queryById(recipe)
    local recipe_ingredients = irecipe.get_elements(typeobject.ingredients)
    local recipe_results = irecipe.get_elements(typeobject.results)

    local items = {}
    for i = 1, #recipe_results do
        local c, n = world:container_get(e.assembling.container, #recipe_ingredients + i)
        if c then
            local item_typeobject = iprototype.queryById(c)
            if iprototype.queryByName("item", item_typeobject.name) then
                if not world:container_pickup(e.assembling.container, c, n) then
                    log.error(("failed to pickup `%s` `%s`"):format(c, n))
                else
                    if not world:container_place(headquater_e.chest.container, c, n) then
                        log.error(("failed to place `%s` `%s`"):format(n, c))
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

    local headquater_e = iworld:get_headquater_entity(world)
    if not headquater_e then
        log.error("no headquater")
        return
    end

    local typeobject = iprototype.queryById(recipe)
    local recipe_ingredients = irecipe.get_elements(typeobject.ingredients)

    local assembling_item_counts = {}
    for i, v in ipairs(recipe_ingredients) do
        local c, n = world:container_get(e.assembling.container, i)
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

    local headquater_item_counts = ichest:item_counts(world, headquater_e)
    for id, count in pairs(assembling_item_counts) do
        if headquater_item_counts[id] then
            local c = math.min(headquater_item_counts[id], count)
            if c > 0 then
                if not world:container_pickup(headquater_e.chest.container, id, c) then
                    log.error(("failed to pickup `%s` `%s`"):format(id, c))
                else
                    if not world:container_place(e.assembling.container, id, c) then
                        log.error(("failed to place `%s` `%s`"):format(id, c))
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

    for i = 1, #recipe_ingredients + #recipe_results do
        local c, n = world:container_get(e.assembling.container, i)
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
        log.error("the recipe hasn't been set")
        return
    end

    local typeobject = iprototype.queryById(recipe)
    local recipe_ingredients = irecipe.get_elements(typeobject.ingredients)
    local recipe_results = irecipe.get_elements(typeobject.results)

    for i = 1, #recipe_results do
        if world:container_get(e.assembling.container, #recipe_ingredients + i) then
            return true
        end
    end
    return false
end

return M
