local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iprototype_cache = ecs.require "prototype_cache"
local iprototype = require "gameplay.interface.prototype"
local click_item_mb = mailbox:sub {"click_item"}
local set_recipe_mb = mailbox:sub {"set_recipe"}
local clear_recipe_mb = mailbox:sub {"clear_recipe"}
local iui = ecs.require "engine.system.ui_system"

---------------
local M = {}

local function _update_item(datamodel, item)
    local typeobject = assert(iprototype.queryById(item))
    local item_ingredients = {}
    for _, v in pairs(iprototype_cache.get("item_ingredients").item_ingredients[typeobject.name] or {}) do
        local typeobject = assert(iprototype.queryById(v.id))
        local t = {
            name = iprototype.display_name(typeobject),
            icon = typeobject.item_icon,
            count = v.count,
        }
        item_ingredients[#item_ingredients+1] = t
    end

    local item_assembling = {}
    for _, name in pairs(iprototype_cache.get("item_ingredients").item_assembling[typeobject.name] or {}) do
        local typeobject = assert(iprototype.queryByName(name))
        local t = {
            icon = typeobject.icon,
            name = iprototype.display_name(typeobject),
        }
        item_assembling[#item_assembling+1] = t
    end

    datamodel.item_name = iprototype.display_name(typeobject)
    datamodel.item_desc = typeobject.item_description or ""
    datamodel.item_icon = typeobject.item_icon
    datamodel.item_ingredients = item_ingredients
    datamodel.item_assembling = item_assembling
end

function M.create(recipe_name, recipe_icon, recipe_time, recipe_ingredients, recipe_results, confirm, item)
    local datamodel = {
        recipe_name = recipe_name,
        recipe_icon = recipe_icon,
        recipe_time = recipe_time,
        recipe_ingredients = recipe_ingredients,
        recipe_results = recipe_results,
        confirm = confirm,
    }

    _update_item(datamodel, item)
    return datamodel
end

function M.update(datamodel)
    for _, _, _, item in click_item_mb:unpack() do
        _update_item(datamodel, item)
    end

    for _ in set_recipe_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/recipe_config.rml", "set_recipe")
        iui.close("/pkg/vaststars.resources/ui/item_source.rml")
    end

    for _ in clear_recipe_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/recipe_config.rml", "clear_recipe")
        iui.close("/pkg/vaststars.resources/ui/item_source.rml")
    end
end

return M