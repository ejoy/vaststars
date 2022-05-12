local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"
local global = require "global"
local objects = global.objects
local cache_names = global.cache_names

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
    }
end

function M:tick(datamodel, object_id)
    local object = assert(objects:get(cache_names, object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    -- 更新背包界面对应的道具
    local inventory = {}
    local item_counts = ichest:item_counts(gameplay_core.get_world(), e)
    for id, count in pairs(item_counts) do
        local typeobject_item = assert(iprototype:query(id))
        local t = {}
        t.name = typeobject_item.name
        t.icon = typeobject_item.icon
        t.count = count
        t.category = typeobject_item.group
        inventory[#inventory+1] = t
    end

    datamodel.inventory = inventory
    return true
end

return M