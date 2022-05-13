local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"
local global = require "global"
local objects = global.objects
local cache_names = global.cache_names
local irecipe = require "gameplay.interface.recipe"
local clickitem_mb = mailbox:sub {"click_item"}

local item_id_to_info = {}
local recipe_to_category = {}
local category_to_entity = {}
for _, typeobject in pairs(iprototype:all_prototype_name()) do
    if iprototype:has_type(typeobject.type, "recipe") then
        for _, element in ipairs(irecipe:get_elements(typeobject.results)) do
            local typeobject_element = assert(iprototype:query(element.id))
            if iprototype:has_type(typeobject_element.type, "item") then
                local id = typeobject_element.id
                item_id_to_info[id] = item_id_to_info[id] or {}
                item_id_to_info[id][#item_id_to_info[id]+1] = {icon = typeobject.icon, element = irecipe:get_elements(typeobject.results), recipe_id = typeobject.id}
            end
        end
        recipe_to_category[typeobject.id] = typeobject.category
    end

    if iprototype:has_type(typeobject.type, "assembling") then
        if typeobject.recipe then -- 固定配方的组装机
            local typeobject_recipe = assert(iprototype:queryByName("recipe", typeobject.recipe))
            category_to_entity[typeobject_recipe.category] = category_to_entity[typeobject_recipe.category] or {}
            table.insert(category_to_entity[typeobject_recipe.category], {id = typeobject.id, icon = typeobject.icon})
        else
            if not typeobject.craft_category then
                log.error(("%s dont have craft_category"):format(typeobject.name))
            end
            for _, craft_category in ipairs(typeobject.craft_category or {}) do
                category_to_entity[craft_category] = category_to_entity[craft_category] or {}
                table.insert(category_to_entity[craft_category], {id = typeobject.id, icon = typeobject.icon})
            end
        end
    end
end

for _, item_info in pairs(item_id_to_info) do
    for _, recipe_info in ipairs(item_info) do
        local recipe_id = recipe_info.recipe_id
        local category = recipe_to_category[recipe_id]
        if category then
            recipe_info.entities = category_to_entity[category] or {}
        end
        recipe_info.recipe_id = nil
    end
end

---------------
local M = {}

function M:create(object_id)
    local object = assert(objects:get(cache_names, object_id))
    local typeobject = iprototype:queryByName("entity", object.prototype_name)

    return {
        item_category = item_category,
        inventory = {},
        prototype_name = object.prototype_name,
        is_headquater = typeobject.headquater,
        item_id_to_info = {},
    }
end

function M:tick(datamodel, object_id)
    local object = assert(objects:get(cache_names, object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if e then
        -- 更新背包界面对应的道具
        local inventory = {}
        local item_counts = ichest:item_counts(gameplay_core.get_world(), e)
        for id, count in pairs(item_counts) do
            local typeobject_item = assert(iprototype:query(id))
            local t = {}
            t.id = typeobject_item.id
            t.name = typeobject_item.name
            t.icon = typeobject_item.icon
            t.count = count
            t.category = typeobject_item.group
            inventory[#inventory+1] = t
        end

        datamodel.inventory = inventory
    end
end

function M:stage_ui_update(datamodel)
    for _, _, _, prototype in clickitem_mb:unpack() do
        datamodel.show_item_info = true
        datamodel.item_info = item_id_to_info[tonumber(prototype)] or {}
        self:flush()
    end
end

return M