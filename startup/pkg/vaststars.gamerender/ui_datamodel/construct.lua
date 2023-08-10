local ecs, mailbox = ...
local world = ecs.world

local math3d = require "math3d"
local PLANES <const> = {math3d.constant("v4", {0, 1, 0, 0})}
local icamera_controller = ecs.interface "icamera_controller"
local gameplay_core = require "gameplay.core"
local iui = ecs.import.interface "vaststars.gamerender|iui"
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
local terrain = ecs.require "terrain"
local idetail = ecs.import.interface "vaststars.gamerender|idetail"
local EDITOR_CACHE_NAMES = {"CONFIRM", "CONSTRUCTED"}
local create_station_builder = ecs.require "editor.stationbuilder"
local coord_system = ecs.require "terrain"
local selected_boxes = ecs.require "selected_boxes"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local COLOR_INVALID <const> = math3d.constant "null"
local COLOR_GREEN = math3d.constant("v4", {0.3, 1, 0, 1})
local ichest = require "gameplay.interface.chest"
local ipower_line = ecs.require "power_line"
local ipick_object = ecs.import.interface "vaststars.gamerender|ipick_object"
local ilorry = ecs.import.interface "vaststars.gamerender|ilorry"
local ibackpack = require "gameplay.interface.backpack"
local gesture_longpress_mb = world:sub{"gesture", "longpress"}
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR
local ROAD_TILE_SCALE_WIDTH <const> = 2
local ROAD_TILE_SCALE_HEIGHT <const> = 2
local CHANGED_FLAG_BUILDING <const> = require("gameplay.interface.constant").CHANGED_FLAG_BUILDING

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
local inventory_mb = mailbox:sub {"inventory"}
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

local CLASS = {
    Lorry = 1,
    Object = 2,
    Mineral = 3,
    Mountain = 4,
    Road = 5,
}

local builder, builder_datamodel, builder_ui
local excluded_pickup_id -- object id
local pick_lorry_id
local selected_obj
local audio = import_package "ant.audio"
local function __on_pick_building(datamodel, o)
    local object = o.object
    if excluded_pickup_id and excluded_pickup_id == object.id then
        return
    end

    iui.open({"ui/detail_panel.rml"}, object.id)
    if datamodel.is_concise_mode then
        return true
    end

    iui.close("ui/build.rml") -- TODO: remove this
    iui.close("ui/construct_road_or_pipe.rml")

    audio.play "event:/ui/click"

    local typeobject = iprototype.queryByName(object.prototype_name)

    datamodel.focus_building_icon = typeobject.item_icon

    selected_obj = o
    datamodel.status = "focus"

    idetail.focus(object.id)
    return true
end

local function __on_pick_non_building(datamodel, o, force)
    local typeobject = iprototype.queryByName(o.name)

    iui.open({"ui/non_building_detail_panel.rml"}, typeobject.item_icon, o.name)
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

local function __on_pick_ground(datamodel)
    iui.open({"ui/main_menu.rml"})
    gameplay_core.world_update = false
    return true
end

local function __unpick_lorry(lorry_id)
    local lorry = ilorry.get(lorry_id)
    if lorry then
        lorry:set_outline(false)
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

    if status == "default" then
        icamera_controller.toggle_view("default", cb)
    elseif status == "construct" then
        icamera_controller.toggle_view("construct", cb)
    end
end

local function __clean(datamodel)
    if builder then
        builder:clean(builder_datamodel)
        builder, builder_datamodel = nil, nil
        iui.close(builder_ui)
    end
    idetail.unselected()
    datamodel.is_concise_mode = false
    datamodel.focus_building_icon = ""
    iui.close("ui/build.rml") -- TODO: remove this
    iui.close("ui/construct_road_or_pipe.rml")
    datamodel.status = "normal"
end

local function __get_new_tech_count(tech_list)
    local count = 0
    for _, tech in ipairs(tech_list) do
        if global.science.tech_picked_flag[tech.detail.name] then
            count = count + 1
        end
    end
    return count
end

---------------
local M = {}

function M:create()
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
    }
end

local current_techname = ""
function M:update_tech(datamodel, tech)
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
        datamodel.tech_count = __get_new_tech_count(global.science.tech_list)
    end
end

function M:update_inventory_bar(datamodel, t)
    datamodel.inventory_bar = t
end

