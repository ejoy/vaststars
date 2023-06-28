local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local objects = require "objects"
local irecipe = require "gameplay.interface.recipe"
local click_item_mb = mailbox:sub {"click_item"}
local to_chest_mb = mailbox:sub {"to_chest"}
local to_headquater_mb = mailbox:sub {"to_headquater"}
local iworld = require "gameplay.interface.world"
local iBackpack = import_package "vaststars.gameplay".interface "backpack"

local item_id_to_info = {}
local recipe_to_category = {}
local category_to_entity = {}
for _, typeobject in pairs(iprototype.each_type("recipe")) do
    for _, element in ipairs(irecipe.get_elements(typeobject.results)) do
        local typeobject_element = assert(iprototype.queryById(element.id))
        if iprototype.has_type(typeobject_element.type, "item") then
            local id = typeobject_element.id
            item_id_to_info[id] = item_id_to_info[id] or {}
            item_id_to_info[id][#item_id_to_info[id]+1] = {icon = assert(typeobject.recipe_icon), element = irecipe.get_elements(typeobject.ingredients), recipe_id = typeobject.id, time = itypes.time(typeobject.time)}
        end
    end
    recipe_to_category[typeobject.id] = typeobject.category
end

for _, typeobject in pairs(iprototype.each_type("building")) do
    if iprototype.has_type(typeobject.type, "assembling") then
        if typeobject.recipe then -- 固定配方的组装机
            local typeobject_recipe = assert(iprototype.queryByName(typeobject.recipe))
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

local function get_inventory(object_id)
    local inventory = {}
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if e then
        for _, slot in pairs(iBackpack.all()) do
            local typeobject_item = assert(iprototype.queryById(slot.item))

            local t = {}
            t.id = typeobject_item.id
            t.name = typeobject_item.name
            t.icon = typeobject_item.icon
            t.category = typeobject_item.group
            t.count = slot.amount
            inventory[#inventory+1] = t
        end
    end
    return inventory
end

local function update(datamodel, object_id)
    datamodel.inventory = get_inventory(object_id)
end

---------------
local M = {}

function M:create(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)

    return {
        object_id = object_id, -- for update
        prototype_name = iprototype.show_prototype_name(typeobject),
        background = typeobject.background,
        item_category = item_category,
        inventory = get_inventory(object_id),
        is_headquater = (typeobject.headquater == true),
        item_prototype_name = "",
        max_slot_count = typeobject.slots,
    }
end

function M:stage_ui_update(datamodel)
    for _, _, _, prototype in click_item_mb:unpack() do
        local typeobject = iprototype.queryById(prototype)
        datamodel.show_item_info = true
        datamodel.item_prototype_name = iprototype.show_prototype_name(typeobject)
        datamodel.item_info = item_id_to_info[tonumber(prototype)] or {}
        self:flush()
    end

    for _, _, _, chest_object_id, prototype in to_chest_mb:unpack() do
        local headquater_item_counts = iworld.inventory(gameplay_core.get_world())
        if not headquater_item_counts[prototype] then
            log.info(("can not found item `%s`"):format(prototype))
            goto continue
        end

        local chest_object = objects:get(chest_object_id)
        if not chest_object then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local chest_e = gameplay_core.get_entity(chest_object.gameplay_eid)
        if not chest_e then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local items = ichest.collect_item(gameplay_core.get_world(), chest_e)
        if not items[prototype] then
            log.info(("can not found item `%s`"):format(prototype))
            goto continue
        end

        --
        local typeobject_item = iprototype.queryById(prototype)
        if ichest.get_amount(items[prototype]) >= typeobject_item.stack then
            log.info(("stack `%s`"):format(typeobject_item.stack))
            goto continue
        end

        local pickup_count = math.min(typeobject_item.stack - ichest.get_amount(items[prototype]), headquater_item_counts[prototype])
        iworld.base_container_pickup_place(gameplay_core.get_world(), chest_e, prototype, pickup_count, true)
        self:flush()
        ::continue::
    end

    for _, _, _, chest_object_id, prototype in to_headquater_mb:unpack() do
        local chest_object = objects:get(chest_object_id)
        if not chest_object then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local chest_e = gameplay_core.get_entity(chest_object.gameplay_eid)
        if not chest_e then
            log.error(("can not found chest `%s`"):format(chest_object_id))
            goto continue
        end

        local items = ichest.collect_item(gameplay_core.get_world(), chest_e)
        if not items[prototype] then
            log.info(("can not found item `%s`"):format(prototype))
            goto continue
        end

        local typeobject_item = iprototype.queryById(prototype)
        local pickup_count = math.min(typeobject_item.stack, ichest.get_amount(items[prototype]))

        iworld.base_container_pickup_place(gameplay_core.get_world(), chest_e, prototype, pickup_count, false)
        self:flush()
        ::continue::
    end

    update(datamodel, datamodel.object_id) -- TODO
    self:flush()
end

function M:update(datamodel)
    update(datamodel, datamodel.object_id)
    self:flush()
end

return M