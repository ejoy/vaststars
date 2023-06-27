local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local gameplay_core = require "gameplay.core"

local click_category_mb = mailbox:sub {"click_category"}
local set_item_mb = mailbox:sub {"set_item"}
local itask = ecs.require "task"
local item_unlocked = ecs.require "ui_datamodel.common.item_unlocked".is_unlocked
local iprototype_cache = require "gameplay.prototype_cache.init"
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local DIRTY_CHEST <const> = require("gameplay.interface.constant").DIRTY_CHEST

local function __get_categories()
    return iprototype_cache.get("drone_depot").category_cache
end

local function __get_category_index(item_id)
  return assert(iprototype_cache.get("drone_depot").category_index_cache[item_id])
end

local function __get_items(category_index)
    local res = {}
    for _, item in ipairs(iprototype_cache.get("drone_depot").items_cache[category_index]) do
        if item_unlocked(item.name) then
            res[#res+1] = item
        end
    end
    return res
end

local function __get_default_item_indexes()
    local res = {}
    for index in ipairs(iprototype_cache.get("drone_depot").category_cache) do
        res[index] = 1
    end
    return res
end

---------------
local M = {}

function M:create(object_id, interface)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local item = interface.get_first_item(gameplay_core.get_world(), e)
    local category_index, item_indexes
    item_indexes = __get_default_item_indexes()
    if item then
        category_index = __get_category_index(item)
    else
        category_index = 1
    end

    local items = __get_items(category_index)
    if item then
        local item_index
        for index, v in ipairs(items) do
            if v.id == item then
                item_index = index
                break
            end
        end
        item_indexes[category_index] = assert(item_index)
    end

    local datamodel = {
        categories = __get_categories(),
        category_index = category_index,
        items = items,
        item_indexes = item_indexes,
    }
    return datamodel
end

function M:stage_ui_update(datamodel, object_id, interface)
    for _, _, _, catalog_index in click_category_mb:unpack() do
        datamodel.category_index = catalog_index
        datamodel.items = __get_items(catalog_index)
    end

    for _, _, _, item_index in set_item_mb:unpack() do
        local item = __get_items(datamodel.category_index)[item_index]
        local e = gameplay_core.get_entity(assert(objects:get(object_id).gameplay_eid))
        local gameplay_world = gameplay_core.get_world()
        interface.set_first_item(gameplay_world, e, item.id)
        igameplay.dirty(DIRTY_CHEST)

        itask.update_progress("set_item", item.name)
    end
end

return M