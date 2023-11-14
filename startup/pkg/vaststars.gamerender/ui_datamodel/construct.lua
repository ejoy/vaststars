local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"

local ipick_object = ecs.require "pick_object_system"
local CLASS <const> = ipick_object.CLASS

local math3d = require "math3d"
local XZ_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})

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
local icoord = require "coord"
local ichest = require "gameplay.interface.chest"
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
local move_md = mailbox:sub {"move"}
local teardown_mb = mailbox:sub {"teardown"}
local construct_entity_mb = mailbox:sub {"construct_entity"}
local copy_mb = mailbox:sub {"copy"}
local build_mode_mb = mailbox:sub {"build_mode"}
local main_button_tap_mb = mailbox:sub {"main_button_tap"}
local main_button_longpress_mb = mailbox:sub {"main_button_longpress"}
local unselected_mb = mailbox:sub {"unselected"}
local gesture_tap_mb = world:sub{"gesture", "tap"}
local gesture_pan_mb = world:sub {"gesture", "pan"}
local lock_axis_mb = mailbox:sub {"lock_axis"}
local unlock_axis_mb = mailbox:sub {"unlock_axis"}
local settings_mb = mailbox:sub {"settings"}
local iguide_tips = ecs.require "guide_tips"
local create_selected_boxes = ecs.require "selected_boxes"

local builder, builder_datamodel, builder_ui
local selected_obj

local LockAxis = false
local LockAxisStatus = {
    status = false,
    BeginX = 0,
    BeginY = 0,
}

local function toggle_view(s, cb)
    local pos = icamera_controller.get_screen_world_position("CENTER")
    pos = math3d.set_index(pos, 2, 0)

    if s == "default" then
        icamera_controller.toggle_view("default", pos, cb)
        igame_object.restart_world()
    elseif s == "construct" then
        icamera_controller.toggle_view("construct", pos, cb)
        igame_object.stop_world()
    else
        assert(false)
    end
end

local function __clean(datamodel, unlock)
    if builder then
        builder:clean(builder_datamodel)
        builder, builder_datamodel = nil, nil
        iui.close(builder_ui)
    end
    idetail.unselected()
    datamodel.focus_building_icon = ""
    datamodel.status = "NORMAL"

    iui.close("/pkg/vaststars.resources/ui/build.rml")
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
        status = "NORMAL",
        show_tech_progress = false,
        current_tech_icon = "none",    --当前科技图标
        current_tech_name = "none",    --当前科技名字
        current_tech_progress = "0%",  --当前科技进度
        current_tech_progress_detail = "0/0",  --当前科技进度(数量),
        ingredient_icons = {},
        show_ingredient = false,
        category_idx = 0,
        item_idx = 0,
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

local function _construct_entity(typeobject, position_type)
    idetail.unselected()
    gameplay_core.world_update = false
    builder_ui = "/pkg/vaststars.resources/ui/construct_building.rml"
    builder_datamodel = iui.get_datamodel("/pkg/vaststars.resources/ui/construct.rml")

    --TODO: prototype should be a parameter
    if iprototype.has_type(typeobject.type, "road") then
        builder = create_roadbuilder()
    elseif iprototype.has_type(typeobject.type, "pipe") then
        builder = create_pipebuilder()
    elseif iprototype.has_type(typeobject.type, "pipe_to_ground") then
        builder = create_pipetogroundbuilder()
    elseif iprototype.has_types(typeobject.type, "station", "park") then
        builder = create_station_builder()
    else
        builder = create_normalbuilder(typeobject.id)
    end

    builder:new_entity(builder_datamodel, typeobject, position_type)
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

local function show_selectbox(x, y, w, h)
    local pos = icoord.position(x, y, w, h)
    local o = create_selected_boxes(
        {
            "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
            "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
        },
        pos, SPRITE_COLOR.SELECTED_OUTLINE, w, h
    )
    idetail.add_tmp_object(o)
end

