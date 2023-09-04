local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local set_item_mb = mailbox:sub {"set_item"}
local click_slot_mb = mailbox:sub {"click_slot"}
local click_set_item_mb = mailbox:sub {"click_set_item"}
local cancel_set_item_mb = mailbox:sub {"cancel_set_item"}
local remove_slot_mb = mailbox:sub {"remove_slot"}
local itask = ecs.require "task"
local item_unlocked = ecs.require "ui_datamodel.common.item_unlocked".is_unlocked
local ITEM_CATEGORY <const> = import_package "vaststars.prototype"("item_category")
local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"

---------------
local M = {}

local function updateSlots(e, datamodel)
    local typeobject = iprototype.queryById(e.building.prototype)
    local gameplay_world = gameplay_core.get_world()
    local max_slot = ichest.get_max_slot(typeobject)
    local slots = {}
    local existing = {}

    for i = 1, max_slot do
        local slot = gameplay_world:container_get(e.station, i)
        if not slot then
            break
        end

        if slot.item ~= 0 then
            local typeobject_item = assert(iprototype.queryById(slot.item))
            slots[#slots + 1] = {slot_index = i, icon = typeobject_item.item_icon, name = typeobject_item.name, type = slot.type, remove = false}
            existing[slot.item] = true
        end
    end
    datamodel.disable = (#slots == max_slot)

    for i = #slots + 1, max_slot do
        slots[#slots + 1] = {slot_index = i, icon = "", name = "", type = ""}
    end
    table.sort(slots, function(a, b)
        local v1 = a.type == "supply" and 0 or 1
        local v2 = b.type == "supply" and 0 or 1
        return v1 == v2 and a.slot_index < b.slot_index or v1 < v2
    end)
    datamodel.slots = slots

    return existing
end

local function updateItems(datamodel, existing)
    local storage = gameplay_core.get_storage()
    storage.item_picked_flag = storage.item_picked_flag or {}

    local cache = {}
    local res = {}
    for _, c in ipairs(ITEM_CATEGORY) do
        local category_idx = #res+1
        cache[c] = category_idx
        res[category_idx] = {
            category = c,
            items = {}
        }
    end

    for _, typeobject in pairs(iprototype.each_type("item")) do
        -- If the 'item_category' field is not configured, it usually means that it cannot be placed on this building through settings.
        -- For certain special items, such as "任务" the item category is configured as ''.
        if not (typeobject.item_category and typeobject.item_category ~= '') then
            goto continue
        end

        if not item_unlocked(typeobject.name) then
            goto continue
        end

        if existing[typeobject.id] then
            goto continue
        end

        local category_idx = assert(cache[typeobject.item_category])
        local items = res[category_idx].items
        items[#items+1] = {
            name = typeobject.name,
            icon = typeobject.item_icon,
            new = (not storage.item_picked_flag[typeobject.name]) and true or false,
            selected = false,
            order = typeobject.item_order,
        }
        ::continue::
    end

    local items = {}
    for category_idx, r in ipairs(res) do
        if #r.items > 0 then
            table.sort(r.items, function(a, b)
                return a.order < b.order
            end)

            for item_idx, item in ipairs(r.items) do
                item.id = ("%s:%s"):format(category_idx, item_idx)
            end

            table.insert(items, r)
        end
    end
    datamodel.items = items
end

function M:create(gameplay_eid, interface)
    local datamodel = {
        show_set_item = false,
        set_type = "",
        disable = true,
    }

    local e = assert(gameplay_core.get_entity(gameplay_eid))

    local existing = updateSlots(e, datamodel)
    updateItems(datamodel, existing)

    datamodel.supply_button = interface.supply_button
    datamodel.demand_button = interface.demand_button
    return datamodel
end

function M:stage_ui_update(datamodel, gameplay_eid, interface)
    for _, _, _, category_idx, item_idx, set_type in set_item_mb:unpack() do
        assert(datamodel.items[category_idx])
        assert(datamodel.items[category_idx].items[item_idx])
        local name = datamodel.items[category_idx].items[item_idx].name
        local typeobject = assert(iprototype.queryByName(name))
        local e = gameplay_core.get_entity(gameplay_eid)
        local gameplay_world = gameplay_core.get_world()
        interface.set_item(gameplay_world, e, set_type, typeobject.id)
        itask.update_progress("set_item", name)

        local existing = updateSlots(e, datamodel)
        updateItems(datamodel, existing)

        datamodel.show_set_item = false
        datamodel.set_type = ""
    end

    for _, _, _, idx in click_slot_mb:unpack() do
        local slot = assert(datamodel.slots[idx])
        if slot.name ~= "" then
            slot.remove = true
        end
    end

    for _, _, _, type in click_set_item_mb:unpack() do
        datamodel.show_set_item = true
        datamodel.set_type = type
    end

    for _ in cancel_set_item_mb:unpack() do
        datamodel.show_set_item = false
    end

    for _, _, _, idx in remove_slot_mb:unpack() do
        local slot = assert(datamodel.slots[idx])
        local e = gameplay_core.get_entity(gameplay_eid)
        local gameplay_world = gameplay_core.get_world()
        interface.remove_item(gameplay_world, e, slot.slot_index)

        local existing = updateSlots(e, datamodel)
        updateItems(datamodel, existing)
    end
end

return M