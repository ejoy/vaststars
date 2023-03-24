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
local create_pipetogroundbuilder = ecs.require "editor.pipetogroundbuilder"
local create_movebuilder = ecs.require "editor.movebuilder"
local create_setitembuilder = ecs.require "editor.setitembuilder"
local objects = require "objects"
local ieditor = ecs.require "editor.editor"
local global = require "global"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local icamera = ecs.require "engine.camera"
local idetail = ecs.import.interface "vaststars.gamerender|idetail"
local construct_menu_cfg = import_package "vaststars.prototype"("construct_menu")
local SHOW_LOAD_RESOURCE <const> = not require "debugger".disable_load_resource
local EDITOR_CACHE_NAMES = {"CONFIRM", "CONSTRUCTED"}
local create_builder = ecs.require "editor.builder"
local create_station_builder = ecs.require "editor.stationbuilder"

local rotate_mb = mailbox:sub {"rotate"} -- construct_pop.rml -> 旋转
local build_mb = mailbox:sub {"build"}   -- construct_pop.rml -> 修建
local cancel_mb = mailbox:sub {"cancel"} -- construct_pop.rml -> 取消
local road_builder_mb = mailbox:sub {"road_builder"}
local pipe_builder_mb = mailbox:sub {"pipe_builder"}
local confirm_cancel_mb = mailbox:sub {"confirm_cancel"} -- 取消已确定的建筑

local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local show_construct_menu_mb = mailbox:sub {"show_construct_menu"}
local show_statistic_mb = mailbox:sub {"statistic"} -- 主界面左下角 -> 统计信息
local show_setting_mb = mailbox:sub {"show_setting"} -- 主界面左下角 -> 游戏设置
local technology_mb = mailbox:sub {"technology"} -- 主界面左下角 -> 科研中心
local construct_entity_mb = mailbox:sub {"construct_entity"} -- 建造 entity
local click_techortaskicon_mb = mailbox:sub {"click_techortaskicon"}
local load_resource_mb = mailbox:sub {"load_resource"}
local construct_mb = mailbox:sub {"construct"} -- 施工
local single_touch_mb = world:sub {"single_touch"}
local move_mb = mailbox:sub {"move"}
local move_finish_mb = mailbox:sub {"move_finish"}
local builder_back_mb = mailbox:sub {"builder_back"}
local construction_center_place_mb = mailbox:sub {"construction_center_place"}
local pickup_mb = world:sub {"pickup"}
local handle_pickup = true
local single_touch_move_mb = world:sub {"single_touch", "MOVE"}
local builder

