local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local CHANGED_FLAG_ASSEMBLING <const> = require("gameplay.interface.constant").CHANGED_FLAG_ASSEMBLING
local RECIPE_CATEGORY <const> = ecs.require "vaststars.prototype|recipe_category"

local set_recipe_mb = mailbox:sub {"set_recipe"}
local click_recipe_mb = mailbox:sub {"click_recipe"}
local clear_recipe_mb = mailbox:sub {"clear_recipe"}
local click_item_mb = mailbox:sub {"click_item"}
local irecipe = require "gameplay.interface.recipe"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.require "engine.system.ui_system"
local iworld = require "gameplay.interface.world"
local recipe_unlocked = ecs.require "ui_datamodel.common.recipe_unlocked".recipe_unlocked
local itask = ecs.require "task"
local iprototype_cache = require "gameplay.prototype_cache.init"
local itypes = require "gameplay.interface.types"

local function __set_recipe_value(datamodel, category_idx, recipe_idx, key, value)
    if category_idx == 0 and recipe_idx == 0 then
        return
    end
    assert(datamodel.recipes[category_idx])
    assert(datamodel.recipes[category_idx].recipes[recipe_idx])
    datamodel.recipes[category_idx].recipes[recipe_idx][key] = value
end

local function __mark_recipe_flag(recipe_name)
    local storage = gameplay_core.get_storage()
    storage.recipe_picked_flag = storage.recipe_picked_flag or {}
    storage.recipe_picked_flag[recipe_name] = true
end

---------------
local M = {}

function M.create(gameplay_eid)
    local e = assert(gameplay_core.get_entity(gameplay_eid))

    local datamodel = {}
    datamodel.category_idx = 0
    datamodel.recipe_idx = 0
    datamodel.confirm = false

    if e.assembling.recipe ~= 0 then
        local typeobject = iprototype.queryById(e.assembling.recipe)
        datamodel.recipe_name = iprototype.display_name(typeobject)
        datamodel.recipe_icon = typeobject.recipe_icon
        datamodel.recipe_time = itypes.time(typeobject.time)
        datamodel.recipe_ingredients = irecipe.get_elements(typeobject.ingredients)
        datamodel.recipe_results = irecipe.get_elements(typeobject.results)
    else
        datamodel.recipe_name = ""
        datamodel.recipe_icon = ""
        datamodel.recipe_time = 0
        datamodel.recipe_ingredients = {}
        datamodel.recipe_results = {}
    end

    local storage = gameplay_core.get_storage()
    storage.recipe_picked_flag = storage.recipe_picked_flag or {}

    local typeobject = iprototype.queryById(e.building.prototype)
    local recipes = iprototype_cache.get("recipe_config").assembling_recipes[typeobject.name]

    local cache = {}
    local res = {}
    for _, c in ipairs(RECIPE_CATEGORY) do
        local category_idx = #res+1
        cache[c] = category_idx
        res[category_idx] = {
            category = c,
            recipes = {}
        }
    end

    for _, recipe in ipairs(recipes) do
        if not recipe_unlocked(recipe.name) then
            goto continue
        end

        local category_idx = assert(cache[recipe.recipe_category])
        local recipe_idx = #res[category_idx].recipes+1

        local new = (not storage.recipe_picked_flag[recipe.name]) and true or false
        if datamodel.recipe_name == recipe.name then
            __mark_recipe_flag(datamodel.recipe_name)
            new = false
        end

        local recipe_typeobject = iprototype.queryById(recipe.id)
        res[category_idx].recipes[recipe_idx] = {
            id = ("%s:%s"):format(category_idx, recipe_idx), -- for rml
            name = iprototype.display_name(recipe_typeobject),
            icon = recipe.icon,
            new = new,
            selected = (datamodel.recipe_name == recipe.name) and true or false,
        }
        ::continue::
    end

    datamodel.recipes = {}
    for _, r in ipairs(res) do
        if #r.recipes > 0 then
            table.insert(datamodel.recipes, r)
            for recipe_idx, recipe in ipairs(r.recipes) do
                if recipe.name == datamodel.recipe_name then
                    datamodel.category_idx = #datamodel.recipes
                    datamodel.recipe_idx = recipe_idx
                end
            end
        end
    end

    return datamodel
end

function M.update(datamodel, gameplay_eid)
    for _, _, _, category_idx, recipe_idx in click_recipe_mb:unpack() do
        __set_recipe_value(datamodel, datamodel.category_idx, datamodel.recipe_idx, "selected", false)
        __set_recipe_value(datamodel, category_idx, recipe_idx, "selected", true)
        datamodel.category_idx = category_idx
        datamodel.recipe_idx = recipe_idx

        local recipe_name = datamodel.recipes[category_idx].recipes[recipe_idx].name
        __mark_recipe_flag(recipe_name)
        __set_recipe_value(datamodel, category_idx, recipe_idx, "new", false)

        local typeobject = iprototype.queryByName(recipe_name)
        datamodel.recipe_name = iprototype.display_name(typeobject)
        datamodel.recipe_icon = typeobject.recipe_icon
        datamodel.recipe_time = itypes.time(typeobject.time)
        datamodel.recipe_ingredients = irecipe.get_elements(typeobject.ingredients)
        datamodel.recipe_results = irecipe.get_elements(typeobject.results)

        datamodel.confirm = true
    end

    for _, _, _, item in click_item_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/item_source.html"}, datamodel.recipe_name, datamodel.recipe_icon, datamodel.recipe_time, datamodel.recipe_ingredients, datamodel.recipe_results, datamodel.confirm, item)
    end

    for _ in set_recipe_mb:unpack() do
        local category_idx = datamodel.category_idx
        local recipe_idx = datamodel.recipe_idx
        assert(datamodel.recipes[category_idx])
        assert(datamodel.recipes[category_idx].recipes[recipe_idx])
        local recipe_name = datamodel.recipes[category_idx].recipes[recipe_idx].name

        local e = gameplay_core.get_entity(gameplay_eid)
        local typeobject = iprototype.queryById(e.building.prototype)
        assert(e.assembling)

        if iworld.set_recipe(gameplay_core.get_world(), e, recipe_name, typeobject.recipe_init_limit) then
            gameplay_core.set_changed(CHANGED_FLAG_ASSEMBLING)
            itask.update_progress("set_recipe", recipe_name)
        end

        iui.close("/pkg/vaststars.resources/ui/recipe_config.html")
    end

    for _ in clear_recipe_mb:unpack() do
        local e = gameplay_core.get_entity(gameplay_eid)
        iworld.set_recipe(gameplay_core.get_world(), e, nil)
        gameplay_core.set_changed(CHANGED_FLAG_ASSEMBLING)

        datamodel.category_idx = 0
        datamodel.recipe_idx = 0

        iui.close("/pkg/vaststars.resources/ui/recipe_config.html")
    end
end

return M