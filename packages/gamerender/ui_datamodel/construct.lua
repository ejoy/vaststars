local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local YAXIS_PLANE_B <const> = math3d.constant("v4", {0, 1, 0, 0})
local YAXIS_PLANE_T <const> = math3d.constant("v4", {0, 1, 0, 20})
local PLANES <const> = {YAXIS_PLANE_T, YAXIS_PLANE_B}
local camera = ecs.require "engine.camera"
local gameplay_core = require "gameplay.core"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iprototype = require "gameplay.interface.prototype"
local create_normalbuilder = ecs.require "editor.normalbuilder"
local create_pipebuilder = ecs.require "editor.pipebuilder"
local create_roadbuilder = ecs.require "editor.roadbuilder"
local create_pipetogroundbuilder = ecs.require "editor.pipetogroundbuilder"
local objects = require "objects"
local ieditor = ecs.require "editor.editor"
local global = require "global"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local icamera = ecs.require "engine.camera"
local idetail = ecs.import.interface "vaststars.gamerender|idetail"
local construct_menu_cfg = import_package "vaststars.prototype"("construct_menu")

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
local inventory = global.inventory
local pickup_mapping_mb = world:sub {"pickup_mapping"}
local pickup_mb = world:sub {"pickup"}
local single_touch_move_mb = world:sub {"single_touch", "MOVE"}
local _TILE_PICKUP <const> = true

local builder
local last_prototype_name

-- TODO
local function get_headquater_object_id()
    for id in objects:select("CONSTRUCTED", "headquater", true) do
        return id
    end
end

local function _has_teardown_entity()
    for _ in objects:select("TEMPORARY", "teardown", true) do
        return true
    end
    return false
end

local function _get_construct_menu()
    local construct_menu = {}
    for _, menu in ipairs(construct_menu_cfg) do
        local m = {}
        m.name = menu.name
        m.icon = menu.icon
        m.detail = {}

        for _, prototype_name in ipairs(menu.detail) do
            local typeobject = assert(iprototype.queryByName("item", prototype_name))
            local c = inventory:get(typeobject.id)
            if c.count > 0 then
                m.detail[#m.detail + 1] = {
                    show_prototype_name = iprototype.show_prototype_name(typeobject),
                    prototype_name = prototype_name,
                    icon = typeobject.icon,
                    count = c.count,
                }
            end
        end

        construct_menu[#construct_menu+1] = m
    end
    return construct_menu
end
---------------
local M = {}

function M:create()
    return {
        construct_menu = {},
        tech_count = global.science.tech_list and #global.science.tech_list or 0,
        show_tech_progress = false,
        current_tech_icon = "none",    --当前科技图标
        current_tech_name = "none",    --当前科技名字
        current_tech_progress = "0%",  --当前科技进度
        manual_queue = {},
    }
end

function M:update_construct_inventory(datamodel)
    datamodel.construct_menu = _get_construct_menu()
end

-- TODO
function M:fps_text(datamodel, text)
    datamodel.fps_text = text
end

function M:drawcall_text(datamodel, text)
    datamodel.drawcall_text = text
end

function M:show_chapter(datamodel, main_text, sub_text)
    datamodel.show_chapter = true
    datamodel.chapter_main_text = main_text
    datamodel.chapter_sub_text = sub_text
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

        ieditor:revert_changes({"TEMPORARY", "CONFIRM"})
        datamodel.show_rotate = false
        datamodel.show_confirm = false
        datamodel.show_construct_complete = false
        gameplay_core.world_update = false
        global.mode = "construct"
        camera.transition("camera_construct.prefab")
        last_prototype_name = nil

        inventory:flush()
        datamodel.construct_menu = _get_construct_menu()
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
        datamodel.show_teardown = _has_teardown_entity()

        global.mode = "teardown"
        gameplay_core.world_update = false
        camera.transition("camera_construct.prefab")
        ::continue::
    end

    for _ in rotate_mb:unpack() do
        assert(gameplay_core.world_update == false)
        builder:rotate_pickup_object(datamodel)
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
        camera.transition("camera_default.prefab")
    end

    for _ in dismantle_complete_mb:unpack() do
        ieditor:teardown_complete()
        global.mode = "normal"
        gameplay_core.world_update = true
        camera.transition("camera_default.prefab")
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
        camera.transition("camera_default.prefab")
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
        local coord = terrain:align(camera.get_central_position(), terrain.ground_width, terrain.ground_height)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end

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
            elseif iprototype.is_road(prototype_name) then
                builder = create_roadbuilder()
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

    local leave = true
    for _, _, x, y, object_id in pickup_mapping_mb:unpack() do
        -- do -- TODO: remove this block
        --     local vsobject_manager = ecs.require "vsobject_manager"
        --     local vsobject = vsobject_manager:get(object_id)
        --     local object = objects:get(object_id)
        --     if object then
        --         log.info(("pickup_mapping object (%s) (%s)"):format(object.prototype_name, math3d.tostring(vsobject:get_position())))
        --     end
        -- end

        if not _TILE_PICKUP then
            if objects:get(object_id) then -- object_id may be 0, such as when user click on empty space
                if global.mode == "teardown" then
                    world:pub {"teardown", objects:get(object_id).prototype_name}
                    ieditor:teardown(object_id)
                    datamodel.show_teardown = _has_teardown_entity()

                elseif global.mode == "normal" then
                    if idetail.show(object_id) then
                        leave = false
                    end
                end
            end
        end
    end

    local function _get_object(pickup_x, pickup_y)
        for _, pos in ipairs(icamera.screen_to_world(pickup_x, pickup_y, PLANES)) do
            local coord = terrain:align(pos, 1, 1) -- assume entity is 1x1
            if coord then
                local object = objects:coord(coord[1], coord[2])
                if object then
                    return object
                end
            end
        end
    end

    -- 点击其它建筑 或 拖动时, 将弹出窗口隐藏
    for _, _, x, y in pickup_mb:unpack() do
        -- do -- TODO: remove this block
        --     local pos = icamera.screen_to_world(x, y, PLANE_B)
        --     log.info(("pickup plane_b (%s)"):format(math3d.tostring(pos[1])))
        --     local coord = terrain:align(pos[1], 1, 1)
        --     if coord then
        --         log.info(("pickup coord: (%d, %d)"):format(coord[1], coord[2]))
        --     end

        --     local object = _get_object(x, y)
        --     if object then
        --         log.info(("pickup object (%s) in (%s, %s) fluidflow_id(%s)"):format(object.prototype_name, object.x, object.y, object.fluidflow_id))
        --     else
        --         log.info(("pickup object (%s) in (%s, %s)"):format("none", x, y))
        --     end

        --     log.info("------------------------------------")
        -- end

        if _TILE_PICKUP then
            local object = _get_object(x, y)
            if object then -- object may be nil, such as when user click on empty space
                if global.mode == "teardown" then
                    world:pub {"teardown", object.prototype_name}
                    ieditor:teardown(object.id)
                    datamodel.show_teardown = _has_teardown_entity()

                elseif global.mode == "normal" then
                    if idetail.show(object.id) then
                        leave = false
                    end
                end
            end
        end

        if leave then
            world:pub {"ui_message", "leave"}
            leave = false
            break
        end
    end

    for _ in single_touch_move_mb:unpack() do
        if leave then
            world:pub {"ui_message", "leave"}
            leave = false
            break
        end
    end

    datamodel.manual_queue = imanual.get_queue(4)
    iobject.flush()
end
return M