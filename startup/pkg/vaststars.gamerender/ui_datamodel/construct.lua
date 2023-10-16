local ecs, mailbox = ...
local world = ecs.world

local CONSTANT <const> = require("gameplay.interface.constant")
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local ROAD_SIZE <const> = CONSTANT.ROAD_SIZE
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local EDITOR_CACHE_NAMES <const> = {"CONFIRM", "CONSTRUCTED"}
local CLASS <const> = {
    Lorry = 1,
    Object = 2,
    Mineral = 3,
    Mountain = 4,
    Road = 5,
}

local math3d = require "math3d"
local XZ_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local COLOR_GREEN = math3d.constant("v4", {0.3, 1, 0, 1})

local icamera_controller = ecs.require "engine.system.camera_controller"
local gameplay_core = require "gameplay.core"
local iui = ecs.require "engine.system.ui_system"
local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local create_normalbuilder = ecs.require "editor.normalbuilder"
local create_movebuilder = ecs.require "editor.movebuilder"
local create_roadbuilder = ecs.require "editor.roadbuilder"
local create_pipebuilder = ecs.require "editor.pipebuilder"
local create_pipetogroundbuilder = ecs.require "editor.pipetogroundbuilder"
local objects = require "objects"
local global = require "global"
local iobject = ecs.require "object"
local idetail = ecs.require "detail_system"
local create_station_builder = ecs.require "editor.stationbuilder"
local terrain = ecs.require "terrain"
local selected_boxes = ecs.require "selected_boxes"
local irl = ecs.require "ant.render|render_layer.render_layer"
local iom = ecs.require "ant.objcontroller|obj_motion"
local ichest = require "gameplay.interface.chest"
local ipower_line = ecs.require "power_line"
local ipick_object = ecs.require "pick_object_system"
local ibackpack = require "gameplay.interface.backpack"
local gesture_longpress_mb = world:sub{"gesture", "longpress"}
local igameplay = ecs.require "gameplay_system"
local audio = import_package "ant.audio"
local ilorry = ecs.require "render_updates.lorry"
local igame_object = ecs.require "engine.game_object"
local rotate_mb = mailbox:sub {"rotate"}
local build_mb = mailbox:sub {"build"}
local quit_mb = mailbox:sub {"quit"}
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local click_techortaskicon_mb = mailbox:sub {"click_techortaskicon"}
local guide_on_going_mb = mailbox:sub {"guide_on_going"}
local help_mb = mailbox:sub {"help"}
local move_md = mailbox:sub {"move"}
local teardown_mb = mailbox:sub {"teardown"}
local construct_entity_mb = mailbox:sub {"construct_entity"}
local backpack_mb = mailbox:sub {"backpack"}
local focus_tips_event = world:sub {"focus_tips"}
local construct_mb = mailbox:sub {"construct"}
local ipower = ecs.require "power"
local main_button_tap_mb = mailbox:sub {"main_button_tap"}
local main_button_longpress_mb = mailbox:sub {"main_button_longpress"}
local start_laying_mb = mailbox:sub {"start_laying"}
local finish_laying_mb = mailbox:sub {"finish_laying"}
local start_teardown_mb = mailbox:sub {"start_teardown"}
local finish_teardown_mb = mailbox:sub {"finish_teardown"}
local remove_one_mb = mailbox:sub {"remove_one"}
local unselected_mb = mailbox:sub {"unselected"}
local gesture_tap_mb = world:sub{"gesture", "tap"}
local gesture_pan_mb = world:sub {"gesture", "pan"}
local lock_axis_mb = mailbox:sub {"lock_axis"}
local unlock_axis_mb = mailbox:sub {"unlock_axis"}
local settings_mb = mailbox:sub {"settings"}

local builder, builder_datamodel, builder_ui
local excluded_pickup_id -- object id
local pick_lorry_id
local selected_obj

local LockAxis = false
local LockAxisStatus = {
    status = false,
    BeginX = 0,
    BeginY = 0,
}

