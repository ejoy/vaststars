local mt = {}
mt.__index = function (t, k)
    t[k] = setmetatable({}, mt)
    return t[k]
end

return function()
    local iprototype = require "gameplay.interface.prototype"
    local itypes = require "gameplay.interface.types"

    local Item2Ingredients = {}
    local Item2Recipe = {}
    do
        local Item2Recipes = {}
        for _, v in pairs(iprototype.each_type "recipe") do
            local ingredients = itypes.items(v.ingredients)
            local results = itypes.items(v.results)
            for _, result in pairs(results) do
                local typeobject = assert(iprototype.queryById(result.id))
                Item2Recipes[typeobject.name] = Item2Recipes[typeobject.name] or {}
                table.insert(Item2Recipes[typeobject.name], {id = v.id, name = v.name, ingredients = ingredients})
            end
        end

        for _, v in pairs(iprototype.each_type "recipe") do
            table.sort(v, function(a, b) return a.id < b.id end)
        end

        local function cache_ingredients(v)
            if not Item2Recipes[v.name] then
                return
            end
            Item2Recipe[v.name] = Item2Recipes[v.name][1]
            Item2Ingredients[v.name] = Item2Recipe[v.name].ingredients
        end

        for _, v in pairs(iprototype.each_type("item")) do
            cache_ingredients(v)
        end
        for _, v in pairs(iprototype.each_type("fluid")) do
            cache_ingredients(v)
        end
    end

    local Item2Assembling = {}
    do
        local Assembling2Recipes = {}
        local Recipe2Assembling = {}
        local cache = setmetatable({}, mt)

        for _, v in pairs(iprototype.each_type "recipe") do
            if v.ingredients_details == false then
                goto continue
            end

            if v.recipe_category then
                local r = {
                    name = v.name,
                    recipe_category = v.recipe_category,
                }
                table.insert(cache[v.recipe_craft_category], r)
            end
            ::continue::
        end

        for _, v in pairs(iprototype.each_type "building") do
            if not (iprototype.has_type(v.type, "assembling") and v.craft_category )then
                goto continue
            end

            if v.ingredients_details == false then
                goto continue
            end

            Assembling2Recipes[v.name] = {}
            for _, c in ipairs(v.craft_category) do
                table.move(cache[c], 1, #cache[c], #Assembling2Recipes[v.name] + 1, Assembling2Recipes[v.name])
            end
            ::continue::
        end

        for AssemblingName, t in pairs(Assembling2Recipes) do
            for _, v in pairs(t) do
                Recipe2Assembling[v.name] = Recipe2Assembling[v.name] or {}
                table.insert(Recipe2Assembling[v.name], AssemblingName)
            end
        end

        for item, recipe in pairs(Item2Recipe) do
            if Recipe2Assembling[recipe.name] then
                table.sort(Recipe2Assembling[recipe.name], function(a, b)
                    return iprototype.queryByName(a).item_order < iprototype.queryByName(b).item_order
                end)
                Item2Assembling[item] = Recipe2Assembling[recipe.name]
            end
        end
    end

    return {
        item_ingredients = Item2Ingredients,
        item_assembling = Item2Assembling,
    }
end