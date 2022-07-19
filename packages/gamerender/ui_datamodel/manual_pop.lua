local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local gameplay_core = require "gameplay.core"
local imanual = require "gameplay.interface.manual"
local manual_add_mb = mailbox:sub {"manual_add"}
local check_material_mb = mailbox:sub {"check_material"}
local click_category_mb = mailbox:sub {"click_category"}
local recipe_category_cfg = import_package "vaststars.prototype"("recipe_category")
local irecipe = require "gameplay.interface.recipe"
local click_recipe_mb = mailbox:sub {"click_recipe"}
local recipe_unlocked = ecs.require "ui_datamodel.common.recipe_unlocked".recipe_unlocked

local function _has_fluid_output(s)
    for _, v in ipairs(itypes.items(s)) do
        if iprototype.is_fluid_id(v.id) then
            return true
        end
    end
    return false
end

-- prototype.recipe_category.group -> the category of ui
local recipes = {} ; local get_recipe_index; do
    local check = {}
    for _, v in pairs(iprototype.each_maintype "recipe") do
        if v.allow_manual == false then
            goto continue
        end

        if _has_fluid_output(v.ingredients) or _has_fluid_output(v.results) then
            goto continue
        end

        if v.group then -- if group is not nil, need to add to the category of ui
            local recipe_item = {
                name = v.name,
                order = v.order,
                icon = v.icon,
                time = v.time,
                ingredients = irecipe.get_elements(v.ingredients),
                results = irecipe.get_elements(v.results),
                group = v.group,
            }

            if v.allow_as_intermediate ~= false then
                local mainoutput = recipe_item.results[1].name
                assert(not check[mainoutput], ("duplicate main output id: %s "):format(mainoutput, check[mainoutput]))
                check[mainoutput] = v.name
            end

            recipes[v.group] = recipes[v.group] or {}
            recipes[v.group][#recipes[v.group] + 1] = recipe_item
        end
        ::continue::
    end

    for _, v in pairs(recipes) do
        table.sort(v, function(a, b)
            return a.order < b.order
        end)
    end

    local function _get_group_index(group)
        for index, category_set in ipairs(recipe_category_cfg) do
            if category_set.group == group then
                return index
            end
        end
        assert(false, ("group `%s` not found"):format(group))
    end

    --
    local cache = {}
    for _, c in pairs(recipes) do
        for index, recipe in ipairs(c) do
            cache[recipe.name] = {_get_group_index(recipe.group), index}
        end
    end
    -- recipe_name -> {category_index, recipe_index}
    function get_recipe_index(name)
        assert(cache[name], ("can not find recipe `%s`"):format(name))
        return table.unpack(cache[name])
    end
end

local function _update_recipe_items(datamodel, recipe_name)
    local storage = gameplay_core.get_storage()
    storage.recipe_new_flag = storage.recipe_new_flag or {}

    local cur_recipe_category_cfg = assert(recipe_category_cfg[datamodel.category_index])

    -- if recipe_name is nil, get the first unlocked recipe
    if not recipe_name then
        for _, recipe in ipairs(recipes[cur_recipe_category_cfg.group] or {}) do
            if recipe_unlocked(recipe.name) then
                recipe_name = recipe.name
                break
            end
        end
    end
    -- if recipe_name is nil, it means all recipes are locked or the category is empty
    if recipe_name then
        storage.recipe_new_flag = storage.recipe_new_flag or {}
        storage.recipe_new_flag[recipe_name] = true
    end

    datamodel.recipe_items = {}
    datamodel.recipe_name = " "
    datamodel.recipe_ingredients = {}
    datamodel.recipe_results = {}

    local recipe_category_new_flag = {}
    for group, recipe_set in pairs(recipes) do
        for _, recipe_item in ipairs(recipe_set) do
            if recipe_unlocked(recipe_item.name) then
                local new_recipe_flag = (not storage.recipe_new_flag[recipe_item.name]) and true or false

                if group == cur_recipe_category_cfg.group then
                    datamodel.recipe_items[#datamodel.recipe_items+1] = {
                        name = recipe_item.name,
                        icon = recipe_item.icon,
                        time = recipe_item.time,
                        ingredients = recipe_item.ingredients,
                        results = recipe_item.results,
                        new = new_recipe_flag,
                    }
                end

                if recipe_name and recipe_name == recipe_item.name then
                    datamodel.recipe_name = recipe_item.name
                    datamodel.recipe_ingredients = recipe_item.ingredients
                    datamodel.recipe_results = recipe_item.results
                end

                if new_recipe_flag then
                    recipe_category_new_flag[group] = true
                end
            end
        end
    end

    datamodel.recipe_category = {}
    for _, category in ipairs(recipe_category_cfg) do
        datamodel.recipe_category[#datamodel.recipe_category+1] = {
            group = category.group,
            icon = category.icon,
            new = recipe_category_new_flag[category.group] ~= nil and true or false,
        }
    end
end

local solver = imanual.create()

local M = {}
function M:create()
    local datamodel = {}
    datamodel.category_index = 1
    datamodel.recipe_index = 1 -- recipe_index is the index of recipe_items[caterory], default is 1

    _update_recipe_items(datamodel)
    return datamodel
end

function M:stage_ui_update(datamodel)
    for _, _, _, name, count in manual_add_mb:unpack() do
        local t = gameplay_core.get_world():manual()
        local output = imanual.evaluate(solver, gameplay_core.manual_chest(), gameplay_core.get_world():manual_container(), {{name, count}})
        if not output then
            log.error("material shortages")
        else
            table.move(output, 1, #output, #t + 1, t)
            gameplay_core.get_world():manual(t)
        end
        world:pub {"manual_add", name, count}
    end

    for _, _, _, name, count in check_material_mb:unpack() do
        local output = imanual.evaluate(solver, gameplay_core.manual_chest(), gameplay_core.get_world():manual_container(), {{name, count}})
        if not output then
            datamodel.material_shortages = true
        else
            datamodel.material_shortages = false
        end
    end

    for _, _, _, category_index in click_category_mb:unpack() do
        datamodel.category_index = category_index
        datamodel.recipe_index = 1 -- recipe_index is the index of recipe_items[caterory], default is 1
        _update_recipe_items(datamodel)
    end

    for _, _, _, recipe_name in click_recipe_mb:unpack() do
        local storage = gameplay_core.get_storage()
        storage.recipe_new_flag = storage.recipe_new_flag or {}
        storage.recipe_new_flag[recipe_name] = true
        datamodel.recipe_name = recipe_name
        datamodel.catalog_index, datamodel.recipe_index = get_recipe_index(datamodel.recipe_name)
        _update_recipe_items(datamodel, recipe_name)
    end
end

return M