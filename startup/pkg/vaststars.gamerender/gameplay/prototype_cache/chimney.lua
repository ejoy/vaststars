local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"

return function()
    local cache = {}
    for _, v in pairs(iprototype.each_type "recipe") do
        cache[v.recipe_craft_category] = cache[v.recipe_craft_category] or {}
        local ingredients = itypes.items(v.ingredients)
        if #ingredients ~= 1 then
            goto continue
        end

        local typeobject = iprototype.queryById(ingredients[1].id)
        cache[v.recipe_craft_category][typeobject.name] = cache[v.recipe_craft_category][typeobject.name] or {}
        table.insert(cache[v.recipe_craft_category][typeobject.name], v.name)
        ::continue::
    end

    return cache
end