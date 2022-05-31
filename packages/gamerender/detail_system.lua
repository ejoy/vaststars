local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local mu = import_package "ant.math".util
local vsobject_manager = ecs.require "vsobject_manager"
local math3d = require "math3d"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"

local idetail = ecs.interface "idetail"

local function get_vmin(w, h, ratio)
    local w = w / ratio
    local h = h / ratio
    return math.min(w, h)
end

function idetail.show(vsobject_id)
    iui.open("detail_panel.rml", vsobject_id)

    -- 显示环型菜单
    local vsobject = assert(vsobject_manager:get(vsobject_id))
    local object = objects:get(vsobject_id)
    local typeobject = iprototype:queryByName("entity", object.prototype_name)
    if typeobject.show_build_function ~= false then
        local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
        local ce = world:entity(mq.camera_ref)
        local vp = ce.camera.viewprojmat
        local vr = mq.render_target.view_rect
        local p = math3d.tovalue(mu.world_to_screen(vp, vr, vsobject:get_position()))

        local vmin = get_vmin(vr.w, vr.h, vr.ratio)
        iui.open("build_function_pop.rml", vsobject_id, p[1] / vmin * 100, p[2] / vmin * 100)
    end

    do
        log.info(object.prototype_name, object.x, object.y)
    end
    return true
end
