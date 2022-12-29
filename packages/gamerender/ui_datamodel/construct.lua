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
local ipower_line = ecs.require "power_line"
local idetail = ecs.import.interface "vaststars.gamerender|idetail"
local construct_menu_cfg = import_package "vaststars.prototype"("construct_menu")
local DISABLE_FPS = require("debugger").disable_fps
local SHOW_LOAD_RESOURCE = not require("debugger").disable_load_resource
local EDITOR_CACHE_NAMES = {"CONFIRM", "CONSTRUCTED"}
local create_builder = ecs.require "editor.builder"

local rotate_mb = mailbox:sub {"rotate"} -- construct_pop.rml -> 旋转
local build_mb = mailbox:sub {"build"}   -- construct_pop.rml -> 修建
local cancel_mb = mailbox:sub {"cancel"} -- construct_pop.rml -> 取消
local confirm_cancel_mb = mailbox:sub {"confirm_cancel"} -- 取消已确定的建筑
local iworld = require "gameplay.interface.world"
local tracedoc = require "utility.tracedoc"

local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local show_construct_menu_mb = mailbox:sub {"show_construct_menu"}
local show_setting_mb = mailbox:sub {"show_setting"} -- 主界面左下角 -> 游戏设置
local technology_mb = mailbox:sub {"technology"} -- 主界面左下角 -> 科研中心
local construct_entity_mb = mailbox:sub {"construct_entity"} -- 建造 entity
local laying_pipe_begin_mb = mailbox:sub {"laying_pipe_begin"} -- 铺管开始
local laying_pipe_cancel_mb = mailbox:sub {"laying_pipe_cancel"} -- 铺管取消
local laying_pipe_confirm_mb = mailbox:sub {"laying_pipe_confirm"} -- 铺管结束
local open_taskui_event = mailbox:sub {"open_taskui"}
local load_resource_mb = mailbox:sub {"load_resource"}
local construct_mb = mailbox:sub {"construct"} -- 施工
local single_touch_mb = world:sub {"single_touch"}
local pickup_mb = world:sub {"pickup"}
local handle_pickup = true
local single_touch_move_mb = world:sub {"single_touch", "MOVE"}
local builder
local iroadnet = ecs.require "roadnet"
local ltask = require "ltask"
local ltask_now = ltask.now
local last_update_time

local function _gettime()
    local _, t = ltask_now() --10ms
    return t * 10
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

-- TODO
function M:fps_text(datamodel, text)
    if DISABLE_FPS then
        return
    end
    datamodel.fps_text = text
end

function M:drawcall_text(datamodel, text)
    if DISABLE_FPS then
        return
    end
    datamodel.drawcall_text = text
end

function M:show_chapter(datamodel, main_text, sub_text)
    datamodel.show_chapter = true
    datamodel.chapter_main_text = main_text
    datamodel.chapter_sub_text = sub_text
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
            last_prototype_name = nil

            datamodel.construct_menu = _get_construct_menu()
            ipower_line.show_supply_area()
        else
            ieditor:revert_changes({"TEMPORARY", "POWER_AREA"})
        end
    end

    for _, _, _, is_task in open_taskui_event:unpack() do
        if gameplay_core.world_update and global.science.current_tech then
            gameplay_core.world_update = false
            iui.open(is_task and "task_pop.rml" or "science.rml")
        end
    end

    --任务完成提示界面
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

    for _ in load_resource_mb:unpack() do
        iui.open("loading.rml", false)
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
        handle_pickup = false
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

    local function _get_road(pickup_x, pickup_y)
        for _, pos in ipairs(icamera.screen_to_world(pickup_x, pickup_y, PLANES)) do
            local coord = terrain:get_coord_by_position(pos)
            if coord then
                local road = iroadnet.editor_get(coord[1], coord[2])
                if road then
                    return coord[1], coord[2]
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
        local coord_x, coord_y = _get_road(x, y)
        if object then -- object may be nil, such as when user click on empty space
            if object.object_state == "constructed" then
                if idetail.show(object.id) then
                    leave = false
                end
            elseif object.object_state == "confirm" then
                iui.open("construct_confirm_pop.rml", object.srt.t, object.x, object.y)
                leave = false
            end
        elseif coord_x then
            if idetail.show_road(coord_x, coord_y) then
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
            local typeobject = iprototype.queryByName("item", prototype_name)
            local count = global.base_chest[typeobject.id] or 0
            local total_count = global.construct_queue:size(prototype_name)
            count = math.min(count, total_count)
            assert(total_count > 0)

            if count > 0 then
                for i = 1, count do
                    local object_id = global.construct_queue:pop(prototype_name)
                    pbuilder:complete(object_id)
                end

                -- decrease item count
                assert(iworld.base_chest_pickup(gameplay_core.get_world(), typeobject.id, count))
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

    --
    local current = _gettime()
    last_update_time = last_update_time or current
    if current - last_update_time > 1000 then
        last_update_time = current
        global.base_chest = tracedoc.new(iworld.base_chest(gameplay_core.get_world()))
    end

    if tracedoc.changed(global.base_chest) or global.construct_queue:changed() then
        local construct_queue = {}
        for prototype_name in global.construct_queue:for_each() do
            local typeobject = iprototype.queryByName("item", prototype_name)
            local count = global.base_chest[typeobject.id] or 0
            local total_count = global.construct_queue:size(prototype_name)
            count = math.min(count, total_count)
            table.insert(construct_queue, {icon = typeobject.icon, count = count, total_count = total_count})
        end
        datamodel.construct_queue = construct_queue

        tracedoc.commit(global.base_chest)
        global.construct_queue:commit()
    end

    iobject.flush()
end
return M