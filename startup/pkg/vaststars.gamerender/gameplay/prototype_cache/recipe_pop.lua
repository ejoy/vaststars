local irecipe = require "gameplay.interface.recipe"
local iprototype = require "gameplay.interface.prototype"
local recipe_category_cfg = import_package "vaststars.prototype"("recipe_category")

return function ()
    local assembling_recipe = {}; local get_recipe_index; do
        local cache = {}
        for _, v in pairs(iprototype.each_type "recipe") do
            if v.recipe_group then
                local recipe_item = {
                    name = v.name,
                    order = v.recipe_order,
                    icon = v.recipe_icon,
                    time = v.time,
                    ingredients = irecipe.get_elements(v.ingredients),
                    results = irecipe.get_elements(v.results),
                    group = v.recipe_group,
                }
                cache[v.category] = cache[v.category] or {}
                cache[v.category][#cache[v.category] + 1] = recipe_item
            end
        end

        local function _get_group_index(group)
            for index, category_set in ipairs(recipe_category_cfg) do
                if category_set.group == group then
                    return index
                end
            end
            assert(false, ("group `%s` not found"):format(group))
        end

        local index_cache = {}

        for _, v in pairs(iprototype.each_type "building") do
            if not ((iprototype.has_type(v.type, "assembling") or iprototype.has_type(v.type, "lorry_factory")) and v.craft_category )then
                goto continue
            end
            assembling_recipe[v.name] = assembling_recipe[v.name] or {}

            for _, c in ipairs(v.craft_category) do
                -- The craft_category field of the assembler may be configured with a "category", and the recipe_group field of all recipes will not be configured with this "category".
                for _, recipe_item in ipairs(cache[c] or {}) do
                    assembling_recipe[v.name][recipe_item.group] = assembling_recipe[v.name][recipe_item.group] or {}
                    assembling_recipe[v.name][recipe_item.group][#assembling_recipe[v.name][recipe_item.group] + 1] = recipe_item
                end
            end
            for _, v in pairs(assembling_recipe[v.name]) do
                table.sort(v, function(a, b)
                    return a.order < b.order
                end)
            end

            --
            for _, g in pairs(assembling_recipe[v.name]) do
                for index, recipe in ipairs(g) do
                    index_cache[v.name] = index_cache[v.name] or {}
                    index_cache[v.name][recipe.name] = {_get_group_index(recipe.group), index}
                end
            end
            -- recipe_name -> {category_index, recipe_index}
            function get_recipe_index(assembling_name, recipe_name)
                assert(index_cache[assembling_name], ("can not find assembling `%s`"):format(assembling_name))
                assert(index_cache[assembling_name][recipe_name], ("can not find recipe `%s`"):format(recipe_name))
                return table.unpack(index_cache[assembling_name][recipe_name])
            end

            ::continue::
        end
    end

    return assembling_recipe
end