local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local global = require "global"
local objects = global.objects
local cache_names = global.cache_names
local ichest = require "gameplay.interface.chest"
local gameplay_core = require "gameplay.core"

local function get(object_id, recipe_name)
    local recipe_typeobject = iprototype:queryByName("recipe", recipe_name)
    if not recipe_typeobject then
        return {
            object_id = object_id,
            recipe_name = recipe_name,
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
        recipe_name = recipe_name,
        recipe_ingredients = recipe_ingredients,
        recipe_results = recipe_results,
        recipe_ingredients_count = recipe_ingredients_count,
        recipe_results_count = recipe_results_count,
    }
end

local function get_percent(process, total)
    assert(process <= total)
    if total <= 0 then
        return 0
    end

    if process < 0 then
        process = 0
    end
    return (total - process) / total
end

local function create(object_id, recipe_name)
    return get(object_id, recipe_name)
end

local function update(datamodel, param, object_id, recipe_name)
    if param[1] ~= object_id then
        return
    end

    for k, v in pairs(get(object_id, recipe_name)) do
        datamodel[k] = v
    end
    return true
end

local function tick(datamodel, param)
    local object_id = param[1]
    local object = assert(objects:get(cache_names, object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return {}
    end

    -- 更新组装机 成分 与 产出材料 的显示个数
    -- 组装机箱子里已有个数 / 配方所需个数
    local assembling = e.assembling
    local total_process = 0
    if assembling.recipe ~= 0 then
        local recipe_typeobject = assert(iprototype:query(assembling.recipe))
        total_process = recipe_typeobject.time * assembling.speed
    end

    local recipe_ingredients_count = {}
    for index, v in ipairs(datamodel.recipe_ingredients) do
        local c, n = gameplay_core.get_world():container_get(e.assembling.container, index)
        if c then
            recipe_ingredients_count[index] = {icon = v.icon, count = n, need_count = v.count}
        else
            recipe_ingredients_count[index] = {icon = v.icon, count = 0, need_count = v.count}
        end
    end

    local recipe_results_count = {}
    for index, v in ipairs(datamodel.recipe_results) do
        local c, n = gameplay_core.get_world():container_get(e.assembling.container, #datamodel.recipe_ingredients + index)
        if c then
            recipe_results_count[index] = {icon = v.icon, count = n, need_count = v.count}
        else
            recipe_results_count[index] = {icon = v.icon, count = 0, need_count = v.count}

        end
    end

    datamodel.recipe_ingredients_count = recipe_ingredients_count
    datamodel.recipe_results_count = recipe_results_count
    datamodel.process = ("%0.0f%%"):format(get_percent(assembling.process, total_process) * 100)

    -- 更新背包界面对应的道具个数
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

    return true
end

return {
    create = create,
    update = update,
    tick = tick,
}