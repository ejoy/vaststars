local item_category = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local iworld = require "gameplay.interface.world"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"

---------------
local M = {}

function M:create()
    return {
        item_category = item_category,
        inventory = {},
    }
end

function M:tick(datamodel)
    -- 更新背包界面对应的道具
    local e = iworld:get_headquater_entity(gameplay_core.get_world())
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