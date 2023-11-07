local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local CONSTRUCT_LIST <const> = ecs.require "vaststars.prototype|construct_list"
local MAX_SHORTCUT_COUNT <const> = 5

local iui = ecs.require "engine.system.ui_system"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local click_item_mb = mailbox:sub {"click_item"}
local click_menu_button_mb = mailbox:sub {"click_menu_button"}
local click_main_button_mb = mailbox:sub {"click_main_button"}
local iUiRt = ecs.require "ant.rmlui|ui_rt_system"
local ibackpack = require "gameplay.interface.backpack"
local math3d = require "math3d"
local iom = ecs.require "ant.objcontroller|obj_motion"
local ivs = ecs.require "ant.render|visible_state"
local item_unlocked = ecs.require "ui_datamodel.common.item_unlocked".is_unlocked

local function get_list()
    local gameplay_world = gameplay_core.get_world()

    local res = {}
    for category_idx, menu in ipairs(CONSTRUCT_LIST) do
        local r = {}
        r.category = menu.category
        r.items = {}

        for item_idx, prototype_name in ipairs(menu.items) do
            local typeobject = assert(iprototype.queryByName(prototype_name))
            local count = ibackpack.query(gameplay_world, typeobject.id)

            if not item_unlocked(typeobject.name) and count <= 0 then
                goto continue
            end

            r.items[#r.items + 1] = {
                id = ("%s:%s"):format(category_idx, item_idx),
                prototype = typeobject.id,
                name = iprototype.display_name(typeobject),
                icon = typeobject.item_icon,
                count = count,
                selected = false,
            }
            ::continue::
        end

        if #r.items > 0 then
            res[#res+1] = r
        end
    end
    return res
end

local function update_list_item(datamodel, category_idx, item_idx, key, value)
    if category_idx == 0 and item_idx == 0 then
        return
    end
    assert(datamodel.construct_list[category_idx])
    assert(datamodel.construct_list[category_idx].items[item_idx])
    datamodel.construct_list[category_idx].items[item_idx][key] = value
end

local function get_shortcur(index)
    local storage = gameplay_core.get_storage()
    storage.shortcuts = storage.shortcuts or {}
    storage.shortcuts[index] = storage.shortcuts[index] or {}
    return storage.shortcuts[index]
end

local function get_list_index(construct_list, prototype)
    for category_idx, menu in ipairs(construct_list) do
        for item_idx, item in ipairs(menu.items) do
            if item.prototype == prototype then
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
    storage.shortcuts = storage.shortcuts or {}
    local shortcuts = {}

    for i = 1, MAX_SHORTCUT_COUNT do
        local s = storage.shortcuts[i]
        if not s then
            shortcuts[i] = {prototype = 0, icon = "", last_timestamp = 0, selected = false}
        else
            if s.prototype and s.prototype ~= 0 then
                local typeobject = iprototype.queryById(s.prototype)
                shortcuts[i] = {prototype = s.prototype, icon = typeobject.item_icon, last_timestamp = s.last_timestamp or 0, selected = false}
            else
                shortcuts[i] = {prototype = 0, icon = "", last_timestamp = 0, selected = false}
            end
        end
    end

    local min_times = math.maxinteger
    local min_id = 1
    for i = 1, MAX_SHORTCUT_COUNT do
        if shortcuts[i].prototype == 0 then
            min_id = i
            break
        end
        if shortcuts[i].last_timestamp < min_times then
            min_times = shortcuts[i].last_timestamp
            min_id = i
        end
    end

    shortcuts[min_id].selected = true

    local construct_list = get_list()
    local category_idx, item_idx = 0, 0
    local item_name, item_desc = "", ""
    if shortcuts[min_id].prototype ~= 0 then
        category_idx, item_idx = get_list_index(construct_list, shortcuts[min_id].prototype)
        local typeobject = iprototype.queryById(shortcuts[min_id].prototype)
        item_name = iprototype.display_name(typeobject)
        item_desc = typeobject.item_description or ""
    end

    local datamodel = {
        construct_list = construct_list,
        shortcuts = shortcuts,
        category_idx = category_idx,
        item_idx = item_idx,
        shortcut_id = min_id,
        item_name = item_name,
        item_desc = item_desc,
    }

    if category_idx ~= 0 and item_idx ~= 0 then
        update_list_item(datamodel, category_idx, item_idx, "selected", true)
    end
    return datamodel
end

function M.update(datamodel)
    for _, _, _, category_idx, item_idx in click_item_mb:unpack() do
        if datamodel.category_idx == category_idx and datamodel.item_idx == item_idx then
            update_list_item(datamodel, category_idx, item_idx, "selected", false)
            datamodel.category_idx = 0
            datamodel.item_idx = 0 
            datamodel.item_name = ""
            datamodel.item_desc = ""

            local storage = gameplay_core.get_storage()
            storage.shortcuts = storage.shortcuts or {}
            storage.shortcuts[datamodel.shortcut_id] = nil

            datamodel.shortcuts[datamodel.shortcut_id] = {prototype = 0, icon = "", times = 0, selected = true}
        else
            update_list_item(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)
            update_list_item(datamodel, category_idx, item_idx, "selected", true)
            datamodel.category_idx = category_idx
            datamodel.item_idx = item_idx

            local prototype = datamodel.construct_list[category_idx].items[item_idx].prototype
            local typeobject = assert(iprototype.queryById(prototype))
            datamodel.item_name = iprototype.display_name(typeobject)
            datamodel.item_desc = typeobject.item_description or ""

            model = iUiRt.set_rt_prefab("item_model",
                "/pkg/vaststars.resources/" .. typeobject.model,
                {s = {1, 1, 1}, t = {0, 0, 0}}, typeobject.camera_distance, nil, model_message_func
            )
            if model then
                world:instance_message(model, "disable_cast_shadow") 
            end

            local data = get_shortcur(datamodel.shortcut_id)
            data.prototype = typeobject.id
            data.icon = typeobject.item_icon
            data.last_timestamp = os.time()

            local shortcut = assert(datamodel.shortcuts[datamodel.shortcut_id])
            shortcut.prototype = prototype
            shortcut.icon = typeobject.item_icon
            shortcut.selected = true
        end
    end

    for _, _, _, index in click_menu_button_mb:unpack() do
        local shortcut
        shortcut = assert(datamodel.shortcuts[datamodel.shortcut_id])
        shortcut.selected = false

        datamodel.shortcut_id = index

        shortcut = assert(datamodel.shortcuts[datamodel.shortcut_id])
        shortcut.selected = true

        if datamodel.category_idx ~= 0 and datamodel.item_idx ~= 0 then
            update_list_item(datamodel, datamodel.category_idx, datamodel.item_idx, "selected", false)
        end

        if shortcut.prototype ~= 0 then
            local category_idx, item_idx = get_list_index(datamodel.construct_list, shortcut.prototype)
            if category_idx ~= 0 and item_idx ~= 0 then
                update_list_item(datamodel, category_idx, item_idx, "selected", true)
                datamodel.category_idx = category_idx
                datamodel.item_idx = item_idx

                local typeobject = iprototype.queryById(shortcut.prototype)
                datamodel.item_name = iprototype.display_name(typeobject)
                datamodel.item_desc = typeobject.item_description or ""

                model = iUiRt.set_rt_prefab("item_model",
                    "/pkg/vaststars.resources/" .. typeobject.model,
                    {s = {1, 1, 1}, t = {0, 0, 0}}, typeobject.camera_distance, nil, model_message_func
                )
                if model then
                    world:instance_message(model, "disable_cast_shadow") 
                end
            end
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
        local shortcut = get_shortcur(datamodel.shortcut_id)
        shortcut.last_timestamp = os.time()

        iui.close("/pkg/vaststars.resources/ui/build_setting.rml")
        iui.open({rml = "/pkg/vaststars.resources/ui/build.rml"})
    end
end

return M