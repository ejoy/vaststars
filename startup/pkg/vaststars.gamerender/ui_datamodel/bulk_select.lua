local ecs, mailbox = ...
local world = ecs.world

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local COLOR <const> = ecs.require "vaststars.prototype|color"

local math3d = require "math3d"
local XZ_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})

local icoord = require "coord"
local COORD_BOUNDARY <const> = icoord.boundary()

local BUTTONS <const> = {
    { command = "reset",    icon = "/pkg/vaststars.resources/ui/textures/bulk-select/reset.texture", },
    { command = "operate",  icon = "/pkg/vaststars.resources/ui/textures/bulk-select/operate.texture", },
    { command = "unselect", icon = "/pkg/vaststars.resources/ui/textures/bulk-select/unselect.texture", },
    { command = "select",   icon = "/pkg/vaststars.resources/ui/textures/bulk-select/select.texture", },
}

local update_selecting_building_mb = mailbox:sub {"update_selecting_building"}
local select_mb = mailbox:sub {"select"}
local unselect_mb = mailbox:sub {"unselect"}
local reset_mb = mailbox:sub {"reset"}
local operate_mb = mailbox:sub {"operate"}
local icamera_controller = ecs.require "engine.system.camera_controller"
local objects = require "objects"
local ibuilding = ecs.require "render_updates.building"
local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local iui = ecs.require "engine.system.ui_system"
local global = require "global"
local set_button_offset = ecs.require "ui_datamodel.common.sector_menu".set_button_offset
local update_buildings_state = ecs.require "ui_datamodel.common.bulk_opt".update_buildings_state
local renew_selected_range = ecs.require "ui_datamodel.common.bulk_opt".renew_selected_range
local remove_selected_range = ecs.require "ui_datamodel.common.bulk_opt".remove_selected_range
local igame_object = ecs.require "engine.game_object"

local selecting = {}

local function _clear()
    update_buildings_state({
        {global.selected_buildings, "opaque", "null", RENDER_LAYER.BUILDING},
        {selecting, "opaque", "null", RENDER_LAYER.BUILDING},
    })
    selecting = {}
end

local M = {}
function M.create()
    gameplay_core.world_update = false
    igame_object.stop_world()

    local buttons = {}
    for _, v in ipairs(BUTTONS) do
        buttons[#buttons+1] = {
            command = v.command,
            background_image = v.icon,
        }
    end
    set_button_offset(buttons)

    update_buildings_state({{global.selected_buildings, "translucent", COLOR.BULK_SELECTED_BUILDINGS, RENDER_LAYER.TRANSLUCENT_BUILDING}})

    renew_selected_range()

    return {
        buttons = buttons,
    }
end

