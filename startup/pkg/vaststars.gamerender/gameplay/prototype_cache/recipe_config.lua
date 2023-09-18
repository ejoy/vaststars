local iprototype = require "gameplay.interface.prototype"

local mt = {}
mt.__index = function (t, k)
    t[k] = setmetatable({}, mt)
    return t[k]
end

return function ()
    local assembling_recipes = {}
    local chimney_recipes = {}

    do
        local cache_a = setmetatable({}, mt)
        local cache_c = setmetatable({}, mt)

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
            end

            if iprototype.has_type(v.type, "chimney") and v.craft_category then
                chimney_recipes[v.name] = {}
                for _, c in ipairs(v.craft_category) do
                    table.move(cache_c[c], 1, #cache_c[c], #chimney_recipes[v.name] + 1, chimney_recipes[v.name])
                end
                for _, v in pairs(chimney_recipes[v.name]) do
                    table.sort(v, function(a, b)
                        return a.recipe_order < b.recipe_order
                    end)
                end
            end
        end
    end

    return {
        assembling_recipes = assembling_recipes,
        chimney_recipes = chimney_recipes,
    }
end