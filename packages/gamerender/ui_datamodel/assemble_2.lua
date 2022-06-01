local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local objects = require "objects"
local ichest = require "gameplay.interface.chest"
local gameplay_core = require "gameplay.core"
local math_max = math.max

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function get(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    local typeobject = iprototype:query(e.entity.prototype)
    local recipe_typeobject = iprototype:query(e.assembling.recipe)
    if not recipe_typeobject then
        return {
            object_id = object_id,
            prototype_name = iprototype:show_prototype_name(typeobject),
            background = typeobject.background,
            recipe_name = "",
            recipe_ingredients = {},
            recipe_results = {},
            recipe_ingredients_count = {},
            recipe_results_count = {},
        }
    end

    local recipe_ingredients = irecipe:get_elements(recipe_typeobject.ingredients)
    local recipe_results = irecipe:get_elements(recipe_typeobject.results)

    local recipe_ingredients_count = {}
    for index, v in ipairs(recipe_ingredients) do
        recipe_ingredients_count[index] = {icon = v.icon, count = 0, need_count = v.count}
    end

    local recipe_results_count = {}
    for index, v in ipairs(recipe_results) do
        recipe_results_count[index] = {icon = v.icon, count = 0, need_count = v.count}
    end

    return {
        object_id = object_id,
        prototype_name = iprototype:show_prototype_name(typeobject),
        background = typeobject.background,
        recipe_name = recipe_typeobject.name,
        recipe_ingredients = recipe_ingredients,
        recipe_results = recipe_results,
        recipe_ingredients_count = recipe_ingredients_count,
        recipe_results_count = recipe_results_count,
    }
end

local function get_percent(progress, total)
    assert(progress <= total)
    progress = math_max(progress, 0)
    return (total - progress) / total
end

---------------
local M = {}

function M:create(object_id)
    return get(object_id)
end

function M:stage_ui_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    -- 更新组装机 成分 与 产出材料 的显示个数
    -- 组装机箱子里已有个数 / 配方所需个数
    local assembling = e.assembling
    local total_progress = 0
    local progress = 0

    if assembling.recipe ~= 0 then
        local recipe_typeobject = assert(iprototype:query(assembling.recipe))
        total_progress = recipe_typeobject.time * 100
        progress = assembling.progress
    end

    local recipe_ingredients_count = {}
    local recipe_results_count = {}
    if e.assembling.container ~= 0xFFFF then
        for index, v in ipairs(datamodel.recipe_ingredients) do
            local c, n = gameplay_core.get_world():container_get(e.assembling.container, index)
            if c then
                recipe_ingredients_count[index] = {icon = v.icon, count = n, need_count = v.count}
            else
                recipe_ingredients_count[index] = {icon = v.icon, count = 0, need_count = v.count}
            end
        end

        for index, v in ipairs(datamodel.recipe_results) do
            local c, n = gameplay_core.get_world():container_get(e.assembling.container, #datamodel.recipe_ingredients + index)
            if c then
                recipe_results_count[index] = {icon = v.icon, count = n, need_count = v.count}
            else
                recipe_results_count[index] = {icon = v.icon, count = 0, need_count = v.count}

            end
        end
    end

    datamodel.recipe_ingredients_count = recipe_ingredients_count
    datamodel.recipe_results_count = recipe_results_count

    if assembling.status == STATUS_IDLE then
        datamodel.progress = "0%"
    else
        datamodel.progress = ("%0.0f%%"):format(get_percent(progress, total_progress) * 100)
    end

    -- 更新背包界面对应的道具
    for e in gameplay_core.select "chest:in entity:in" do
        local typeobject = iprototype:query(e.entity.prototype)
        if typeobject.headquater then
            local inventory = {}
            local item_counts = ichest:item_counts(gameplay_core.get_world(), e)
            for id, count in pairs(item_counts) do
                local typeobject_item = assert(iprototype:query(id))
                local t = {}
                t.name = typeobject_item.name
                t.icon = typeobject_item.icon
                t.count = count
                inventory[#inventory+1] = t
            end
            datamodel.inventory = inventory
            break
        end
    end
end

function M:update(datamodel, object_id)
    for k, v in pairs(get(object_id)) do
        datamodel[k] = v
    end
    self:flush()
end

return M