local function pickupObjectOnBuild(datamodel, position, blur)
    local coord = icoord.position2coord(position)
    if not coord then
        return
    end
    idetail.unselected()

    local o = ipick_object.pick(coord[1], coord[2], blur)
    if o and o.class == CLASS.Lorry then
        local typeobject = iprototype.queryByName(o.name)
        iui.open({rml = "/pkg/vaststars.resources/ui/non_building_detail_panel.rml"}, typeobject.icon, typeobject.mineral_name and typeobject.mineral_name or iprototype.display_name(typeobject), o.eid)

        local lorry = assert(ilorry.get(o.id))
        lorry:show_arrow(true)
        idetail.add_tmp_object({remove = function()
            local lorry = ilorry.get(o.id)
            if lorry then
                lorry:show_arrow(false)
            end
        end})
        return

    elseif o and o.class == CLASS.Object then
        local object = o.object
        local excluded_pickup_id = iguide_tips.get_excluded_pickup_id()
        if excluded_pickup_id and excluded_pickup_id ~= object.id then
            return
        end

        iui.open({rml = "/pkg/vaststars.resources/ui/detail_panel.rml"}, object.id)

        local e = assert(gameplay_core.get_entity(object.gameplay_eid))
        local typeobject = iprototype.queryById(e.building.prototype)
        local w, h = iprototype.rotate_area(typeobject.area, e.building.direction)
        show_selectbox(e.building.x, e.building.y, w, h)
        return

    elseif o and (o.class == CLASS.Mountain or o.class == CLASS.Road) then
        local typeobject = iprototype.queryByName(o.name)
        iui.open({rml = "/pkg/vaststars.resources/ui/non_building_detail_panel.rml"}, typeobject.icon, iprototype.display_name(typeobject), o.eid)

        if o.x and o.y and o.w and o.h then
            show_selectbox(o.x, o.y, o.w, o.h)
        end
        return

    elseif o and o.class == CLASS.Mineral then
        local typeobject = iprototype.queryByName(o.name)
        iui.open({rml = "/pkg/vaststars.resources/ui/non_building_detail_panel.rml"}, typeobject.icon, typeobject.mineral_name and typeobject.mineral_name or iprototype.display_name(typeobject), o.eid)

        show_selectbox(o.x, o.y, o.w, o.h)
        return
    else
        __clean(datamodel)
        toggle_view("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end
end

local function pickupObject(datamodel, position, blur)
    local coord = icoord.position2coord(position)
    if not coord then
        return
    end
    idetail.unselected()

    local o = ipick_object.pick(coord[1], coord[2], blur)
    assert(o)
    if o and o.class == CLASS.Lorry then
        local typeobject = iprototype.queryByName(o.name)
        iui.open({rml = "/pkg/vaststars.resources/ui/non_building_detail_panel.rml"}, typeobject.icon, typeobject.mineral_name and typeobject.mineral_name or iprototype.display_name(typeobject), o.eid)

        local lorry = assert(ilorry.get(o.id))
        lorry:show_arrow(true)
        idetail.add_tmp_object({remove = function()
            local lorry = ilorry.get(o.id)
            if lorry then
                lorry:show_arrow(false)
            end
        end})

        --
        selected_obj = o
        datamodel.focus_building_icon = typeobject.item_icon
        datamodel.status = "FOCUS"

        iui.open({rml = "/pkg/vaststars.resources/ui/building_menu.rml"}, o.id)

        audio.play "event:/ui/click"
        return

    elseif o and o.class == CLASS.Object then
        local object = o.object
        local excluded_pickup_id = iguide_tips.get_excluded_pickup_id()
        if excluded_pickup_id and excluded_pickup_id ~= object.id then
            return
        end

        iui.open({rml = "/pkg/vaststars.resources/ui/detail_panel.rml"}, object.id)

        local e = assert(gameplay_core.get_entity(object.gameplay_eid))
        local typeobject = iprototype.queryById(e.building.prototype)
        local w, h = iprototype.rotate_area(typeobject.area, e.building.direction)
        show_selectbox(e.building.x, e.building.y, w, h)

        --
        selected_obj = o
        datamodel.focus_building_icon = typeobject.item_icon
        datamodel.status = "FOCUS"

        local gameplay_eid = object.gameplay_eid
        local typeobject = iprototype.queryByName(object.prototype_name)
        if typeobject.building_menu ~= false then
            iui.open({rml = "/pkg/vaststars.resources/ui/building_menu.rml"}, gameplay_eid)
        end

        audio.play "event:/ui/click"
        return

    elseif o and (o.class == CLASS.Mountain or o.class == CLASS.Road) then
        local typeobject = iprototype.queryByName(o.name)
        iui.open({rml = "/pkg/vaststars.resources/ui/non_building_detail_panel.rml"}, typeobject.icon, iprototype.display_name(typeobject), o.eid)

        show_selectbox(o.x, o.y, o.w, o.h)

        --
        selected_obj = o
        datamodel.focus_building_icon = typeobject.item_icon
        datamodel.status = "FOCUS"

        if o.class == CLASS.Road then
            iui.open({rml = "/pkg/vaststars.resources/ui/building_menu.rml"}, o.id)
        end

        audio.play "event:/ui/click"
        return

    elseif o and o.class == CLASS.Mineral then
        local typeobject = iprototype.queryByName(o.name)
        iui.open({rml = "/pkg/vaststars.resources/ui/non_building_detail_panel.rml"}, typeobject.icon, typeobject.mineral_name and typeobject.mineral_name or iprototype.display_name(typeobject), o.eid)

        show_selectbox(o.x, o.y, o.w, o.h)

        selected_obj = o

        --
        datamodel.show_construct_button = true
        idetail.add_tmp_object({remove = function()
            datamodel.show_construct_button = false
        end})
        audio.play "event:/ui/click"
        return

    elseif o and o.class == CLASS.Empty then
        show_selectbox(o.x, o.y, o.w, o.h)

        selected_obj = o
        datamodel.focus_building_icon = ""

        --
        datamodel.show_construct_button = true
        idetail.add_tmp_object({remove = function()
            datamodel.show_construct_button = false
        end})
        audio.play "event:/ui/click"
        return
    end
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
        toggle_view("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end

    for _ in guide_on_going_mb:unpack() do
        __clean(datamodel)
        toggle_view("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end

    for _ in click_techortaskicon_mb:unpack() do
        gameplay_core.world_update = false
        iui.open({rml = "/pkg/vaststars.resources/ui/science.rml"})
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
            idetail.unselected()
            selected_obj = nil
            iui.leave()

            -- in copy mode
            if datamodel.status ~= "BUILD" then
                datamodel.focus_building_icon = ""
            end
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

    for _, _, v in gesture_tap_mb:unpack() do
        iui.leave()
        local pos = icamera_controller.screen_to_world(v.x, v.y, XZ_PLANE)

        -- don't respond to tap in build mode
        if datamodel.status == "BUILD" then
            pickupObjectOnBuild(datamodel, pos, false)
        else
            pickupObject(datamodel, pos, true)
        end
    end

    local longpress_startpoint = {}
    for _, _, e in gesture_longpress_mb:unpack() do
        -- don't respond to long press in build mode
        if datamodel.status == "BUILD" then
            goto continue
        end
        if e.state == "began" then
            local pos = icamera_controller.screen_to_world(e.x, e.y, XZ_PLANE)
            pickupObject(datamodel, pos)
            icamera_controller.lock_axis("xz-axis")
            icamera_controller.toggle_view("pickup", math3d.set_index(pos, 2, 0))

        elseif e.state == "changed" then
            longpress_startpoint.x = e.x
            longpress_startpoint.y = e.y

        elseif e.state == "ended" then
            longpress_startpoint = nil

            local pos = icamera_controller.get_screen_world_position("CENTER")
            pos = math3d.set_index(pos, 2, 0)
            icamera_controller.toggle_view("default", math3d.set_index(pos, 2, 0), function()
                icamera_controller.unlock_axis()
            end)
        end
        ::continue::
    end

    if longpress_startpoint and longpress_startpoint.x and longpress_startpoint.y then
        log.info("longpress_startpoint", longpress_startpoint.x, longpress_startpoint.y)
        __clean(datamodel, false)
        local pos = icamera_controller.screen_to_world(longpress_startpoint.x, longpress_startpoint.y, XZ_PLANE)
        pickupObject(datamodel, pos)
    end

    for _, _, _, gameplay_eid in teardown_mb:unpack() do
        iui.leave()
        idetail.unselected()
        datamodel.focus_building_icon = ""
        datamodel.status = "NORMAL"

        selected_obj = nil

        local gameplay_world = gameplay_core.get_world()
        local e = gameplay_core.get_entity(gameplay_eid)
        local typeobject = iprototype.queryById(e.building.prototype)
        if e.chest then
            if not ibackpack.can_move_to_backpack(gameplay_world, e, typeobject.id) then
                log.error("backpack is full")
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

        if ibackpack.get_available_capacity(gameplay_world, typeobject.id, 1) <= 0 then
            log.error("backpack is full")
            goto continue
        end
        ibackpack.place(gameplay_world, typeobject.id, 1)

        igameplay.destroy_entity(gameplay_eid)
        gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

        --TODO
        -- ibuilding.remove(x, y)
        -- iroadnet:del("road", x, y)
        -- gameplay_core.set_changed(CHANGED_FLAG_ROADNET)

        -- the road will not execute the following logic
        for _, o in objects:selectall("gameplay_eid", gameplay_eid, {"CONSTRUCTED"}) do
            iobject.remove(o)
            objects:remove(o.id)
            local building = global.buildings[o.id]
            if building then
                for _, v in pairs(building) do
                    v:remove()
                end
            end
        end
        ::continue::
    end

    for _, _, _, object_id in move_md:unpack() do
        datamodel.status = "BUILD"
        toggle_view("construct", function()
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
        assert(datamodel.status == "BUILD")
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
            _construct_entity(typeobject, "RIGHT_CENTER")
        end
    end

    for _, _, _, name in copy_mb:unpack() do
        local typeobject = iprototype.queryByName(name)

        datamodel.status = "BUILD"
        idetail.unselected()
        toggle_view("construct", function()
            iui.leave()
            iui.open({rml = "/pkg/vaststars.resources/ui/build.rml"}, typeobject.id)
            gameplay_core.world_update = false

            assert(builder == nil)
            _construct_entity(typeobject, "RIGHT_CENTER")
        end)
    end

    for _ in build_mode_mb:unpack() do
        datamodel.status = "BUILD"
        assert(selected_obj)
        local pos = math3d.vector(icoord.position(selected_obj.x, selected_obj.y, selected_obj.w, selected_obj.h))
        icamera_controller.focus_on_position("RIGHT_CENTER", pos, function()
            toggle_view("construct", function()
                iui.leave()
                iui.open({rml = "/pkg/vaststars.resources/ui/build.rml"})
                gameplay_core.world_update = false
            end)
        end)
    end

    for _ in main_button_tap_mb:unpack() do
        if datamodel.status == "SELECTED" then
            iui.leave()
            idetail.unselected()
            datamodel.focus_building_icon = ""
            datamodel.status = "NORMAL"

        else
            if selected_obj then
                datamodel.status = "SELECTED"

                if selected_obj.class == CLASS.Lorry then
                    local e = assert(gameplay_core.get_entity(selected_obj.id))
                    icamera_controller.focus_on_position("CENTER", math3d.vector(icoord.position(e.lorry.x, e.lorry.y, 1, 1)))

                elseif selected_obj.class == CLASS.Object then
                    local object = selected_obj.object
                    icamera_controller.focus_on_position("CENTER", object.srt.t)

                    idetail.selected(object.gameplay_eid)
                else
                    if selected_obj.get_pos then
                        icamera_controller.focus_on_position("CENTER", math3d.vector(selected_obj:get_pos()))
                    end
                end
            else
                log.error("no target selected")
            end
        end
    end

    for _ in unselected_mb:unpack() do
        iui.leave()
        idetail.unselected()
        datamodel.focus_building_icon = ""
        datamodel.status = "NORMAL"

        selected_obj = nil
    end

    for _ in main_button_longpress_mb:unpack() do
        assert(selected_obj)
        if selected_obj.class == CLASS.Object then
            iui.leave()
            local object = selected_obj.object
            if iguide_tips.get_excluded_pickup_id() == object.id then
                goto continue
            end

            local prototype_name = object.prototype_name
            local typeobject = iprototype.queryByName(prototype_name)
            if typeobject.teardown == false then
                goto continue
            end
            iui.open({rml = "/pkg/vaststars.resources/ui/building_menu_longpress.rml"}, selected_obj.object.gameplay_eid)
        elseif selected_obj.class == CLASS.Lorry or selected_obj.class == CLASS.Road then
            iui.leave()
            iui.open({rml = "/pkg/vaststars.resources/ui/building_menu_longpress.rml"}, selected_obj.id)
        end
        ::continue::
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

    for _ in settings_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/main_menu.rml"})
    end

    iobject.flush()
end
return M