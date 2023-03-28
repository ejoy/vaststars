local ecs, mailbox = ...
local iUiRt     = ecs.import.interface "ant.rmlui|iuirt"
local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local objects = require "objects"
local irecipe = require "gameplay.interface.recipe"
local click_item_mb = mailbox:sub {"click_item"}
local close_chestui_mb = mailbox:sub {"close_chestui"}
local mt = {}
function mt:__index(k)
    self[k] = {}
    return self[k]
end
local item_crafting_recipe = setmetatable({}, mt)   -- item id -> crafting recipe info
local item_crafting_entities = setmetatable({}, mt) -- item id -> crafting entity info
local category_to_entities = setmetatable({}, mt)

for _, typeobject in pairs(iprototype.each_type("building", "assembling")) do
    if typeobject.recipe then -- default recipe
        local typeobject_recipe = assert(iprototype.queryByName(typeobject.recipe))
        category_to_entities[typeobject_recipe.category][typeobject.id] = {icon = typeobject.icon, name = typeobject.name}
    else
        if not typeobject.craft_category then
            if not typeobject.mining_category then
                log.error(("%s dont have craft_category"):format(typeobject.name))
            end
        else
            for _, craft_category in ipairs(typeobject.craft_category) do
                category_to_entities[craft_category][typeobject.id] = {icon = typeobject.icon, name = typeobject.name}
            end
        end
    end
end

local function _has_type(prototype, type)
    local typeobject = assert(iprototype.queryById(prototype))
    return iprototype.has_type(typeobject.type, type)
end

for _, typeobject in pairs(iprototype.each_type("recipe")) do
    for idx, element in ipairs(itypes.items(typeobject.results)) do
        if not _has_type(element.id, "item") then
            goto continue
        end

        local id = element.id
        table.insert(item_crafting_recipe[id], {
            icon = assert(typeobject.recipe_icon),
            element = irecipe.get_elements(typeobject.ingredients),
            time = itypes.time(typeobject.time),
            weight = idx, -- display the first result first
            recipe_name = typeobject.name, -- for debug
        })

        for entity_prototype, v in pairs(category_to_entities[typeobject.category]) do
            item_crafting_entities[id][entity_prototype] = v
        end
        ::continue::
    end
end

local function _limit(list, top)
    table.sort(list, function(a, b) return a.weight < b.weight end)
    local result = {}
    table.move(list, 1, top, 1, result)
    return result
end

for idx, item_info in pairs(item_crafting_recipe) do
    item_crafting_recipe[idx] = _limit(item_info, 5)
end

for id, entity_info in pairs(item_crafting_entities) do
    local result = {}
    local c = 0
    for _, v in pairs(entity_info) do -- TODO: display all entities
        table.insert(result, v)
        c = c + 1
        if c >= 4 then
            break
        end
    end
    item_crafting_entities[id] = result
end

local function get_inventory(object_id)
    local inventory = {}
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return inventory
    end

    for _, slot in pairs(ichest.collect_item(gameplay_core.get_world(), e)) do
        if slot.item == 0 then -- TODO: fix this
            goto continue
        end
        local typeobject_item = assert(iprototype.queryById(slot.item))
        local stack = slot.amount

        while stack > 0 do
            local t = {}
            t.id = typeobject_item.id
            t.name = typeobject_item.name
            t.icon = typeobject_item.icon
            t.category = typeobject_item.group[1] -- currently, items will only have one category, which is used for displaying in the inventory.

            if stack >= typeobject_item.stack then
                t.count = typeobject_item.stack
            else
                t.count = stack
            end

            inventory[#inventory+1] = t
            stack = stack - typeobject_item.stack
        end
        ::continue::
    end
    return inventory
end

local function update(datamodel, object_id)
    datamodel.inventory = get_inventory(object_id)
end

---------------
local M = {}
local rt_model_path-- = "/pkg/vaststars.resources/glb/drone.glb|mesh.prefab"
local rt_exist = false
local rt_name = "chest_model"
function M:create(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    local filename = typeobject.model:match("^.+/(.+).prefab$")
    rt_model_path = "/pkg/vaststars.resources/glb/"..filename..".glb|mesh.prefab"
    return {
        object_id = object_id, -- for update
        prototype_name = iprototype.show_prototype_name(typeobject),
        item_category = item_category,
        inventory = get_inventory(object_id),
        item_prototype_name = "",
        max_slot_count = typeobject.slots,
    }
end

function M:stage_ui_update(datamodel)
    local gid = iUiRt.get_group_id(rt_name)
    if gid and not rt_exist then
        rt_exist = true
        local focus_entity_scale = {0.1, 0.1, 0.1}
        iUiRt.create_new_rt(rt_name, rt_model_path, "vaststars", focus_entity_scale)
    end
    for _, _, _, prototype in click_item_mb:unpack() do
        local typeobject = iprototype.queryById(prototype)
        datamodel.show_item_info = true
        datamodel.item_prototype_name = iprototype.show_prototype_name(typeobject)
        datamodel.item_info = item_crafting_recipe[tonumber(prototype)] or {}
        datamodel.entities = item_crafting_entities[tonumber(prototype)] or {}
        self:flush()
    end

    update(datamodel, datamodel.object_id) -- TODO
    self:flush()

    for _, _, _ in close_chestui_mb:unpack() do
        if rt_exist then
            iUiRt.close_ui_rt(rt_name)
            rt_exist = false
        end
    end
end

function M:update(datamodel)
    update(datamodel, datamodel.object_id)
    self:flush()
end

return M