local function __on_pick_building(datamodel, o)
    local object = o.object
    if excluded_pickup_id and excluded_pickup_id == object.id then
        return
    end

    iui.open({rml = "/pkg/vaststars.resources/ui/detail_panel.rml"}, object.id)
    if datamodel.is_concise_mode then
        return true
    end

    iui.close("/pkg/vaststars.resources/ui/build.rml") -- TODO: remove this
    iui.close("/pkg/vaststars.resources/ui/construct_road_or_pipe.rml")

    local typeobject = iprototype.queryByName(object.prototype_name)
    if typeobject.base then
        typeobject = iprototype.queryByName(typeobject.base)
    end

    datamodel.focus_building_icon = typeobject.item_icon

    selected_obj = o
    datamodel.status = "focus"

    idetail.focus(assert(object.gameplay_eid))
    return true
end

local function __on_pick_non_building(datamodel, o, force)
    local typeobject = iprototype.queryByName(o.name)
    if typeobject.base then
        typeobject = iprototype.queryByName(typeobject.base)
    end

    iui.open({rml = "/pkg/vaststars.resources/ui/non_building_detail_panel.rml"}, typeobject.icon, iprototype.display_name(typeobject), o.eid)
    if datamodel.is_concise_mode and force ~= true then
        return true
    end

    datamodel.focus_building_icon = typeobject.item_icon

    selected_obj = o
    datamodel.status = "focus"

    if o.x and o.y and o.w and o.h then
        idetail.focus_non_building(o.x, o.y, o.w, o.h)
    else
        idetail.unselected()
    end
    return true
end

local function __unpick_lorry(lorry_id)
    local lorry = ilorry.get(lorry_id)
    if lorry then
        lorry:show_arrow(false)
    end
end

local status = "default"
local function __switch_status(s, cb)
    if status == s then
        if cb then
            cb()
        end
        return
    end
    status = s

    local pos = icamera_controller.get_central_position()
    pos = math3d.set_index(pos, 2, 0)

    if status == "default" then
        icamera_controller.toggle_view("default", math3d.ref(pos), cb)
        igame_object.stop_world()
    elseif status == "construct" then
        icamera_controller.toggle_view("construct", math3d.ref(pos), cb)
        igame_object.restart_world()
    end
end

local function __clean(datamodel, unlock)
    if builder then
        builder:clean(builder_datamodel)
        builder, builder_datamodel = nil, nil
        iui.close(builder_ui)
    end
    idetail.unselected()
    datamodel.is_concise_mode = false
    datamodel.focus_building_icon = ""
    iui.close("/pkg/vaststars.resources/ui/build.rml") -- TODO: remove this
    iui.close("/pkg/vaststars.resources/ui/construct_road_or_pipe.rml")
    datamodel.status = "normal"
    iui.leave()

    LockAxisStatus = {
        status = false,
        BeginX = 0,
        BeginY = 0,
    }

    if unlock == false then
        return
    end
    icamera_controller.unlock_axis()
    log.info("unlock axis")
end

---------------
local M = {}

function M.create()
    return {
        is_concise_mode = false,
        show_tech_progress = false,
        current_tech_icon = "none",    --当前科技图标
        current_tech_name = "none",    --当前科技名字
        current_tech_progress = "0%",  --当前科技进度
        current_tech_progress_detail = "0/0",  --当前科技进度(数量),
        ingredient_icons = {},
        show_ingredient = false,
        category_idx = 0,
        item_idx = 0,
        status = "normal",
        tech_count = #global.science.tech_list,
    }
end

