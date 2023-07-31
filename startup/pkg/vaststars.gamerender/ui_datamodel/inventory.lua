local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local ITEM_CATEGORY <const> = import_package "vaststars.prototype"("item_category")
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local iBackpack = import_package "vaststars.gameplay".interface "backpack"
local click_item_mb = mailbox:sub {"click_item"}
local close_mb = mailbox:sub {"close"}
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function get_inventory()
    local t = {}
    for _, slot in pairs(iBackpack.all(gameplay_core.get_world())) do
        local typeobject_item = assert(iprototype.queryById(slot.prototype))

        local v = {}
        v.id = typeobject_item.id
        v.name = typeobject_item.name
        v.icon = typeobject_item.icon
        v.category = typeobject_item.item_category
        v.count = slot.amount

        t[v.category] = t[v.category] or {}
        t[v.category][#t[v.category]+1] = v
    end

    for _, items in pairs(t) do
        table.sort(items, function (a, b)
            return a.id < b.id
        end)
    end

    local inventory = {}
    for _, category in ipairs(ITEM_CATEGORY) do
        if t[category] then
            inventory[#inventory+1] = {category = category, items = t[category]}
        end
    end
    return inventory
end

local function set_item_value(datamodel, category_idx, item_idx, key, value)
    if category_idx == 0 and item_idx == 0 then
        return
    end
    assert(datamodel.inventory[category_idx])
    assert(datamodel.inventory[category_idx].items[item_idx])
    datamodel.inventory[category_idx].items[item_idx][key] = value
end

---------------
local M = {}

function M:create()
    return {
        category_idx = 0,
        item_idx = 0,
        item_name = "",
        item_desc = "",
        inventory = get_inventory(),
    }
end

function M:stage_ui_update(datamodel)
    for _, _, _, category_idx, item_idx in click_item_mb:unpack() do
        if datamodel.category_idx == category_idx and datamodel.item_idx == item_idx then
            set_item_value(datamodel, category_idx, item_idx, "selected", false)
            datamodel.category_idx = 0
            datamodel.item_idx = 0 
            datamodel.item_name = ""
            datamodel.item_desc = ""
            datamodel.item_icon = ""
        else
            set_item_value(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)
            set_item_value(datamodel, category_idx, item_idx, "selected", true)
            datamodel.category_idx = category_idx
            datamodel.item_idx = item_idx

            local item_name = datamodel.inventory[category_idx].items[item_idx].name
            local typeobject = iprototype.queryByName(item_name)
            datamodel.item_name = iprototype.display_name(typeobject)
            datamodel.item_desc = typeobject.item_description or ""
            datamodel.item_icon = typeobject.icon
        end
    end

    for _ in close_mb:unpack() do
        iui.close("inventory.rml")
    end

    self:flush()
end

function M:update(datamodel)
    datamodel.inventory = get_inventory()
    self:flush()
end

return M