function M.update(datamodel)
    for _, _, _, left, top, width, height in update_selecting_building_mb:unpack() do
        local lefttop = icamera_controller.screen_to_world(left, top, XZ_PLANE)
        local rightbottom = icamera_controller.screen_to_world(left + width, top + height, XZ_PLANE)

        local ltcoord = icoord.position2coord(lefttop) or {0, 0}
        local rbcoord = icoord.position2coord(rightbottom) or {COORD_BOUNDARY[2][1], COORD_BOUNDARY[2][2]}
        local aabb_select = math3d.aabb(math3d.vector(ltcoord[1], 0, ltcoord[2]), math3d.vector(rbcoord[1], 0, rbcoord[2]))

        local t = {}
        for x = ltcoord[1], rbcoord[1] do
            for y = ltcoord[2], rbcoord[2] do
                local object = objects:coord(x, y)
                if object then
                    local e = assert(gameplay_core.get_entity(object.gameplay_eid))
                    local typeobject = iprototype.queryById(e.building.prototype)
                    local w, h = iprototype.rotate_area(typeobject.area, object.dir)
                    local inside = math3d.aabb_test_point(aabb_select, math3d.vector(e.building.x, 0, e.building.y)) >= 0 and
                            math3d.aabb_test_point(aabb_select, math3d.vector(e.building.x + w, 0, e.building.y + h)) >= 0
                    if inside and not e.debris and typeobject.teardown ~= false and typeobject.bulk_opt ~= false then
                        t[e.eid] = true
                    end
                end
                local road_x, road_y = icoord.road_coord(x, y)
                local v = ibuilding.get(road_x, road_y)
                if v then
                    local typeobject = iprototype.queryByName(v.prototype)
                    local w, h = iprototype.rotate_area(typeobject.area, v.direction)
                    local inside = math3d.aabb_test_point(aabb_select, math3d.vector(road_x, 0, road_y)) >= 0 and
                            math3d.aabb_test_point(aabb_select, math3d.vector(road_x + w, 0, road_y + h)) >= 0
                    if inside then
                        t[v.eid] = true
                    end
                end
            end
        end

        local add, del = {}, {}
        local selected_buildings = global.selected_buildings

        for gameplay_eid in pairs(selecting) do
            if t[gameplay_eid] == nil then
                if selected_buildings[gameplay_eid] == nil then
                    del[gameplay_eid] = true
                end
                selecting[gameplay_eid] = nil
            end
        end

        for gameplay_eid in pairs(t) do
            if selecting[gameplay_eid] == nil then
                if selected_buildings[gameplay_eid] == nil then
                    add[gameplay_eid] = true
                end
                selecting[gameplay_eid] = true
            end
        end

        update_buildings_state({
            {add, "translucent", COLOR.BULK_SELECTEING_BUILDINGS, RENDER_LAYER.TRANSLUCENT_BUILDING},
            {del, "opaque", "null", RENDER_LAYER.BUILDING},
        })
    end

    for _ in select_mb:unpack() do
        local add = {}
        for gameplay_eid in pairs(selecting) do
            if not global.selected_buildings[gameplay_eid] then
                global.selected_buildings[gameplay_eid] = true
                add[gameplay_eid] = true
            end
        end
        update_buildings_state({
            {add, "translucent", COLOR.BULK_SELECTED_BUILDINGS, RENDER_LAYER.TRANSLUCENT_BUILDING},
        })
        renew_selected_range()
    end

    for _ in unselect_mb:unpack() do
        local del = {}
        for gameplay_eid in pairs(selecting) do
            if global.selected_buildings[gameplay_eid] then
                global.selected_buildings[gameplay_eid] = nil
                del[gameplay_eid] = true
            end
        end
        update_buildings_state({
            {del, "translucent", COLOR.BULK_SELECTEING_BUILDINGS, RENDER_LAYER.TRANSLUCENT_BUILDING},
        })
        renew_selected_range()
    end

    for _ in reset_mb:unpack() do
        local t = {}
        for gameplay_eid in pairs(global.selected_buildings) do
            if not selecting[gameplay_eid] then
                t[gameplay_eid] = true
            end
        end
        update_buildings_state({
            {t, "opaque", "null", RENDER_LAYER.BUILDING},
            {selecting, "translucent", COLOR.BULK_SELECTEING_BUILDINGS, RENDER_LAYER.TRANSLUCENT_BUILDING},
        })

        global.selected_buildings = {}
        remove_selected_range()

        iui.send("/pkg/vaststars.resources/ui/bulk_select.html", "update_selecting_building")
    end

    for _ in operate_mb:unpack() do
        update_buildings_state({{selecting, "opaque", "null", RENDER_LAYER.BUILDING}})
        selecting = {}

        --
        iui.close("/pkg/vaststars.resources/ui/bulk_select.html")
        iui.open({rml = "/pkg/vaststars.resources/ui/bulk_opt.html"})
    end
end

function M.gesture_tap()
    remove_selected_range()

    _clear()

    iui.redirect("/pkg/vaststars.resources/ui/construct.html", "bulk_opt_exit")

    gameplay_core.world_update = true
    igame_object.restart_world()
end

function M.gesture_pinch()
    iui.send("/pkg/vaststars.resources/ui/bulk_select.html", "update_selecting_building")
end

function M.gesture_pan_changed()
    iui.send("/pkg/vaststars.resources/ui/bulk_select.html", "update_selecting_building")
end

function M.gesture_pan_ended(datamodel)
end

return M