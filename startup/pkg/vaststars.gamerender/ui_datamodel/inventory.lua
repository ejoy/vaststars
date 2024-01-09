local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local ITEM_CATEGORY <const> = ecs.require "vaststars.prototype|item_category"
local CONSTANT <const> = require "gameplay.interface.constant"
local UPS <const> = CONSTANT.UPS

local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local iinventory = require "gameplay.interface.inventory"
local click_item_mb = mailbox:sub {"click_item"}
local iprototype_cache = ecs.require "prototype_cache"

local function get_items()
    local t = {}
    for _, slot in pairs(iinventory.all(gameplay_core.get_world())) do
        local typeobject_item = assert(iprototype.queryById(slot.item))

        local v = {}
        v.id = typeobject_item.id
        v.name = typeobject_item.name
        v.icon = typeobject_item.item_icon
        v.count = slot.amount
        v.order = typeobject_item.item_order or 0

        local category = typeobject_item.item_category or error(("`%s` item_category is nil"):format(typeobject_item.name))
        t[category] = t[category] or {}
        t[category][#t[category]+1] = v
    end

    for _, items in pairs(t) do
        table.sort(items, function (a, b)
            return a.order < b.order
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

local function _power_conversion(n)
    if not n then
        return ""
    end
    n = n * UPS

    local postfix = ''
    if n >= 1000000000 then
        n = n / 1000000000
        postfix = 'GW'
    elseif n >= 1000000 then
        n = n / 1000000
        postfix = 'MW'
    elseif n >= 1000 then
        n = n / 1000
        postfix = 'kW'
    end
    return math.ceil(n) .. postfix
end

local function _speed_conversion(n)
    if not n then
        return ""
    end
    return math.floor(n * 100) .. '%'
end

---------------
local M = {}

function M.create()
    return {
        category_idx = 0,
        item_idx = 0,
        item_name = "",
        item_desc = "",
        item_ingredients = {},
        item_assembling = {},
        inventory = get_items(),
        power = "",
        speed = "",
    }
end

function M.update(datamodel)
    for _, _, _, category_idx, item_idx in click_item_mb:unpack() do
        if datamodel.category_idx == category_idx and datamodel.item_idx == item_idx then
            set_item_value(datamodel, category_idx, item_idx, "selected", false)
            datamodel.category_idx = 0
            datamodel.item_idx = 0 
            datamodel.item_name = ""
            datamodel.item_desc = ""
            datamodel.item_icon = ""
            datamodel.item_ingredients = {}
            datamodel.item_assembling = {}
            datamodel.power = ""
            datamodel.speed = ""
        else
            set_item_value(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)
            set_item_value(datamodel, category_idx, item_idx, "selected", true)
            datamodel.category_idx = category_idx
            datamodel.item_idx = item_idx

            local item_name = datamodel.inventory[category_idx].items[item_idx].name
            local typeobject = iprototype.queryByName(item_name)
            datamodel.item_name = iprototype.display_name(typeobject)
            datamodel.item_desc = typeobject.item_description or ""
            datamodel.item_icon = typeobject.item_icon

            datamodel.item_ingredients = {}
            for _, v in pairs(iprototype_cache.get("item_ingredients").item_ingredients[item_name] or {}) do
                local typeobject = assert(iprototype.queryById(v.id))
                local t = {
                    name = iprototype.display_name(typeobject),
                    icon = typeobject.item_icon,
                    count = v.count,
                }
                datamodel.item_ingredients[#datamodel.item_ingredients+1] = t
            end

            datamodel.item_assembling = {}
            for _, name in pairs(iprototype_cache.get("item_ingredients").item_assembling[item_name] or {}) do
                local typeobject = assert(iprototype.queryByName(name))
                local t = {
                    icon = typeobject.icon,
                    name = iprototype.display_name(typeobject),
                }
                datamodel.item_assembling[#datamodel.item_assembling+1] = t
            end

            datamodel.power = _power_conversion(typeobject.power)
            datamodel.speed = _speed_conversion(typeobject.speed)
        end
    end
end

return M