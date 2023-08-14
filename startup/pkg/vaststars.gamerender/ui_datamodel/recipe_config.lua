local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local set_recipe_mb = mailbox:sub {"set_recipe"}
local click_recipe_mb = mailbox:sub {"click_recipe"}
local clear_recipe_mb = mailbox:sub {"clear_recipe"}
local RECIPE_CATEGORY <const> = import_package "vaststars.prototype"("recipe_category")
local irecipe = require "gameplay.interface.recipe"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"
local objects = require "objects"
local recipe_unlocked = ecs.require "ui_datamodel.common.recipe_unlocked".recipe_unlocked
local itask = ecs.require "task"
local iprototype_cache = require "gameplay.prototype_cache.init"
local CHANGED_FLAG_ASSEMBLING <const> = require("gameplay.interface.constant").CHANGED_FLAG_ASSEMBLING
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

function M:create(object_id)
    local object = assert(objects:get(object_id))
    local e = assert(gameplay_core.get_entity(assert(object.gameplay_eid)))

    local datamodel = {}
    datamodel.object_id = object_id
    datamodel.category_idx = 0
    datamodel.recipe_idx = 0

    if e.assembling.recipe ~= 0 then
        local typeobject = iprototype.queryById(e.assembling.recipe)
        datamodel.recipe_name = typeobject.name
        datamodel.recipe_icon = typeobject.recipe_icon
        datamodel.recipe_time = itypes.time(typeobject.time)
        datamodel.recipe_ingredients = irecipe.get_elements(typeobject.ingredients)
        datamodel.recipe_results = irecipe.get_elements(typeobject.results)
    else
        datamodel.recipe_name = ""
    end

    local storage = gameplay_core.get_storage()
    storage.recipe_picked_flag = storage.recipe_picked_flag or {}

    local object = assert(objects:get(datamodel.object_id))
    local recipes = iprototype_cache.get("recipe_config")[object.prototype_name]

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

    for _, recipe in pairs(recipes) do
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

        res[category_idx].recipes[recipe_idx] = {
            id = ("%s:%s"):format(category_idx, recipe_idx), -- for rml
            name = recipe.name,
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

function M:stage_ui_update(datamodel, object_id)
    for _, _, _, category_idx, recipe_idx in click_recipe_mb:unpack() do
        __set_recipe_value(datamodel, datamodel.category_idx, datamodel.recipe_idx, "selected", false)
        __set_recipe_value(datamodel, category_idx, recipe_idx, "selected", true)
        datamodel.category_idx = category_idx
        datamodel.recipe_idx = recipe_idx

        local recipe_name = datamodel.recipes[category_idx].recipes[recipe_idx].name
        __mark_recipe_flag(recipe_name)
        __set_recipe_value(datamodel, category_idx, recipe_idx, "new", false)

        local typeobject = iprototype.queryByName(recipe_name)
        datamodel.recipe_name = typeobject.name
        datamodel.recipe_icon = typeobject.recipe_icon
        datamodel.recipe_time = itypes.time(typeobject.time)
        datamodel.recipe_ingredients = irecipe.get_elements(typeobject.ingredients)
        datamodel.recipe_results = irecipe.get_elements(typeobject.results)

        datamodel.confirm = true
    end

    for _, _, _, object_id in set_recipe_mb:unpack() do
        local category_idx = datamodel.category_idx
        local recipe_idx = datamodel.recipe_idx
        assert(datamodel.recipes[category_idx])
        assert(datamodel.recipes[category_idx].recipes[recipe_idx])
        local recipe_name = datamodel.recipes[category_idx].recipes[recipe_idx].name

        local object = assert(objects:get(object_id, {"CONSTRUCTED"}))
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        assert(e.assembling)

        if iworld.set_recipe(gameplay_core.get_world(), e, recipe_name, typeobject.recipe_init_limit) then
            -- TODO viewport
            local recipe_typeobject = iprototype.queryByName(recipe_name)
            assert(recipe_typeobject, ("can not found recipe `%s`"):format(recipe_name))

            object.fluid_name = irecipe.get_init_fluids(recipe_typeobject) or {} -- recipe may not have fluid
            object.recipe = recipe_name

            gameplay_core.set_changed(CHANGED_FLAG_ASSEMBLING)

            itask.update_progress("set_recipe", recipe_name)
        end

        iui.close("ui/recipe_config.rml")
    end

    for _ in clear_recipe_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))

        iworld.set_recipe(gameplay_core.get_world(), e, nil)
        object.recipe = ""
        object.fluid_name = {}

        gameplay_core.set_changed(CHANGED_FLAG_ASSEMBLING)

        datamodel.category_idx = 0
        datamodel.recipe_idx = 0

        iui.close("ui/recipe_config.rml")
    end
end

return M