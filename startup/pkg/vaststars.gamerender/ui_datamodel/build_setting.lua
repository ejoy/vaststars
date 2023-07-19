local ecs, mailbox = ...
local world = ecs.world

local iui = ecs.import.interface "vaststars.gamerender|iui"
local gameplay_core = require "gameplay.core"
local CONSTRUCT_MENU <const> = import_package "vaststars.prototype"("construct_menu")
local iprototype = require "gameplay.interface.prototype"
local MAX_SHORTCUT_COUNT <const> = 5
local click_item_mb = mailbox:sub {"click_item"}
local click_menu_button_mb = mailbox:sub {"click_menu_button"}
local click_main_button_mb = mailbox:sub {"click_main_button"}
local iUiRt = ecs.import.interface "ant.rmlui|iuirt"
local ibackpack = require "gameplay.interface.backpack"

local function __get_construct_menu()
    local res = {}
    for category_idx, menu in ipairs(CONSTRUCT_MENU) do
        local m = {}
        m.category = menu.category
        m.items = {}

        for item_idx, prototype_name in ipairs(menu.items) do
            local typeobject = assert(iprototype.queryByName(prototype_name))
            local count = ibackpack.query(gameplay_core.get_world(), typeobject.id)
            m.items[#m.items + 1] = {
                id = ("%s:%s"):format(category_idx, item_idx),
                name = prototype_name,
                icon = typeobject.icon,
                count = count,
                selected = false,
            }
        end

        res[#res+1] = m
    end
    return res
end

local function __set_item_value(datamodel, category_idx, item_idx, key, value)
    if category_idx == 0 and item_idx == 0 then
        return
    end
    assert(datamodel.construct_menu[category_idx])
    assert(datamodel.construct_menu[category_idx].items[item_idx])
    datamodel.construct_menu[category_idx].items[item_idx][key] = value
end

local function __update_shortcur(index, prototype_name, icon, timestamp)
    local storage = gameplay_core.get_storage()
    storage.shortcut = storage.shortcut or {}
    storage.shortcut[index] = storage.shortcut[index] or {}

    local shortcut = storage.shortcut[index]
    shortcut.prototype_name = prototype_name
    shortcut.icon = icon
    shortcut.last_timestamp = timestamp
end

local function __get_construct_index(prototype_name)
    for category_idx, menu in ipairs(CONSTRUCT_MENU) do
        for item_idx, item in ipairs(menu.items) do
            if item == prototype_name then
                return category_idx, item_idx
            end
        end
    end
    return 0, 0
end

local M = {}

function M:create()
    local storage = gameplay_core.get_storage()
    storage.shortcut = storage.shortcut or {}
    local shortcut = {}

    for i = 1, MAX_SHORTCUT_COUNT do
        local s = storage.shortcut[i]
        if not s then
            shortcut[i] = {prototype_name = "", icon = "", last_timestamp = 0, selected = false}
        else
            if s.prototype_name ~= "" then
                local typeobject = iprototype.queryByName(s.prototype_name)
                shortcut[i] = {prototype_name = s.prototype_name, icon = typeobject.icon, last_timestamp = s.last_timestamp or 0, selected = false}
            else
                shortcut[i] = {prototype_name = "", icon = "", last_timestamp = 0, selected = false}
            end
        end
    end

    local min_times = math.maxinteger
    local min_id = 1
    for i = 1, MAX_SHORTCUT_COUNT do
        if shortcut[i].prototype_name == "" then
            min_id = i
            break
        end
        if shortcut[i].last_timestamp < min_times then
            min_times = shortcut[i].last_timestamp
            min_id = i
        end
    end

    shortcut[min_id].selected = true

    local category_idx, item_idx = 0, 0
    local item_name, item_desc = "", ""
    if shortcut[min_id].prototype_name ~= "" then
        category_idx, item_idx = __get_construct_index(shortcut[min_id].prototype_name)
        local typeobject = iprototype.queryByName(shortcut[min_id].prototype_name)
        item_name = iprototype.show_prototype_name(typeobject)
        item_desc = typeobject.item_description or ""
    end

    local datamodel = {
        construct_menu = __get_construct_menu(),
        shortcut = shortcut,
        category_idx = category_idx,
        item_idx = item_idx,
        shortcut_id = min_id,
        item_name = item_name,
        item_desc = item_desc,
    }

    if category_idx ~= 0 and item_idx ~= 0 then
        __set_item_value(datamodel, category_idx, item_idx, "selected", true)
    end
    return datamodel
end

function M:stage_ui_update(datamodel)
    for _, _, _, category_idx, item_idx in click_item_mb:unpack() do
        if datamodel.category_idx == category_idx and datamodel.item_idx == item_idx then
            __set_item_value(datamodel, category_idx, item_idx, "selected", false)
            datamodel.category_idx = 0
            datamodel.item_idx = 0 
            datamodel.item_name = ""
            datamodel.item_desc = ""

            local storage = gameplay_core.get_storage()
            storage.shortcut = storage.shortcut or {}
            storage.shortcut[datamodel.shortcut_id] = nil

            datamodel.shortcut[datamodel.shortcut_id] = {prototype_name = "", icon = "", times = 0, selected = true}
        else
            __set_item_value(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)
            __set_item_value(datamodel, category_idx, item_idx, "selected", true)
            datamodel.category_idx = category_idx
            datamodel.item_idx = item_idx

            local item_name = datamodel.construct_menu[category_idx].items[item_idx].name
            local typeobject = iprototype.queryByName(item_name)
            datamodel.item_name = iprototype.show_prototype_name(typeobject)
            datamodel.item_desc = typeobject.item_description or ""

            iUiRt.set_rt_prefab("item_model",
                "/pkg/vaststars.resources/" .. typeobject.model,
                {s = {1, 1, 1}, t = {0, 0, 0}}, typeobject.camera_distance
            )

            __update_shortcur(datamodel.shortcut_id, item_name, typeobject.icon, os.time())

            local shortcut = assert(datamodel.shortcut[datamodel.shortcut_id])
            shortcut.prototype_name = item_name
            shortcut.icon = typeobject.icon
            shortcut.selected = true
        end
    end

    for _, _, _, index in click_menu_button_mb:unpack() do
        local shortcut
        shortcut = assert(datamodel.shortcut[datamodel.shortcut_id])
        shortcut.selected = false

        datamodel.shortcut_id = index

        shortcut = assert(datamodel.shortcut[datamodel.shortcut_id])
        shortcut.selected = true

        if datamodel.category_idx ~= 0 and datamodel.item_idx ~= 0 then
            __set_item_value(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)
        end

        if shortcut.prototype_name ~= "" then
            local category_idx, item_idx = __get_construct_index(shortcut.prototype_name)
            assert(category_idx ~= 0 and item_idx ~= 0)
            __set_item_value(datamodel, category_idx, item_idx, "selected", true)
            datamodel.category_idx = category_idx
            datamodel.item_idx = item_idx

            local typeobject = iprototype.queryByName(shortcut.prototype_name)
            datamodel.item_name = iprototype.show_prototype_name(typeobject)
            datamodel.item_desc = typeobject.item_description or ""
        else
            datamodel.category_idx = 0
            datamodel.item_idx = 0
            datamodel.item_name = ""
            datamodel.item_desc = ""
        end
    end

    for _ in click_main_button_mb:unpack() do
        world:pub {"rmlui_message_close", "build_setting.rml"}
        iui.open({"build.rml"})
    end
end

return M