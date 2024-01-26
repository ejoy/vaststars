local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"

return function()
    local recipe_category = {}
    for _, typeobject in pairs(iprototype.each_type "recipe") do
        recipe_category[typeobject.recipe_craft_category] = recipe_category[typeobject.recipe_craft_category] or {}
        local t = recipe_category[typeobject.recipe_craft_category]
        t[#t+1] = typeobject
    end

    local miner_recipe = {}
    for _, typeobject in pairs(iprototype.each_type("building", "mining")) do
        assert(typeobject.craft_category, "miner entity should have craft_category")
        miner_recipe[typeobject.name] = {}
        for _, category in ipairs(typeobject.craft_category) do
            local recipes = recipe_category[category]
            if not recipes then
            error(("can not find recipe category `%s`"):format(category))
            end

            for _, recipe_typeobject in ipairs(recipes) do
                local ingredients = itypes.items(recipe_typeobject.ingredients)
                local result = itypes.items(recipe_typeobject.results)
                assert(#ingredients == 0, "recipe of miner should not have ingredients")
                assert(#result == 1, "recipe of miner should only have one result")

                local mineral = iprototype.queryById(result[1].id).name
                local _ = miner_recipe[mineral] == nil or error(("find duplicate recipe for mineral `%s`"):format(mineral))
                miner_recipe[typeobject.name][mineral] = recipe_typeobject.name
            end
        end
    end

    return miner_recipe
end