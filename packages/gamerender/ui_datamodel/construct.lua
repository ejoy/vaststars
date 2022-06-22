local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local camera = ecs.require "engine.camera"
local gameplay_core = require "gameplay.core"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local construct_menu_cfg = import_package "vaststars.prototype"("construct_menu")
local iprototype = require "gameplay.interface.prototype"
local create_normalbuilder = ecs.require "editor.normalbuilder"
local create_pipebuilder = ecs.require "editor.pipebuilder"
local create_pipetogroundbuilder = ecs.require "editor.pipetogroundbuilder"
local objects = require "objects"
local ieditor = ecs.require "editor.editor"
local global = require "global"
local iobject = ecs.require "object"

local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local construct_begin_mb = mailbox:sub {"construct_begin"} -- 建造 -> 建造模式
local dismantle_begin_mb = mailbox:sub {"dismantle_begin"} -- 建造 -> 拆除模式
local rotate_mb = mailbox:sub {"rotate"} -- 旋转建筑
local construct_confirm_mb = mailbox:sub {"construct_confirm"} -- 确认放置
local construct_complete_mb = mailbox:sub {"construct_complete"} -- 开始施工
local dismantle_complete_mb = mailbox:sub {"dismantle_complete"} -- 开始拆除
local cancel_mb = mailbox:sub {"cancel"} -- 主界面左上角返回按钮
local show_setting_mb = mailbox:sub {"show_setting"} -- 主界面左下角 -> 游戏设置
local headquater_mb = mailbox:sub {"headquater"} -- 主界面左下角 -> 指挥中心
local technology_mb = mailbox:sub {"technology"} -- 主界面左下角 -> 科研中心
local construct_entity_mb = mailbox:sub {"construct_entity"} -- 建造 entity
local laying_pipe_begin_mb = mailbox:sub {"laying_pipe_begin"} -- 铺管开始
local laying_pipe_cancel_mb = mailbox:sub {"laying_pipe_cancel"} -- 铺管取消
local laying_pipe_confirm_mb = mailbox:sub {"laying_pipe_confirm"} -- 铺管结束
local open_taskui_event = mailbox:sub {"open_taskui"}
local single_touch_mb = world:sub {"single_touch"}
local imanual = require "ui_datamodel.common.manual"

local builder
local last_prototype_name