function M:stage_ui_update(datamodel)
    for _ in rotate_mb:unpack() do
        if builder then
            builder:rotate_pickup_object(builder_datamodel)
        end
    end

    for _ in build_mb:unpack() do
        if builder and builder.confirm then
            local x, y = iobject.central_coord(builder.typeobject.name, DEFAULT_DIR, coord_system)
            x, y = x - (x % ROAD_TILE_SCALE_WIDTH), y - (y % ROAD_TILE_SCALE_HEIGHT)

            builder:confirm(builder_datamodel)
            audio.play "event:/function/place"

            if builder.continue_construct ~= false then
                builder:clean(builder_datamodel)
                builder:new_entity(builder_datamodel, builder.typeobject, x, y)
            end
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
        iui.open({"ui/science.rml"})
    end

    for _ in help_mb:unpack() do
        if not iui.is_open("ui/help_panel.rml") then
            iui.open({"ui/help_panel.rml"})
        else
            iui.close("ui/help_panel.rml")
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
            local center = coord_system:get_position_by_coord(nd.x, nd.y, 1, 1)
            if nd.show_arrow then
                prefab = assert(igame_object.create({
                    state = "opaque",
                    color = COLOR_INVALID,
                    prefab = "prefabs/arrow-guide.prefab",
                    group_id = 0,
                    srt = {
                        t = center,
                    },
                    animation_name = "ArmatureAction",
                    final_frame = false,
                    render_layer = RENDER_LAYER.SELECTED_BOXES,
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
            icamera_controller.focus_on_position(coord_system:get_position_by_coord(nd.camera_x, nd.camera_y, width, height))
        end
    end
end

local function close_focus_tips(tech_node)
    local selected_tips = tech_node.selected_tips
    if not selected_tips then
        return
    end
    for _, tip in ipairs(selected_tips) do
        for _, o in ipairs(tip) do
            o:remove()
        end
    end
    tech_node.selected_tips = {}
    excluded_pickup_id = nil
end

local function __construct_entity(typeobject)
    idetail.unselected()
    gameplay_core.world_update = false

    if iprototype.has_type(typeobject.type, "road") then
        local x, y = iobject.central_coord(typeobject.name, DEFAULT_DIR, coord_system)
        x, y = x - (x % ROAD_TILE_SCALE_WIDTH), y - (y % ROAD_TILE_SCALE_HEIGHT)

        builder_ui = "ui/construct_road_or_pipe.rml" -- TODO: remove this
        builder_datamodel = iui.get_datamodel("ui/construct.rml")
        builder = create_roadbuilder()
        builder:new_entity(builder_datamodel, typeobject, x, y)
    elseif iprototype.has_type(typeobject.type, "pipe") then
        local x, y = iobject.central_coord(typeobject.name, DEFAULT_DIR, coord_system)
        x, y = x - (x % ROAD_TILE_SCALE_WIDTH), y - (y % ROAD_TILE_SCALE_HEIGHT)

        builder_ui = "ui/construct_road_or_pipe.rml" -- TODO: remove this
        builder_datamodel = iui.get_datamodel("ui/construct.rml")
        builder = create_pipebuilder()
        builder:new_entity(builder_datamodel, typeobject, x, y)
    elseif iprototype.has_type(typeobject.type, "pipe_to_ground") then
        local x, y = iobject.central_coord(typeobject.name, DEFAULT_DIR, coord_system)
        x, y = x - (x % ROAD_TILE_SCALE_WIDTH), y - (y % ROAD_TILE_SCALE_HEIGHT)

        builder_ui = "ui/construct_road_or_pipe.rml"  -- TODO: remove this
        builder_datamodel = iui.get_datamodel("ui/construct.rml")
        builder = create_pipetogroundbuilder()
        builder:new_entity(builder_datamodel, typeobject, x, y)
    elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
        builder_ui = "ui/construct_building.rml"
        builder_datamodel = iui.get_datamodel("ui/construct.rml")
        builder = create_station_builder()
        builder:new_entity(builder_datamodel, typeobject)
    else
        builder_ui = "ui/construct_building.rml"
        builder_datamodel = iui.get_datamodel("ui/construct.rml")
        builder = create_normalbuilder(typeobject.id)
        builder:new_entity(builder_datamodel, typeobject)
    end
end

function M:stage_camera_usage(datamodel)
    local dragdrop_delta
    for _, delta in dragdrop_camera_mb:unpack() do
        dragdrop_delta = delta
    end
    if dragdrop_delta and builder then
        builder:touch_move(builder_datamodel, dragdrop_delta)
        self:flush()
    end

    for _, _, e in gesture_pan_mb:unpack() do
        if e.state == "began" then
            iui.leave()
        end
        if e.state == "ended" and builder then
            builder:touch_end(builder_datamodel)
            self:flush()
        end
    end

    local leave = true
    local gesture_tap_changed = false
    for _, _, v in gesture_tap_mb:unpack() do
        iui.leave()
        gesture_tap_changed = true

        local x, y = v.x, v.y

        for _, pos in ipairs(icamera_controller.screen_to_world(x, y, PLANES)) do
            local coord = terrain:get_coord_by_position(pos)
            if coord then
                local o = ipick_object.blur_pick(coord[1], coord[2])
                if o and o.class == CLASS.Lorry then
                    if pick_lorry_id then
                        __unpick_lorry(pick_lorry_id)
                    end
                    idetail.unselected()
                    pick_lorry_id = o.id

                    if __on_pick_non_building(datamodel, o) then
                        o.lorry:set_outline(true)
                        leave = false
                    end
                elseif o and o.class == CLASS.Object then
                    idetail.unselected()
                    iui.close("ui/construct_road_or_pipe.rml") -- TODO: remove this
                    if __on_pick_building(datamodel, o) then
                        __unpick_lorry(pick_lorry_id)
                        pick_lorry_id = nil
                        leave = false
                    end
                elseif o and (o.class == CLASS.Mineral or o.class == CLASS.Mountain or o.class == CLASS.Road)then
                    idetail.unselected()
                    iui.close("ui/construct_road_or_pipe.rml") -- TODO: remove this
                    if __on_pick_non_building(datamodel, o) then
                        __unpick_lorry(pick_lorry_id)
                        pick_lorry_id = nil
                        leave = false
                    end
                else
                    __unpick_lorry(pick_lorry_id)
                    pick_lorry_id = nil

                    idetail.unselected()
                end
                break
            end
        end
    end

    local function __get_building(x, y)
        for _, pos in ipairs(icamera_controller.screen_to_world(x, y, PLANES)) do
            local coord = terrain:get_coord_by_position(pos)
            if coord then
                local r = objects:coord(coord[1], coord[2], EDITOR_CACHE_NAMES)
                if r then
                    return r
                end
            end
        end
    end

    for _, _, v in gesture_longpress_mb:unpack() do
        local x, y = v.x, v.y
        leave = false
        local object = __get_building(x, y)
        if not object then
            idetail.unselected()
            __on_pick_ground(datamodel)
        end
    end

    for _, _, _, object_id in teardown_mb:unpack() do
        iui.leave()
        idetail.unselected()
        datamodel.status = "normal"
        datamodel.focus_building_icon = ""
        selected_obj = nil

        local object = assert(objects:get(object_id))
        local gw = gameplay_core.get_world()
        local typeobject = iprototype.queryByName(object.prototype_name)

        local e = gameplay_core.get_entity(object.gameplay_eid)
        local chest_component = ichest.get_chest_component(e)
        if chest_component then
            if not ibackpack.can_move_to_backpack(gameplay_core.get_world(), e[chest_component]) then
                log.error("can not teardown")
                goto continue
            end

            for i = 1, ichest.MAX_SLOT do
                local slot = gameplay_core.get_world():container_get(e[chest_component], i)
                if not slot then
                    break
                end
                ibackpack.move_to_backpack(gameplay_core.get_world(), e[chest_component], i)
            end
        end

        igameplay.destroy_entity(object.gameplay_eid)
        gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

        if typeobject.power_network_link or typeobject.power_supply_distance then
            ipower:build_power_network(gw)
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
            builder_ui = "ui/move_building.rml"
            builder_datamodel = iui.open({"ui/move_building.rml"}, object.prototype_name)
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

    -- TODO: 多个UI的stage_ui_update中会产生focus_tips_event事件，focus_tips_event处理逻辑涉及到要修改相机位置，所以暂时放在这里处理
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
            iui.open({"ui/build.rml"})
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

                if selected_obj.class == CLASS.Object and not iprototype.is_pipe(selected_obj.object.prototype_name) then -- TODO: optimize
                    local object = selected_obj.object
                    icamera_controller.focus_on_position(object.srt.t)

                    idetail.show(object.id)
                    idetail.selected(object)
                else
                    if selected_obj.get_pos then
                        icamera_controller.focus_on_position(selected_obj:get_pos())
                    end

                    if iprototype.is_road(selected_obj.name) or iprototype.is_pipe(selected_obj.name) or iprototype.is_pipe_to_ground(selected_obj.name) then
                        datamodel.focus_building_icon = ""
                        iui.open({"ui/construct_road_or_pipe.rml"}, selected_obj.name, {show_start_laying = true})
                    end

                    if not iprototype.is_pipe(selected_obj.name) then
                        local typeobject = iprototype.queryByName(selected_obj.name)
                        iui.open({"ui/non_building_detail_panel.rml"}, typeobject.item_icon, iprototype.display_name(typeobject))
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

            idetail.selected(object)

            local prototype_name = object.prototype_name
            local typeobject = iprototype.queryByName(prototype_name)
            if typeobject.move == false and typeobject.teardown == false then
                goto continue
            end

            iui.open({"ui/building_menu_longpress.rml"}, object.id)
        elseif selected_obj.class == CLASS.Road then
            iui.open({"ui/construct_road_or_pipe.rml"}, selected_obj.name, {show_remove_one = true, show_start_teardown = true})
        end

        ::continue::
    end

    for _, _, _, prototype_name in start_laying_mb:unpack() do
        local create_builder
        if iprototype.is_road(prototype_name) then
            create_builder = create_roadbuilder
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
            assert(typeobject.construct_name)
            typeobject = iprototype.queryByName(typeobject.construct_name)
            builder_ui = "ui/construct_road_or_pipe.rml"
            builder_datamodel = iui.get_datamodel("ui/construct_road_or_pipe.rml")
            datamodel.is_concise_mode = true
            builder_datamodel.is_concise_mode = true
            builder = create_builder()
            builder:new_entity(builder_datamodel, typeobject, selected_obj.x, selected_obj.y)
            builder:start_laying(builder_datamodel)
        end)
    end

    for _, _, _, prototype_name in start_teardown_mb:unpack() do
        local create_builder
        if iprototype.is_road(prototype_name) then
            create_builder = create_roadbuilder
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
            assert(typeobject.construct_name)
            typeobject = iprototype.queryByName(typeobject.construct_name)
            builder_ui = "ui/construct_road_or_pipe.rml"
            builder_datamodel = iui.get_datamodel("ui/construct_road_or_pipe.rml")
            datamodel.is_concise_mode = true
            builder_datamodel.is_concise_mode = true
            builder_datamodel.show_remove_one = false
            builder = create_builder()
            builder:new_entity(builder_datamodel, typeobject, selected_obj.x, selected_obj.y)
            builder:start_teardown(builder_datamodel)
        end)
    end

    for _ in finish_laying_mb:unpack() do
        assert(builder)
        local to_x, to_y = builder:finish_laying(builder_datamodel)
        local obj
        if iprototype.is_road(builder.typeobject.name) then
            obj = ipick_object.pick_road(to_x, to_y)
            __on_pick_non_building(datamodel, obj, true)
        else
            obj = ipick_object.pick_obj(to_x, to_y)
            __on_pick_building(datamodel, obj)
        end
        builder:clean(builder_datamodel)
        print("finish_laying_mb", to_x, to_y)
        builder:new_entity(builder_datamodel, builder.typeobject, to_x, to_y)
        builder:start_laying(builder_datamodel)
    end

    for _ in finish_teardown_mb:unpack() do
        assert(builder)
        builder:finish_teardown(builder_datamodel)

        __switch_status("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end

    for _, _, _, prototype_name in remove_one_mb:unpack() do
        assert(iprototype.is_road(prototype_name) or iprototype.is_pipe(prototype_name))

        assert(selected_obj)
        if selected_obj.get_pos then
            icamera_controller.focus_on_position(selected_obj:get_pos())
        end

        local typeobject = iprototype.queryByName(prototype_name)
        assert(typeobject.construct_name)
        typeobject = iprototype.queryByName(typeobject.construct_name)
        builder_ui = "ui/construct_road_or_pipe.rml"
        builder_datamodel = iui.get_datamodel("ui/construct_road_or_pipe.rml")
        builder = create_roadbuilder()
        builder:new_entity(builder_datamodel, typeobject, selected_obj.x, selected_obj.y)
        builder:remove_one(builder_datamodel)

        __switch_status("default", function()
            gameplay_core.world_update = true
            __clean(datamodel)
        end)
    end

    for _ in inventory_mb:unpack() do
        iui.open({"ui/inventory.rml"})
    end

    iobject.flush()
end
return M