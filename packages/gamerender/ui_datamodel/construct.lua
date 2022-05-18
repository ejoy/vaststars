local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local camera = ecs.require "engine.camera"
local construct_editor = ecs.require "construct_editor"
local gameplay_core = require "gameplay.core"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local fluid_list_cfg = import_package "vaststars.prototype"("fluid_category")
local construct_menu_cfg = import_package "vaststars.prototype"("construct_menu")
local iprototype = require "gameplay.interface.prototype"
local global = require "global"
local objects = global.objects

local construct_begin_mb = mailbox:sub {"construct_begin"}
local dismantle_begin_mb = mailbox:sub {"dismantle_begin"}
local rotate_mb = mailbox:sub {"rotate"}
local construct_confirm_mb = mailbox:sub {"construct_confirm"} -- 确认建造
local construct_complete_mb = mailbox:sub {"construct_complete"} -- 开始施工
local dismantle_complete_mb = mailbox:sub {"dismantle_complete"}
local cancel_mb = mailbox:sub {"cancel"}
local construct_entity_mb = mailbox:sub {"construct_entity"}
local fluidbox_update_mb = mailbox:sub {"fluidbox_update"}
local show_setting_mb = mailbox:sub {"show_setting"}
local headquater_mb = mailbox:sub {"headquater"}

local construct_menu = {} ; do
    for _, menu in ipairs(construct_menu_cfg) do
        local m = {}
        m.name = menu.name
        m.icon = menu.icon
        m.detail = {}

        for _, prototype_name in ipairs(menu.detail) do
            local typeobject = assert(iprototype:queryByName("item", prototype_name))

            local d = {}
            d.show_prototype_name = iprototype:show_prototype_name(typeobject)
            d.prototype = prototype_name
            d.icon = typeobject.icon
            m.detail[#m.detail + 1] = d
        end

        construct_menu[#construct_menu+1] = m
    end
end

-- = {{catagory = xxx, icon = xxx, fluid = {{id = xxx, name = xxx, icon = xxx}, ...} }, ...}
local fluid_category = {}; do
    local t = {}
    for _, v in pairs(iprototype:all_prototype_name()) do
        if iprototype:has_type(v.type, "fluid") then
            for _, c in ipairs(v.catagory) do
                t[c] = t[c] or {}
                t[c][#t[c]+1] = {id = v.id, name = v.name, icon = v.icon}
            end
        end
    end

    for catagory, v in pairs(t) do
        fluid_category[#fluid_category+1] = {catagory = catagory, icon = fluid_list_cfg[catagory].icon, pos = fluid_list_cfg[catagory].pos, fluid = v}
        table.sort(v, function(a, b) return a.id < b.id end)
    end
    table.sort(fluid_category, function(a, b) return a.pos < b.pos end)
end

local function get_headquater_object_id()
    for id in objects:select("CONSTRUCTED", "headquater", true) do
        return id
    end
end

---------------
local M = {}

function M:create()
    return {
        fluid_category = fluid_category,
        construct_menu = construct_menu,
    }
end

function M:fps_text(datamodel, text)
    datamodel.fps_text = text
end

function M:drawcall_text(datamodel, text)
    datamodel.drawcall_text = text
end

function M:stage_ui_update(datamodel)
    for _, _, _, double_confirm in construct_begin_mb:unpack() do
        if construct_editor:check_unconfirmed(double_confirm) then
            world:pub {"ui_message", "show_unconfirmed_double_confirm"}
            goto continue
        end
        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        construct_editor:construct_begin()
        gameplay_core.world_update = false
        construct_editor.mode = "construct"
        camera.set("camera_construct.prefab")
        ::continue::
    end

    for _, _, _, double_confirm in dismantle_begin_mb:unpack() do
        if construct_editor:check_unconfirmed(double_confirm) then
            world:pub {"ui_message", "show_unconfirmed_double_confirm"}
            goto continue
        end
        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        construct_editor:teardown_begin()
        construct_editor.mode = "teardown"
        gameplay_core.world_update = false
        camera.set("camera_construct.prefab")
        ::continue::
    end

    for _ in rotate_mb:unpack() do
        assert(gameplay_core.world_update == false)
        construct_editor:rotate_pickup_object()
    end

    for _ in construct_confirm_mb:unpack() do
        assert(gameplay_core.world_update == false)
        if construct_editor:confirm() then
            world:pub {"ui_message", "show_construct_complete", true}
        end
    end

    for _ in construct_complete_mb:unpack() do
        construct_editor:complete()
        gameplay_core.world_update = true
        construct_editor.mode = "normal"
        camera.set("camera_default.prefab")
    end

    for _ in dismantle_complete_mb:unpack() do
        construct_editor:teardown_complete()
        construct_editor.mode = "normal"
        gameplay_core.world_update = true
        camera.set("camera_default.prefab")
    end

    for _, _, _, double_confirm in cancel_mb:unpack() do
        if construct_editor:check_unconfirmed(double_confirm) then
            world:pub {"ui_message", "show_unconfirmed_double_confirm"}
            goto continue
        end
        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        construct_editor:cancel()
        gameplay_core.world_update = true
        construct_editor.mode = "normal"
        camera.set("camera_default.prefab")
        ::continue::
    end

    for _, _, _, fluid_name in fluidbox_update_mb:unpack() do
        construct_editor:set_pickup_object_fluid(fluid_name)
    end

    for _ in headquater_mb:unpack() do
        local object_id = get_headquater_object_id()
        if object_id then
            iui.open("cmdcenter.rml", object_id)
        else
            log.error("can not found headquater")
        end
    end

    for _ in show_setting_mb:unpack() do
        iui.open("option_pop.rml")
    end
end

function M:stage_camera_usage()
    for _, _, _, prototype_name in construct_entity_mb:unpack() do
        construct_editor:new_pickup_object(prototype_name)
    end
end
return M