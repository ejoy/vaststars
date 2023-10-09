local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.require "engine.system.ui_system"
local gameplay_core = require "gameplay.core"
local CONSTRUCT_MENU <const> = import_package "vaststars.prototype"("construct_menu")
local iprototype = require "gameplay.interface.prototype"
local MAX_SHORTCUT_COUNT <const> = 5
local click_item_mb = mailbox:sub {"click_item"}
local click_menu_button_mb = mailbox:sub {"click_menu_button"}
local click_main_button_mb = mailbox:sub {"click_main_button"}
local iUiRt = ecs.require "ant.rmlui|ui_rt_system"
local ibackpack = require "gameplay.interface.backpack"
local math3d = require "math3d"
local iom = ecs.require "ant.objcontroller|obj_motion"
local ivs = ecs.require "ant.render|visible_state"

local function __get_construct_menu()
    local res = {}
    for category_idx, menu in ipairs(CONSTRUCT_MENU) do
        local r = {}
        r.category = menu.category
        r.items = {}

        for item_idx, prototype_name in ipairs(menu.items) do
            local typeobject = assert(iprototype.queryByName(prototype_name))
            local count = ibackpack.query(gameplay_core.get_world(), typeobject.id)
            r.items[#r.items + 1] = {
                id = ("%s:%s"):format(category_idx, item_idx),
                prototype = typeobject.id,
                name = iprototype.display_name(typeobject),
                icon = typeobject.item_icon,
                count = count,
                selected = false,
            }
        end

        res[#res+1] = r
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

local function __get_shortcur(index)
    local storage = gameplay_core.get_storage()
    storage.shortcut = storage.shortcut or {}
    storage.shortcut[index] = storage.shortcut[index] or {}
    return storage.shortcut[index]
end

local function __get_construct_index(prototype)
    local typeobject = assert(iprototype.queryById(prototype))
    for category_idx, menu in ipairs(CONSTRUCT_MENU) do
        for item_idx, item in ipairs(menu.items) do
            if item == typeobject.name then
                return category_idx, item_idx
            end
        end
    end
    return 0, 0
end

local model_euler
local function model_message_func(mdl, msg)
    if msg == "motion" then
        local e <close> = world:entity(mdl.tag["*"][1])
        if not e then
            return
        end
        if not model_euler then
            local r = iom.get_rotation(e)
            local rad = math3d.tovalue(math3d.quat2euler(r))
            model_euler = { math.deg(rad[1]), math.deg(rad[2]), math.deg(rad[3]) }
        end
        model_euler[2] = model_euler[2] + 1
        iom.set_rotation(e, math3d.quaternion{math.rad(model_euler[1]), math.rad(model_euler[2]), math.rad(model_euler[3])})
    elseif msg == "disable_cast_shadow" then
        for _, eid in ipairs(mdl.tag['*']) do
            local e <close> = world:entity(eid, "visible_state?in render_object?in")
            if e.visible_state then
                ivs.set_state(e, "cast_shadow", false)
            end
        end
    end
end

local M = {}
local model

function M.create()
    local storage = gameplay_core.get_storage()
    storage.shortcut = storage.shortcut or {}
    local shortcut = {}

    for i = 1, MAX_SHORTCUT_COUNT do
        local s = storage.shortcut[i]
        if not s then
            shortcut[i] = {prototype = 0, icon = "", last_timestamp = 0, selected = false}
        else
            if s.prototype and s.prototype ~= 0 then
                local typeobject = iprototype.queryById(s.prototype)
                shortcut[i] = {prototype = s.prototype, icon = typeobject.item_icon, last_timestamp = s.last_timestamp or 0, selected = false}
            else
                shortcut[i] = {prototype = 0, icon = "", last_timestamp = 0, selected = false}
            end
        end
    end

    local min_times = math.maxinteger
    local min_id = 1
    for i = 1, MAX_SHORTCUT_COUNT do
        if shortcut[i].prototype == 0 then
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
    if shortcut[min_id].prototype ~= 0 then
        category_idx, item_idx = __get_construct_index(shortcut[min_id].prototype)
        local typeobject = iprototype.queryById(shortcut[min_id].prototype)
        item_name = iprototype.display_name(typeobject)
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

function M.stage_camera_usage(datamodel)
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

            datamodel.shortcut[datamodel.shortcut_id] = {prototype = 0, icon = "", times = 0, selected = true}
        else
            __set_item_value(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)
            __set_item_value(datamodel, category_idx, item_idx, "selected", true)
            datamodel.category_idx = category_idx
            datamodel.item_idx = item_idx

            local prototype = datamodel.construct_menu[category_idx].items[item_idx].prototype
            local typeobject = assert(iprototype.queryById(prototype))
            datamodel.item_name = iprototype.display_name(typeobject)
            datamodel.item_desc = typeobject.item_description or ""

            model = iUiRt.set_rt_prefab("item_model",
                "/pkg/vaststars.resources/" .. typeobject.model,
                {s = {1, 1, 1}, t = {0, 0, 0}}, typeobject.camera_distance, nil, model_message_func
            )
            world:instance_message(model, "disable_cast_shadow")

            local data = __get_shortcur(datamodel.shortcut_id)
            data.prototype = typeobject.id
            data.icon = typeobject.item_icon
            data.last_timestamp = os.time()

            local shortcut = assert(datamodel.shortcut[datamodel.shortcut_id])
            shortcut.prototype = prototype
            shortcut.icon = typeobject.item_icon
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

        if shortcut.prototype ~= 0 then
            local category_idx, item_idx = __get_construct_index(shortcut.prototype)
            assert(category_idx ~= 0 and item_idx ~= 0)
            __set_item_value(datamodel, category_idx, item_idx, "selected", true)
            datamodel.category_idx = category_idx
            datamodel.item_idx = item_idx

            local typeobject = iprototype.queryById(shortcut.prototype)
            datamodel.item_name = iprototype.display_name(typeobject)
            datamodel.item_desc = typeobject.item_description or ""

            model = iUiRt.set_rt_prefab("item_model",
                "/pkg/vaststars.resources/" .. typeobject.model,
                {s = {1, 1, 1}, t = {0, 0, 0}}, typeobject.camera_distance, nil, model_message_func
            )
            world:instance_message(model, "disable_cast_shadow")
        else
            datamodel.category_idx = 0
            datamodel.item_idx = 0
            datamodel.item_name = ""
            datamodel.item_desc = ""
        end
    end

    if model then
        world:instance_message(model, "motion")
    end

    for _ in click_main_button_mb:unpack() do
        local shortcut = __get_shortcur(datamodel.shortcut_id)
        shortcut.last_timestamp = os.time()

        iui.close("/pkg/vaststars.resources/ui/build_setting.rml")
        iui.open({rml = "/pkg/vaststars.resources/ui/build.rml"})
    end
end

return M