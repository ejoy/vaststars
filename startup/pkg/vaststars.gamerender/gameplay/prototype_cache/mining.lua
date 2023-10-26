local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"

return function()
    local recipe_category = {}
    for _, typeobject in pairs(iprototype.each_type "recipe") do
        recipe_category[typeobject.recipe_craft_category] = recipe_category[typeobject.recipe_craft_category] or {}
        local t = recipe_category[typeobject.recipe_craft_category]
        t[#t+1] = typeobject
    end

    local mining_recipe = {}
    for _, typeobject in pairs(iprototype.each_type("building", "mining")) do
        assert(typeobject.mining_category, "mining entity should have mining_category")
        mining_recipe[typeobject.name] = {}
        for _, category in ipairs(typeobject.mining_category) do
            local recipes = recipe_category[category]
            if not recipes then
            error(("can not find recipe category `%s`"):format(category))
            end

            for _, recipe_typeobject in ipairs(recipes) do
                local ingredients = itypes.items(recipe_typeobject.ingredients)
                local result = itypes.items(recipe_typeobject.results)
                assert(#ingredients == 0, "recipe of mining should not have ingredients")
                assert(#result == 1, "recipe of mining should only have one result")

                local mineral = iprototype.queryById(result[1].id).name
                local _ = mining_recipe[mineral] == nil or error(("find duplicate recipe for mineral `%s`"):format(mineral))
                mining_recipe[typeobject.name][mineral] = recipe_typeobject.name
            end
        end
    end

    return mining_recipe
end