local function _get_construct_menu()
    local construct_menu = {}
    for _, menu in ipairs(construct_menu_cfg) do
        local m = {}
        m.name = menu.name
        m.icon = menu.icon
        m.detail = {}

        for _, prototype_name in ipairs(menu.detail) do
            local typeobject = assert(iprototype.queryByName(prototype_name))
            m.detail[#m.detail + 1] = {
                show_prototype_name = iprototype.show_prototype_name(typeobject),
                prototype_name = prototype_name,
                icon = typeobject.icon,
            }
        end

        construct_menu[#construct_menu+1] = m
    end
    return construct_menu
end

---------------
local M = {}
local function get_new_tech_count(tech_list)
    local count = 0
    for _, tech in ipairs(tech_list) do
        if global.science.tech_picked_flag[tech.detail.name] then
            count = count + 1
        end
    end
    return count
end
function M:create()
    return {
        show_load_resource = SHOW_LOAD_RESOURCE,
        construct_menu = {},
        tech_count = get_new_tech_count(global.science.tech_list),
        show_tech_progress = false,
        current_tech_icon = "none",    --当前科技图标
        current_tech_name = "none",    --当前科技名字
        current_tech_progress = "0%",  --当前科技进度
    }
end

function M:update_tech(datamodel, tech)
    if tech then
        datamodel.show_tech_progress = true
        datamodel.is_task = tech.task
        datamodel.current_tech_name = tech.name
        datamodel.current_tech_icon = tech.detail.icon
        datamodel.current_tech_progress = (tech.progress * 100) // tech.detail.count .. '%'
    else
        datamodel.show_tech_progress = false
        datamodel.tech_count = get_new_tech_count(global.science.tech_list)
    end
end

function M:construct_queue(datamodel, construct_queue)
    datamodel.construct_queue = construct_queue
end

function M:stage_ui_update(datamodel)
    for _ in rotate_mb:unpack() do
        if builder then
            builder:rotate_pickup_object(datamodel)
        end
    end

    for _ in build_mb:unpack() do
        if builder then
            builder:confirm(datamodel)
        end
        self:flush()
    end

    for _, _, _, x, y in confirm_cancel_mb:unpack() do
        local object = objects:coord(x, y, EDITOR_CACHE_NAMES)
        assert(object)
        assert(object.object_state == "confirm")
        objects:remove(object.id, "CONFIRM")
        iobject.remove(object)
        global.construct_queue:remove(object.prototype_name, object.id)
        iui.close("construct_confirm_pop.rml")
        datamodel.show_construct = false
    end

    for _ in cancel_mb:unpack() do
        if builder then
            builder:clean(datamodel)
            builder = nil
        end
        handle_pickup = true
    end

    for _, _, _, show in show_construct_menu_mb:unpack() do
        if show then
            idetail.unselected()
            ieditor:revert_changes({"TEMPORARY"})
            datamodel.show_rotate = false
            datamodel.show_confirm = false
            datamodel.construct_menu = _get_construct_menu()
        else
            ieditor:revert_changes({"TEMPORARY"})
        end
    end

    for _, _, _, is_task in click_techortaskicon_mb:unpack() do
        if gameplay_core.world_update and global.science.current_tech then
            gameplay_core.world_update = false
            iui.open(is_task and {"task_pop.rml"} or {"science.rml"})
        end
    end

    --任务完成提示界面
    for _ in technology_mb:unpack() do
        gameplay_core.world_update = false
        iui.open({"science.rml"})
    end

    for _ in show_statistic_mb:unpack() do
        iui.open({"statistics.rml"})
    end

    for _ in show_setting_mb:unpack() do
        iui.open({"option_pop.rml"})
    end

    for _ in load_resource_mb:unpack() do
        iui.open({"loading.rml"}, false)
        camera.init("camera_default.prefab")
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
        if builder then
            builder:clean(datamodel)
        end

        local typeobject = iprototype.queryByName(prototype_name)
        if iprototype.is_pipe_to_ground(prototype_name) then
            builder = create_pipetogroundbuilder()
        elseif iprototype.is_pipe(prototype_name) then
            builder = create_pipebuilder()
        elseif typeobject.crossing then
            builder = create_station_builder()
        else
            builder = create_normalbuilder()
        end

        builder:new_entity(datamodel, typeobject)
        self:flush()
        handle_pickup = false
    end

    for _, _, _, object_id in move_mb:unpack() do
        if builder then
            builder:clean(datamodel)
        end

        idetail.unselected()
        ieditor:revert_changes({"TEMPORARY"})

        local object = assert(objects:get(object_id))
        local prototype_name = object.prototype_name
        builder = create_movebuilder(object_id)

        local typeobject = iprototype.queryByName(prototype_name)
        builder:new_entity(datamodel, typeobject)
        self:flush()
        handle_pickup = false
    end

    for _ in move_finish_mb:unpack() do
        handle_pickup = true
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

    local function _get_object(pickup_x, pickup_y)
        for _, pos in ipairs(icamera.screen_to_world(pickup_x, pickup_y, PLANES)) do
            local coord = terrain:get_coord_by_position(pos)
            if coord then
                local object = objects:coord(coord[1], coord[2], EDITOR_CACHE_NAMES)
                if object then
                    return object
                end
            end
        end
    end

    -- 点击其它建筑 或 拖动时, 将弹出窗口隐藏
    for _, _, x, y in pickup_mb:unpack() do
        if not handle_pickup then
            goto continue
        end

        local object = _get_object(x, y)
        if object then -- object may be nil, such as when user click on empty space
            if object.object_state == "constructed" then
                if idetail.show(object.id) then
                    leave = false
                end
            elseif object.object_state == "confirm" then
                iui.open({"construct_confirm_pop.rml"}, object.srt.t, object.x, object.y)
                leave = false
            end
        else
            idetail.unselected()
        end

        if leave then
            world:pub {"ui_message", "leave"}
            leave = false
            break
        end
        ::continue::
    end

    for _ in single_touch_move_mb:unpack() do
        if leave then
            world:pub {"ui_message", "leave"}
            leave = false
            break
        end
    end

    for _ in construct_mb:unpack() do
        local pbuilder = create_builder()
        for prototype_name in global.construct_queue:for_each() do
            local object_id = global.construct_queue:pop(prototype_name)
            if builder and builder.complete then
                builder:complete(object_id)
            else
                pbuilder:complete(object_id)
            end
        end

        if builder then
            builder:clean(datamodel)
            builder = nil
        end
        self:flush()

        datamodel.cur_edit_mode = ""
        handle_pickup = true
    end

    for _ in road_builder_mb:unpack() do
        iui.close("build_function_pop.rml")
        iui.close("detail_panel.rml")
        datamodel.cur_edit_mode = "construct"
        idetail.unselected()
        handle_pickup = false
        gameplay_core.world_update = false
        iui.open({"road_or_pipe_build.rml", "road_build.lua"})
    end

    for _ in pipe_builder_mb:unpack() do
        iui.close("build_function_pop.rml")
        iui.close("detail_panel.rml")
        datamodel.cur_edit_mode = "construct"
        idetail.unselected()
        handle_pickup = false
        gameplay_core.world_update = false
        iui.open({"road_or_pipe_build.rml", "pipe_build.lua"})
    end

    for _ in builder_back_mb:unpack() do
        datamodel.cur_edit_mode = ""
        handle_pickup = true
        gameplay_core.world_update = true
        iui.close("road_or_pipe_build.rml")
    end

    for _, _, _, prototype_name, gameplay_eid, item in construction_center_place_mb:unpack() do
        if builder then
            builder:clean(datamodel)
        end

        builder = create_setitembuilder(gameplay_eid, item)
        local typeobject = iprototype.queryByName(prototype_name)
        builder:new_entity(datamodel, typeobject)
        self:flush()
        handle_pickup = false
    end

    iobject.flush()
end
return M