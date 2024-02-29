local ecs, mailbox = ...
local world = ecs.world

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"
local set_button_offset = ecs.require "ui_datamodel.common.sector_menu".set_button_offset

local math3d = require "math3d"
local XZ_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})

local icoord = require "coord"
local COORD_BOUNDARY <const> = icoord.boundary()

local BUTTONS = {
    { command = "reset",    icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/reset.texture", },
    { command = "operate",  icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/operate.texture", },
    { command = "unselect", icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/unselect.texture", },
    { command = "mark",     icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/mark.texture", },
}

local update_selecting_building_mb = mailbox:sub {"update_selecting_building"}
local close_mb = mailbox:sub {"close"}
local icamera_controller = ecs.require "engine.system.camera_controller"
local icoord = require "coord"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local ibuilding = ecs.require "render_updates.building"
local iprototype = require "gameplay.interface.prototype"
local iroadnet_converter = require "roadnet_converter"
local iroadnet = ecs.require "engine.roadnet"
local gameplay_core = require "gameplay.core"
local iui = ecs.require "engine.system.ui_system"

local selected = {}
local selecting = {}

local M = {}
function M.create()
    local buttons = {}
    for _, v in ipairs(BUTTONS) do
        buttons[#buttons+1] = {
            command = v.command,
            background_image = v.icon,
        }
    end
    set_button_offset(buttons)

    return {
        buttons = buttons,
    }
end

local function _update_object_state(gameplay_eid, state, color, emissive_color, render_layer)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local object = objects:coord(e.building.x, e.building.y)
    if object then
        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {state = state, color = color, emissive_color = emissive_color, render_layer = render_layer}
    end
end

local function _update_road_state(gameplay_eid, color)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local v = ibuilding.get(e.building.x, e.building.y)
    if v then
        local typeobject = iprototype.queryByName(v.prototype)
        local shape = iroadnet_converter.to_shape(typeobject.name)
        iroadnet:set("road", v.x, v.y, color, shape, v.direction)
    end
end

local function _to_road_color(color)
    if color == "null" then
        return 0xffffffff
    end
    local r, g, b, a = math3d.index(color, 1, 2, 3, 4)
    r, g, b, a = math.floor(r*255), math.floor(g*255), math.floor(b*255), math.floor(a*255)
    return r | g<<8 | b<<16 | a<<24
end

local function _update_selected_objs(gameplay_eids, state, color, render_layer)
    for gameplay_eid in pairs(gameplay_eids) do
        _update_object_state(gameplay_eid, state, color, color, render_layer)
        _update_road_state(gameplay_eid, _to_road_color(color))
    end
end

local function _clear()
    _update_selected_objs(selected, "opaque", "null", RENDER_LAYER.BUILDING)
    _update_selected_objs(selecting, "opaque", "null", RENDER_LAYER.BUILDING)
    iroadnet:flush()

    selecting = {}
    iui.redirect("/pkg/vaststars.resources/ui/construct.html", "bulk_opt_exit")
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

        local old = selecting
        local add, del = {}, {}

        for gameplay_eid in pairs(old) do
            if t[gameplay_eid] == nil then
                del[gameplay_eid] = true
                selecting[gameplay_eid] = nil
            end
        end

        for gameplay_eid in pairs(t) do
            if old[gameplay_eid] == nil then
                add[gameplay_eid] = true
                selecting[gameplay_eid] = true
            end
        end

        _update_selected_objs(add, "translucent", SPRITE_COLOR.SELECTED, RENDER_LAYER.TRANSLUCENT_BUILDING)
        _update_selected_objs(del, "opaque", "null", RENDER_LAYER.BUILDING)

        iroadnet:flush()
    end

    for _ in close_mb:unpack() do
        _clear()
    end
end

function M.gesture_tap()
    iui.send("/pkg/vaststars.resources/ui/bulk_opt.html", "tap")
end

function M.gesture_pinch()
    iui.send("/pkg/vaststars.resources/ui/bulk_opt.html", "update_selecting_building")
end

function M.gesture_pan_changed()
    iui.send("/pkg/vaststars.resources/ui/bulk_opt.html", "update_selecting_building")
end

function M.gesture_pan_ended(datamodel)
end

return M