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

function idetail.show(object_id)
    iui.open("detail_panel.rml", object_id)

    -- 显示环型菜单
    local vsobject = assert(vsobject_manager:get(object_id))
    local object = objects:get(object_id)
    local typeobject = iprototype.queryByName("entity", object.prototype_name)

    local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
    local ce = world:entity(mq.camera_ref)
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    local p = math3d.tovalue(mu.world_to_screen(vp, vr, vsobject:get_position()))
    local vmin = get_vmin(vr.w, vr.h, vr.ratio)

    if typeobject.show_build_function ~= false then
        iui.open("build_function_pop.rml", object_id, p[1] / vmin * 100, p[2] / vmin * 100)
    elseif iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        iui.open("pipe_function_pop.rml", object_id, p[1] / vmin * 100, p[2] / vmin * 100)
    end

    do
        log.info(object.prototype_name, object.x, object.y)
    end
    return true
end
