local config = import_package "vaststars.config"
local recipe_menu = config.recipe_menu
local general = require "gameplay.utility.general"
local has_type = general.has_type
local recipe_api = require "gameplay.utility.recipe"
local prototype_api = require "gameplay.prototype"

local recipes = {}
for _, v in pairs(prototype_api.prototype_name) do
    if has_type(v.type, "recipe") then
        recipes[v.category] = recipes[v.category] or {}
        recipes[v.category][#recipes[v.category] + 1] = {
            name = v.name,
            order = v.order,
            icon = v.icon,
            time = v.time,
            ingredients = recipe_api.get_items(v.ingredients),
            results = recipe_api.get_items(v.results),
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