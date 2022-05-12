local get_recipe_menu = require "gameplay.utility.get_recipe_menu"

local function get_recipe_index(recipe_menu, recipe_name)
    for index, v1 in ipairs(recipe_menu) do
        for recipe_index, v2 in ipairs(v1.item) do
            if v2.name == recipe_name then
                return index, recipe_index
            end
        end
    end

    log.error(("can not found recipe `%s`"):format(recipe_name))
    return 1, 1
end

---------------
local M = {}

function M:create(object_id, recipe_name)
    local recipe_menu = get_recipe_menu()
    local catalog_index = 1
    local recipe_index = 1

    if recipe_name and recipe_name ~= "" then
        catalog_index, recipe_index = get_recipe_index(get_recipe_menu(), recipe_name)
    end

    return {
        object_id = object_id,
        recipe_index = recipe_index,
        recipe_name = recipe_name or "",
        recipe_menu = recipe_menu,
        catalog_index = catalog_index,
        items = recipe_menu[catalog_index].item or {}
    }
end

function M:update(datamodel, param, object_id, recipe_name)
    if param[1] ~= object_id then
        return
    end

    if recipe_name and recipe_name ~= "" then
        datamodel.catalog_index, datamodel.recipe_index = get_recipe_index(get_recipe_menu(), recipe_name)
        datamodel.recipe_name = recipe_name
    end
    datamodel.items = datamodel.recipe_menu[datamodel.catalog_index].item or {}

    return true
end

return M