local construct_menu = {} ; do
    for _, menu in ipairs(construct_menu_cfg) do
        local m = {}
        m.name = menu.name
        m.icon = menu.icon
        m.detail = {}

        for _, prototype_name in ipairs(menu.detail) do
            local typeobject = assert(iprototype.queryByName("entity", prototype_name))
            m.detail[#m.detail + 1] = {
                show_prototype_name = iprototype.show_prototype_name(typeobject),
                prototype_name = prototype_name,
                icon = typeobject.icon,
            }
        end

        construct_menu[#construct_menu+1] = m
    end
end

-- TODO
local function get_headquater_object_id()
    for id in objects:select("CONSTRUCTED", "headquater", true) do
        return id
    end
end

---------------
local M = {}

function M:create()
    return {
        construct_menu = construct_menu,
        tech_count = global.science.tech_list and #global.science.tech_list or 0,
        show_tech_progress = false,
        current_tech_icon = "none",    --当前科技图标
        current_tech_name = "none",    --当前科技名字
        current_tech_progress = "0%",  --当前科技进度
        manual_queue = {},
    }
end

-- TODO
function M:fps_text(datamodel, text)
    datamodel.fps_text = text
end

function M:drawcall_text(datamodel, text)
    datamodel.drawcall_text = text
end

local tech_finish_switch = false
function M:update_tech(datamodel, tech)
    if tech then
        datamodel.show_tech_progress = true
        datamodel.is_task = tech.task
        datamodel.current_tech_name = tech.name
        datamodel.current_tech_icon = tech.detail.icon
        datamodel.current_tech_progress = (tech.progress * 100) // tech.detail.count .. '%'
    else
        datamodel.show_tech_progress = false
        datamodel.tech_count = global.science.tech_list and #global.science.tech_list or 0
        tech_finish_switch = not tech_finish_switch
        --TODO: trigger animation
        if tech_finish_switch then
            datamodel.finish_animation = "3s sine-in-out 0s enlarge"
        else
            datamodel.finish_animation = "2.99s sine-in-out 0s enlarge"
        end
    end
end

function M:stage_ui_update(datamodel)
    for _, _, _, double_confirm in construct_begin_mb:unpack() do
        if builder then
            if builder:check_unconfirmed(double_confirm) then
                world:pub {"ui_message", "show_unconfirmed_double_confirm"}
                goto continue
            end
        end

        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        world:pub {"ui_message", "show_rotate_confirm", {rotate = false, confirm = false}}
        gameplay_core.world_update = false
        global.mode = "construct"
        camera.set("camera_construct.prefab")
        last_prototype_name = nil

        ::continue::
    end

    for _, _, _, double_confirm in dismantle_begin_mb:unpack() do
        if builder then
            if builder:check_unconfirmed(double_confirm) then
                world:pub {"ui_message", "show_unconfirmed_double_confirm"}
                goto continue
            end

            builder:clean(datamodel)
            builder = nil
        end

        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        ieditor:revert_changes({"TEMPORARY", "CONFIRM"})
        global.mode = "teardown"
        gameplay_core.world_update = false
        camera.set("camera_construct.prefab")
        ::continue::
    end

    for _ in rotate_mb:unpack() do
        assert(gameplay_core.world_update == false)
        builder:rotate_pickup_object()
    end

    for _ in construct_confirm_mb:unpack() do
        assert(gameplay_core.world_update == false)
        builder:confirm(datamodel)
        self:flush()
    end

    for _ in construct_complete_mb:unpack() do
        builder:complete(datamodel)
        self:flush()
        builder = nil
        gameplay_core.world_update = true
        global.mode = "normal"
        camera.set("camera_default.prefab")
    end

    for _ in dismantle_complete_mb:unpack() do
        ieditor:teardown_complete()
        global.mode = "normal"
        gameplay_core.world_update = true
        camera.set("camera_default.prefab")
    end

    for _, _, _, double_confirm in cancel_mb:unpack() do
        if builder then
            if builder:check_unconfirmed(double_confirm) then
                world:pub {"ui_message", "show_unconfirmed_double_confirm"}
                goto continue
            end

            builder:clean(datamodel)
            builder = nil
        end

        if not double_confirm then
            world:pub {"ui_message", "unconfirmed_double_confirm_continuation"}
            goto continue
        end

        ieditor:revert_changes({"TEMPORARY", "CONFIRM"})
        gameplay_core.world_update = true
        global.mode = "normal"
        camera.set("camera_default.prefab")
        ::continue::
    end

    for _ in headquater_mb:unpack() do
        local object_id = get_headquater_object_id()
        if object_id then
            iui.open("cmdcenter.rml", object_id)
        else
            log.error("can not found headquater")
        end
    end

    for _ in open_taskui_event:unpack() do
        if gameplay_core.world_update and global.science.current_tech then
            gameplay_core.world_update = false
            iui.open("task_pop.rml")
        end
    end

    for _ in technology_mb:unpack() do
        gameplay_core.world_update = false
        iui.open("science.rml")
    end

    for _ in show_setting_mb:unpack() do
        iui.open("option_pop.rml")
    end

    for _ in laying_pipe_begin_mb:unpack() do
        builder:laying_pipe_begin(datamodel)
        self:flush()
    end

    for _ in laying_pipe_cancel_mb:unpack() do
        builder:laying_pipe_cancel(datamodel)
        self:flush()
    end

    for _ in laying_pipe_confirm_mb:unpack() do
        builder:laying_pipe_confirm(datamodel)
        self:flush()
    end
end

function M:stage_camera_usage(datamodel)
    for _, delta in dragdrop_camera_mb:unpack() do
        if builder then
            builder:touch_move(datamodel, delta)
            self:flush()
        end
    end

    for _, _, _, prototype_name in construct_entity_mb:unpack() do
        if last_prototype_name ~= prototype_name then
            if builder then
                builder:clean(datamodel)
            end

            if iprototype.is_pipe_to_ground(prototype_name) then
                builder = create_pipetogroundbuilder()
            elseif iprototype.is_pipe(prototype_name) then
                builder = create_pipebuilder()
            else
                builder = create_normalbuilder()
            end

            local typeobject = iprototype.queryByName("entity", prototype_name)
            builder:new_entity(datamodel, typeobject)
            self:flush()

            last_prototype_name = prototype_name
        end
    end

    for _, state in single_touch_mb:unpack() do
        if state == "END" or state == "CANCEL" then
            if builder then
                builder:touch_end(datamodel)
                self:flush()
            end
        end
    end

    datamodel.manual_queue = imanual.get_queue(4)
    iobject.flush()
end
return M