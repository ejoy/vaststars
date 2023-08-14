local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local gameplay_core = require "gameplay.core"

local click_item_mb = mailbox:sub {"click_item"}
local set_item_mb = mailbox:sub {"set_item"}
local itask = ecs.require "task"
local item_unlocked = ecs.require "ui_datamodel.common.item_unlocked".is_unlocked
local ITEM_CATEGORY <const> = import_package "vaststars.prototype"("item_category")
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.require "engine.system.ui_system"

local function __set_item_value(datamodel, category_idx, item_idx, key, value)
    if category_idx == 0 and item_idx == 0 then
        return
    end
    assert(datamodel.items[category_idx])
    assert(datamodel.items[category_idx].items[item_idx])
    datamodel.items[category_idx].items[item_idx][key] = value
end

local function __mark_item_flag(item_name)
    local storage = gameplay_core.get_storage()
    storage.item_picked_flag = storage.item_picked_flag or {}
    storage.item_picked_flag[item_name] = true
end

---------------
local M = {}

function M:create(object_id, interface)
    local datamodel = {}
    datamodel.category_idx = 0
    datamodel.item_idx = 0

    local object = assert(objects:get(object_id))
    local e = assert(gameplay_core.get_entity(assert(object.gameplay_eid)))
    local item = interface.get_item(gameplay_core.get_world(), e)
    if item and item ~= 0 then
        local typeobject = assert(iprototype.queryById(item))
        datamodel.item_name = typeobject.name
        datamodel.item_icon = typeobject.item_icon
        datamodel.item_desc = typeobject.item_description
    end

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
        -- If the 'pile' field is not configured, it is usually a 'building' that cannot be placed in a drone depot.
        if not (typeobject.pile and typeobject.item_category ~= '') then
            goto continue
        end

        if not item_unlocked(typeobject.name) then
            goto continue
        end

        local category_idx = assert(cache[typeobject.item_category])
        local item_idx = #res[category_idx].items+1

        res[category_idx].items[item_idx] = {
            id = ("%s:%s"):format(category_idx, item_idx),
            name = typeobject.name,
            icon = typeobject.item_icon,
            new = (not storage.item_picked_flag[typeobject.name]) and true or false,
            selected = (datamodel.item_name == typeobject.name) and true or false,
        }
        ::continue::
    end

    datamodel.items = {}
    for _, r in ipairs(res) do
        if #r.items > 0 then
            table.insert(datamodel.items, r)
            for item_idx, recipe in ipairs(r.items) do
                if recipe.name == datamodel.item_name then
                    assert(datamodel.category_idx == 0 and datamodel.item_idx == 0)

                    datamodel.category_idx = #datamodel.items
                    datamodel.item_idx = item_idx

                    local item_name = datamodel.items[datamodel.category_idx].items[datamodel.item_idx].name
                    __mark_item_flag(item_name)
                    __set_item_value(datamodel, datamodel.category_idx, datamodel.item_idx, "new", false)
                end
            end
        end
    end

    return datamodel
end

function M:stage_ui_update(datamodel, object_id, interface)
    for _, _, _, category_idx, item_idx in click_item_mb:unpack() do
        if category_idx == datamodel.category_idx and item_idx == datamodel.item_idx then
            __set_item_value(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)

            datamodel.category_idx = 0
            datamodel.item_idx = 0

            datamodel.item_name = ""
            datamodel.item_icon = ""
            datamodel.item_desc = ""
            datamodel.confirm = true
        else
            __set_item_value(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)
            __set_item_value(datamodel, category_idx, item_idx, "selected", true)
            datamodel.category_idx = category_idx
            datamodel.item_idx = item_idx

            local item_name = datamodel.items[category_idx].items[item_idx].name
            __mark_item_flag(item_name)
            __set_item_value(datamodel, category_idx, item_idx, "new", false)

            local typeobject = iprototype.queryByName(item_name)
            datamodel.item_name = typeobject.name
            datamodel.item_icon = typeobject.item_icon
            datamodel.item_desc = typeobject.item_description
            datamodel.confirm = true
        end
    end

    for _ in set_item_mb:unpack() do
        local category_idx = datamodel.category_idx
        local item_idx = datamodel.item_idx
        if not(category_idx == 0 and item_idx == 0) then
            assert(datamodel.items[category_idx])
            assert(datamodel.items[category_idx].items[item_idx])
            local name = datamodel.items[category_idx].items[item_idx].name
            local typeobject = assert(iprototype.queryByName(name))
            local e = gameplay_core.get_entity(assert(objects:get(object_id).gameplay_eid))
            local gameplay_world = gameplay_core.get_world()
            interface.set_item(gameplay_world, e, typeobject.id)
            itask.update_progress("set_item", name)
        else
            local e = gameplay_core.get_entity(assert(objects:get(object_id).gameplay_eid))
            local gameplay_world = gameplay_core.get_world()
            interface.set_item(gameplay_world, e, 0)
        end
        iui.call_datamodel_method("ui/building_menu.rml", "update_item_icon")
        iui.close("ui/item_config.rml")
    end
end

return M