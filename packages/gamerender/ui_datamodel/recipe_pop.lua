local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local set_recipe_mb = mailbox:sub {"set_recipe"}
local building_menu = ecs.require "building_menu"
local recipe_menu_cfg = import_package "vaststars.prototype"("recipe_category")
local irecipe = require "gameplay.interface.recipe"
local iprototype = require "gameplay.interface.prototype"

local recipe_menu = {} ; do
    local recipes = {}
    for _, v in pairs(iprototype:all_prototype_name()) do
        if iprototype:has_type(v.type, "recipe") then
            recipes[v.category] = recipes[v.category] or {}
            recipes[v.category][#recipes[v.category] + 1] = {
                name = v.name,
                order = v.order,
                icon = v.icon,
                time = v.time,
                ingredients = irecipe:get_elements(v.ingredients),
                results = irecipe:get_elements(v.results),
                group = v.group,
            }
        end
    end

    for _, menu in ipairs(recipe_menu_cfg) do
        local m = {}
        m.group = menu.group
        m.icon = menu.icon
        m.item = {}

        for _, category in ipairs(menu.category) do
            assert(recipes[category], ("can not found category `%s`, define in package.prototype.recipe"):format(category))
            for _, v in ipairs(recipes[category]) do
                if v.group == menu.group then
                    m.item[#m.item + 1] = v
                end
            end
        end
        table.sort(m.item, function(a, b) return a.order < b.order end)

        recipe_menu[#recipe_menu+1] = m
    end
end

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
    local catalog_index = 1
    local recipe_index = 1

    if recipe_name and recipe_name ~= "" then
        catalog_index, recipe_index = get_recipe_index(recipe_menu, recipe_name)
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
        datamodel.catalog_index, datamodel.recipe_index = get_recipe_index(recipe_menu, recipe_name)
        datamodel.recipe_name = recipe_name
    end
    datamodel.items = datamodel.recipe_menu[datamodel.catalog_index].item or {}
end

function M:stage_ui_update(datamodel)
    for _, _, _, vsobject_id, recipe_name in set_recipe_mb:unpack() do
        building_menu:set_recipe(vsobject_id, recipe_name)
    end
end

return M