local current_techname = ""
function M.update_tech(datamodel, tech)
    if tech then
        if current_techname ~= tech.name then
            local ingredient_icons = {}
            local ingredients = irecipe.get_elements(tech.detail.ingredients)
            for _, ingredient in ipairs(ingredients) do
                if ingredient.tech_icon ~= '' then
                    ingredient_icons[#ingredient_icons + 1] = {icon = assert(ingredient.tech_icon), count = ingredient.count}
                end
            end
            current_techname = tech.name
            datamodel.ingredient_icons = ingredient_icons
            if #ingredient_icons > 0 then
                datamodel.show_ingredient = true
            else
                datamodel.show_ingredient = false
            end
        end
        datamodel.show_tech_progress = true
        datamodel.is_task = tech.task
        datamodel.current_tech_name = tech.name
        datamodel.current_tech_icon = tech.detail.icon
        datamodel.current_tech_progress = (tech.progress * 100) // tech.detail.count .. '%'
        datamodel.current_tech_progress_detail = tech.progress.."/"..tech.detail.count
    else
        datamodel.show_tech_progress = false
        datamodel.tech_count = #global.science.tech_list
    end
end

function M.update_backpack_bar(datamodel, t)
    datamodel.backpack_bar = {}
    for _, v in ipairs(t) do
        datamodel.backpack_bar[#datamodel.backpack_bar + 1] = v
        if #datamodel.backpack_bar >= 4 then
            break
        end
    end
end

local function open_focus_tips(tech_node)
    local focus = tech_node.detail.guide_focus
    if not focus then
        return
    end
    local width, height
    for _, nd in ipairs(focus) do
        if nd.prefab then
            if not width or not height then
                width, height = nd.w, nd.h
            end
            if not tech_node.selected_tips then
                tech_node.selected_tips = {}
            end

            local prefab
            local center = terrain:get_position_by_coord(nd.x, nd.y, 1, 1)
            if nd.show_arrow then
                prefab = assert(world:create_instance({
                    prefab = "/pkg/vaststars.resources/glbs/arrow-guide.glb|mesh.prefab",
                    on_ready = function(self)
                        for _, eid in ipairs(self.tag['*']) do
                            local e <close> = world:entity(eid, "render_object?in")
                            if e.render_object then
                                irl.set_layer(e, RENDER_LAYER.SELECTED_BOXES)
                            end
                        end

                        local root <close> = world:entity(assert(self.tag['*'][1]))
                        iom.set_position(root, center)
                    end,
                }))
            end
            if nd.force then
                local object = objects:coord(nd.x, nd.y, EDITOR_CACHE_NAMES)
                if object then
                    excluded_pickup_id = object.id
                end
            end
            tech_node.selected_tips[#tech_node.selected_tips + 1] = {selected_boxes({"/pkg/vaststars.resources/" .. nd.prefab}, center, COLOR_GREEN, nd.w, nd.h), prefab}
        elseif nd.camera_x and nd.camera_y then
            icamera_controller.focus_on_position(terrain:get_position_by_coord(nd.camera_x, nd.camera_y, width, height))
        end
    end
end

local function close_focus_tips(tech_node)
    local selected_tips = tech_node.selected_tips
    if not selected_tips then
        return
    end
    for _, tip in ipairs(selected_tips) do
        tip[1]:remove()
        if tip[2] then
            world:remove_instance(tip[2])
        end
    end
    tech_node.selected_tips = {}
    excluded_pickup_id = nil
end

local function __construct_entity(typeobject)
    idetail.unselected()
    gameplay_core.world_update = false

    if iprototype.has_type(typeobject.type, "road") then
        local x, y = iobject.central_coord(typeobject.name, DEFAULT_DIR)
        x, y = x - (x % ROAD_SIZE), y - (y % ROAD_SIZE)

        builder_ui = "/pkg/vaststars.resources/ui/construct_road_or_pipe.rml" -- TODO: remove this
        builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct.rml")
        builder = create_roadbuilder()
        builder:new_entity(builder_datamodel, typeobject, x, y)
    elseif iprototype.has_type(typeobject.type, "pipe") then
        local x, y = iobject.central_coord(typeobject.name, DEFAULT_DIR)
        x, y = x - (x % ROAD_SIZE), y - (y % ROAD_SIZE)

        builder_ui = "/pkg/vaststars.resources/ui/construct_road_or_pipe.rml" -- TODO: remove this
        builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct.rml")
        builder = create_pipebuilder()
        builder:new_entity(builder_datamodel, typeobject, x, y)
    elseif iprototype.has_type(typeobject.type, "pipe_to_ground") then
        local x, y = iobject.central_coord(typeobject.name, DEFAULT_DIR)
        x, y = x - (x % ROAD_SIZE), y - (y % ROAD_SIZE)

        builder_ui = "/pkg/vaststars.resources/ui/construct_road_or_pipe.rml"  -- TODO: remove this
        builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct.rml")
        builder = create_pipetogroundbuilder()
        builder:new_entity(builder_datamodel, typeobject, x, y)
    elseif iprototype.has_types(typeobject.type, "station", "park") then
        builder_ui = "/pkg/vaststars.resources/ui/construct_building.rml"
        builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct.rml")
        builder = create_station_builder()
        builder:new_entity(builder_datamodel, typeobject)
    else
        builder_ui = "/pkg/vaststars.resources/ui/construct_building.rml"
        builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct.rml")
        builder = create_normalbuilder(typeobject.id)
        builder:new_entity(builder_datamodel, typeobject)
    end
end

local function move_focus(e)
	local dx = math.abs(e.x - LockAxisStatus.BeginX)
	local dy = math.abs(e.y - LockAxisStatus.BeginY)
	if dx > 10 or dy > 10 then
		LockAxisStatus.BeginX = e.x
		LockAxisStatus.BeginY = e.y
		LockAxisStatus.count = 0
		return
	end
	local count = LockAxisStatus.count + 1
	if count > 3 then
		if dx > dy * 2 then
			return "z-axis"
		elseif dy > dx * 2 then
			return "x-axis"
		else
			LockAxisStatus.BeginX = e.x
			LockAxisStatus.BeginY = e.y
			LockAxisStatus.count = 0
			return
		end
	else
		LockAxisStatus.count = count
	end
end

local function pickupObject(datamodel, position, func)
    local coord = terrain:get_coord_by_position(position)
    if not coord then
        return false
    end

    local o = ipick_object[func](coord[1], coord[2])
    if o and o.class == CLASS.Lorry then
        if pick_lorry_id then
            __unpick_lorry(pick_lorry_id)
        end
        idetail.unselected()
        pick_lorry_id = o.id

        if __on_pick_non_building(datamodel, o) then
            local lorry = ilorry.get(pick_lorry_id)
            if lorry then
                lorry:show_arrow(true)
            end
            return true
        end
    elseif o and o.class == CLASS.Object then
        idetail.unselected()
        iui.close("/pkg/vaststars.resources/ui/construct_road_or_pipe.rml") -- TODO: remove this
        if __on_pick_building(datamodel, o) then
            __unpick_lorry(pick_lorry_id)
            pick_lorry_id = nil
            return true
        end
    elseif o and (o.class == CLASS.Mineral or o.class == CLASS.Mountain or o.class == CLASS.Road)then
        idetail.unselected()
        iui.close("/pkg/vaststars.resources/ui/construct_road_or_pipe.rml") -- TODO: remove this
        if __on_pick_non_building(datamodel, o) then
            __unpick_lorry(pick_lorry_id)
            pick_lorry_id = nil
            return true
        end
    else
        __unpick_lorry(pick_lorry_id)
        pick_lorry_id = nil

        idetail.unselected()
    end

    return false
end

function M.update(datamodel)
    for _ in rotate_mb:unpack() do
        if builder and builder.rotate then
            builder:rotate(builder_datamodel)
        end
    end

    for _ in build_mb:unpack() do
        if builder and builder.confirm then
            builder:confirm(builder_datamodel)
            audio.play "event:/function/place"
        end
    end

    for _ in quit_mb:unpack() do
        __clean(datamodel)
        __switch_status("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end

    for _ in guide_on_going_mb:unpack() do
        __clean(datamodel)
        __switch_status("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end

    for _ in click_techortaskicon_mb:unpack() do
        gameplay_core.world_update = false
        iui.open({rml = "/pkg/vaststars.resources/ui/science.rml"})
    end

    for _ in help_mb:unpack() do
        if not iui.is_open("/pkg/vaststars.resources/ui/help_panel.rml") then
            iui.open({rml = "/pkg/vaststars.resources/ui/help_panel.rml"})
        else
            iui.close("/pkg/vaststars.resources/ui/help_panel.rml")
        end
    end

    local dragdrop_delta
    for _, delta in dragdrop_camera_mb:unpack() do
        dragdrop_delta = delta
    end
    if dragdrop_delta and builder then
        builder:touch_move(builder_datamodel, dragdrop_delta)
    end

    for _, _, e in gesture_pan_mb:unpack() do
        if e.state == "began" then
            iui.leave()
        end

        if builder then
            if e.state == "began" then
                if LockAxis and LockAxisStatus.status == false then
                    log.info("lock axis begin", e.x, e.y)
                    LockAxisStatus.BeginX, LockAxisStatus.BeginY = e.x, e.y
                    LockAxisStatus.count = 0
                end
            elseif e.state == "changed" then
                if LockAxis and LockAxisStatus.status == false then
                    local p = move_focus(e)
                    if p then
                        log.info("lock axis ", p)
                        icamera_controller.lock_axis(p)
                        LockAxisStatus.status = true
                    end
                end
            elseif e.state == "ended" then
                log.info("unlock axis")
                icamera_controller.unlock_axis()
                LockAxisStatus.status = false

                builder:touch_end(builder_datamodel)
            end
        end
    end

    local leave = true
    local gesture_tap_changed = false
    for _, _, v in gesture_tap_mb:unpack() do
        iui.leave()
        gesture_tap_changed = true
        local pos = icamera_controller.screen_to_world(v.x, v.y, XZ_PLANE)
        if pickupObject(datamodel, pos, "blur_pick") then
            audio.play "event:/ui/click"
            leave = false
        end
    end

    local longpress_startpoint = {}
    for _, _, e in gesture_longpress_mb:unpack() do
        if e.state == "began" then
            local pos = icamera_controller.screen_to_world(e.x, e.y, XZ_PLANE)
            pickupObject(datamodel, pos, "pick")
            icamera_controller.lock_axis("xz-axis")
            icamera_controller.toggle_view("pickup", math3d.ref(math3d.set_index(pos, 2, 0)))

        elseif e.state == "changed" then
            longpress_startpoint.x = e.x
            longpress_startpoint.y = e.y

        elseif e.state == "ended" then
            longpress_startpoint = nil

            local pos = icamera_controller.get_central_position()
            pos = math3d.set_index(pos, 2, 0)
            icamera_controller.toggle_view("default", math3d.ref(math3d.set_index(pos, 2, 0)), function()
                icamera_controller.unlock_axis()
            end)
        end
    end

    if longpress_startpoint and longpress_startpoint.x and longpress_startpoint.y then
        log.info("longpress_startpoint", longpress_startpoint.x, longpress_startpoint.y)
        __clean(datamodel, false)
        local pos = icamera_controller.screen_to_world(longpress_startpoint.x, longpress_startpoint.y, XZ_PLANE)
        pickupObject(datamodel, pos, "pick")
    end

    for _, _, _, object_id in teardown_mb:unpack() do
        iui.leave()
        idetail.unselected()
        datamodel.status = "normal"
        datamodel.focus_building_icon = ""
        selected_obj = nil

        local object = assert(objects:get(object_id))
        local gameplay_world = gameplay_core.get_world()
        local typeobject = iprototype.queryByName(object.prototype_name)

        local e = gameplay_core.get_entity(object.gameplay_eid)
        if e.chest then
            if not ibackpack.can_move_to_backpack(gameplay_world, e) then
                log.error("can not teardown")
                goto continue
            end

            for i = 1, ichest.MAX_SLOT do
                local slot = ichest.get(gameplay_world, e.chest, i)
                if not slot then
                    break
                end
                ibackpack.move_to_backpack(gameplay_world, e, i)
            end
        end

        ibackpack.place(gameplay_world, typeobject.id, 1)
        igameplay.destroy_entity(object.gameplay_eid)
        gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

        if typeobject.power_network_link or typeobject.power_supply_distance then
            ipower:build_power_network(gameplay_world)
            ipower_line.update_line(ipower:get_pole_lines())
        end

        iobject.remove(object)
        objects:remove(object_id)
        local building = global.buildings[object_id]
        if building then
            for _, v in pairs(building) do
                v:remove()
            end
        end
        ::continue::
    end

    if gesture_tap_changed and leave then
        __clean(datamodel)
        __switch_status("default", function()
            __clean(datamodel)
            gameplay_core.world_update = true
        end)

        iui.leave()
    end

    for _, _, _, object_id in move_md:unpack() do
        __switch_status("construct", function()
            if builder then
                builder:clean(builder_datamodel)
            end

            local object = assert(objects:get(object_id))
            local typeobject = iprototype.queryByName(object.prototype_name)
            gameplay_core.world_update = false

            idetail.unselected()
            builder_ui = "/pkg/vaststars.resources/ui/move_building.rml"
            builder_datamodel = iui.open({rml = "/pkg/vaststars.resources/ui/move_building.rml"}, object.prototype_name)
            builder = create_movebuilder(object_id)
            builder:new_entity(builder_datamodel, typeobject)
        end)
    end

    for _, _, _, name in construct_entity_mb:unpack() do
        if name == "" then
            goto continue
        end
        local typeobject = iprototype.queryByName(name)
        if ibackpack.query(gameplay_core.get_world(), typeobject.id) >= 1 then
            idetail.unselected()
            gameplay_core.world_update = false

            -- we may click the button repeatedly, so we need to clear the old model first
            if builder then
                builder:clean(builder_datamodel)
                builder, builder_datamodel = nil, nil
                iui.close(builder_ui)
            end
            __construct_entity(typeobject)
        end
        ::continue::
    end

    -- TODO: 多个UI的 update() 中会产生focus_tips_event事件，focus_tips_event处理逻辑涉及到要修改相机位置，所以暂时放在这里处理
    for _, action, tech_node in focus_tips_event:unpack() do
        if action == "open" then
            open_focus_tips(tech_node)
        elseif action == "close" then
            close_focus_tips(tech_node)
        end
    end

    for _ in construct_mb:unpack() do
        datamodel.is_concise_mode = true
        __switch_status("construct", function()
            iui.open({rml = "/pkg/vaststars.resources/ui/build.rml"})
            gameplay_core.world_update = false
        end)
    end

    for _ in main_button_tap_mb:unpack() do
        if datamodel.status == "selected" then
            __unpick_lorry(pick_lorry_id)
            iui.leave()
            idetail.unselected()
            datamodel.status = "normal"
            datamodel.focus_building_icon = ""
        else
            if selected_obj then
                datamodel.status = "selected"

                if selected_obj.class == CLASS.Lorry then
                    iui.open({rml = "/pkg/vaststars.resources/ui/building_menu.rml"}, pick_lorry_id)
                    idetail.selected(pick_lorry_id)

                    local e = assert(gameplay_core.get_entity(pick_lorry_id))
                    icamera_controller.focus_on_position(terrain:get_position_by_coord(e.lorry.x, e.lorry.y, 1, 1))

                elseif selected_obj.class == CLASS.Object and not iprototype.is_pipe(selected_obj.object.prototype_name) then -- TODO: optimize
                    local object = selected_obj.object
                    icamera_controller.focus_on_position(object.srt.t)

                    idetail.show(object.id)
                    idetail.selected(object.gameplay_eid)
                else
                    if selected_obj.get_pos then
                        icamera_controller.focus_on_position(selected_obj:get_pos())
                    end

                    if iprototype.is_road(selected_obj.name) or iprototype.is_pipe(selected_obj.name) or iprototype.is_pipe_to_ground(selected_obj.name) then
                        datamodel.focus_building_icon = ""
                        iui.open({rml = "/pkg/vaststars.resources/ui/construct_road_or_pipe.rml"}, selected_obj.name, {show_start_laying = true})
                    end

                    if not iprototype.is_pipe(selected_obj.name) then
                        local typeobject = iprototype.queryByName(selected_obj.name)
                        iui.open({rml = "/pkg/vaststars.resources/ui/non_building_detail_panel.rml"}, typeobject.item_icon, iprototype.display_name(typeobject), selected_obj.eid)
                    end
                end
            else
                log.error("no target selected")
            end
        end
    end

    for _ in unselected_mb:unpack() do
        __unpick_lorry(pick_lorry_id)
        iui.leave()
        idetail.unselected()
        datamodel.status = "normal"
        datamodel.focus_building_icon = ""
        selected_obj = nil
    end

    for _ in main_button_longpress_mb:unpack() do
        iui.leave()

        assert(selected_obj)
        if selected_obj.class == CLASS.Object then
            local object = selected_obj.object
            if excluded_pickup_id and excluded_pickup_id == object.id then
                goto continue
            end

            idetail.selected(object.gameplay_eid)

            local prototype_name = object.prototype_name
            local typeobject = iprototype.queryByName(prototype_name)
            if typeobject.move == false and typeobject.teardown == false then
                goto continue
            end

            iui.open({rml = "/pkg/vaststars.resources/ui/building_menu_longpress.rml"}, object.id)
        elseif selected_obj.class == CLASS.Road then
            iui.open({rml = "/pkg/vaststars.resources/ui/construct_road_or_pipe.rml"}, selected_obj.name, {show_remove_one = true, show_start_teardown = true})
        end

        ::continue::
    end

    for _, _, _, prototype_name in start_laying_mb:unpack() do
        local create_builder
        if iprototype.is_road(prototype_name) then
            goto continue
        elseif iprototype.is_pipe(prototype_name) then
            create_builder = create_pipebuilder
        else
            assert(false)
        end

        __switch_status("construct", function()
            assert(selected_obj)
            if selected_obj.get_pos then
                icamera_controller.focus_on_position(selected_obj:get_pos())
            end

            gameplay_core.world_update = false
            local typeobject = iprototype.queryByName(prototype_name)
            assert(typeobject.base)
            typeobject = iprototype.queryByName(typeobject.base)
            builder_ui = "/pkg/vaststars.resources/ui/construct_road_or_pipe.rml"
            builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct_road_or_pipe.rml")
            datamodel.is_concise_mode = true
            builder_datamodel.is_concise_mode = true
            builder = create_builder()
            builder:new_entity(builder_datamodel, typeobject, selected_obj.x, selected_obj.y)
            builder:start_laying(builder_datamodel)
        end)
        ::continue::
    end

    for _, _, _, prototype_name in start_teardown_mb:unpack() do
        local create_builder
        if iprototype.is_road(prototype_name) then
            goto continue
        elseif iprototype.is_pipe(prototype_name) then
            create_builder = create_pipebuilder
        else
            assert(false)
        end

        __switch_status("construct", function()
            assert(selected_obj)
            if selected_obj.get_pos then
                icamera_controller.focus_on_position(selected_obj:get_pos())
            end

            gameplay_core.world_update = false
            local typeobject = iprototype.queryByName(prototype_name)
            assert(typeobject.base)
            typeobject = iprototype.queryByName(typeobject.base)
            builder_ui = "/pkg/vaststars.resources/ui/construct_road_or_pipe.rml"
            builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct_road_or_pipe.rml")
            datamodel.is_concise_mode = true
            builder_datamodel.is_concise_mode = true
            builder_datamodel.show_remove_one = false
            builder = create_builder()
            builder:new_entity(builder_datamodel, typeobject, selected_obj.x, selected_obj.y)
            builder:start_teardown(builder_datamodel)
        end)
        ::continue::
    end

    for _ in finish_laying_mb:unpack() do
        assert(builder)
        builder:finish_laying(builder_datamodel)
    end

    for _ in finish_teardown_mb:unpack() do
        assert(builder)
        builder:finish_teardown(builder_datamodel)

        __switch_status("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end

    for _ in lock_axis_mb:unpack() do
        LockAxis = true
    end

    for _ in unlock_axis_mb:unpack() do
        LockAxis = false
        LockAxisStatus = {
            status = false,
            BeginX = 0,
            BeginY = 0,
        }
        icamera_controller.unlock_axis()
        log.info("unlock axis")
    end

    for _, _, _, prototype_name in remove_one_mb:unpack() do
        assert(iprototype.is_road(prototype_name) or iprototype.is_pipe(prototype_name))

        assert(selected_obj)
        if selected_obj.get_pos then
            icamera_controller.focus_on_position(selected_obj:get_pos())
        end

        local typeobject = iprototype.queryByName(prototype_name)
        assert(typeobject.base)
        typeobject = iprototype.queryByName(typeobject.base)
        builder_ui = "/pkg/vaststars.resources/ui/construct_road_or_pipe.rml"
        builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct_road_or_pipe.rml")
        builder = create_roadbuilder()
        builder:remove_one(builder_datamodel, selected_obj.x, selected_obj.y)

        __switch_status("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end

    for _ in backpack_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/backpack.rml"})
    end

    for _ in settings_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/main_menu.rml"})
    end

    iobject.flush()
end
return M