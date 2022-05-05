local config = import_package "vaststars.config"
local recipe_menu = config.recipe_menu
local irecipe = require "gameplay.utility.recipe"
local iprototype = require "gameplay.prototype"

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

local t = {}
for _, menu in ipairs(recipe_menu) do
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

    t[#t+1] = m
end

local function get()
    return t
end
return get