local gameplay = import_package "vaststars.gameplay"
local config = import_package "vaststars.config"
local recipe_menu = config.recipe_menu
local general = require "gameplay.utility.general"
local has_type = general.has_type

local recipes = {}
for _, v in pairs(gameplay.prototype_name) do
    if has_type(v.type, "recipe") then
        recipes[v.category] = recipes[v.category] or {}
        recipes[v.category][#recipes[v.category] + 1] = {name = v.name, order = v.order, icon = v.icon}
    end
end

local t = {}
for _, menu in ipairs(recipe_menu) do
    local m = {}
    m.name = menu.name
    m.icon = menu.icon
    m.item = {}

    for _, c in ipairs(menu.category) do
        table.move(recipes[c], 1, #recipes[c], #m.item + 1, m.item)
    end
    table.sort(m.item, function(a, b) return a.order < b.order end)

    t[#t+1] = m
end

local function get()
    return t
end
return get