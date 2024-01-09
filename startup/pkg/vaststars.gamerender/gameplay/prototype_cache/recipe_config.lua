local iprototype = require "gameplay.interface.prototype"

local mt = {}
mt.__index = function (t, k)
    t[k] = {}
    return t[k]
end

return function ()
    local assembling_recipes = {}
    local assembling_recipes_2 = {}
    local chimney_recipes = {}

    do
        local cache_a = setmetatable({}, mt) -- assembling
        local cache_c = setmetatable({}, mt) -- chimney

        for _, v in pairs(iprototype.each_type "recipe") do
            if v.recipe_category then
                table.insert(cache_a[v.recipe_craft_category], {
                    id = v.id,
                    name = v.name,
                    recipe_order = v.recipe_order,
                    icon = v.recipe_icon,
                    recipe_category = v.recipe_category,
                })
            else
                table.insert(cache_c[v.recipe_craft_category], {
                    id = v.id,
                    name = v.name,
                    recipe_order = v.recipe_order,
                    icon = v.recipe_icon,
                })
            end
        end

        for _, v in pairs(iprototype.each_type "building") do
            if iprototype.has_type(v.type, "assembling") and v.craft_category then
                assembling_recipes[v.name] = {}
                for _, c in ipairs(v.craft_category) do
                    table.move(cache_a[c], 1, #cache_a[c], #assembling_recipes[v.name] + 1, assembling_recipes[v.name])
                end
                table.sort(assembling_recipes[v.name], function(a, b)
                    return a.recipe_order < b.recipe_order
                end)

                for _, recipe in ipairs(assembling_recipes[v.name]) do
                    local typeobject_recipe = iprototype.queryByName(recipe.name)
                    local s = typeobject_recipe.ingredients
                    if #s // 4 == 2 then
                        for idx = 2, #s // 4 do
                            local id = string.unpack("<I2I2", s, 4 * idx - 3)
                            local typeobject = iprototype.queryById(id) or error(("can not found id `%s`"):format(id))
                            assembling_recipes_2[v.name] = assembling_recipes_2[v.name] or {}
                            assembling_recipes_2[v.name][typeobject.name] = recipe.name
                        end
                    end
                end
            end

            if iprototype.has_type(v.type, "chimney") and v.craft_category then
                chimney_recipes[v.name] = {}
                for _, c in ipairs(v.craft_category) do
                    for _, recipe in ipairs(cache_c[c]) do
                        local typeobject_recipe = iprototype.queryByName(recipe.name)
                        local s = typeobject_recipe.ingredients
                        assert(#s // 4 == 2)
                        for idx = 2, #s // 4 do
                            local id = string.unpack("<I2I2", s, 4 * idx - 3)
                            local typeobject = iprototype.queryById(id) or error(("can not found id `%s`"):format(id))
                            chimney_recipes[v.name][typeobject.name] = recipe.name
                        end
                    end
                end
            end
        end
    end

    return {
        assembling_recipes = assembling_recipes, -- [building] = recipe_list
        assembling_recipes_2 = assembling_recipes_2, -- [building][ingredient] = recipe
        chimney_recipes = chimney_recipes, -- [building][ingredient] = recipe
    }
end