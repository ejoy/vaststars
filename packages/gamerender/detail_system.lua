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
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local camera = ecs.require "engine.camera"
local EDITOR_CACHE_NAMES <const> = {"SELECTED", "CONSTRUCTED"}
local CLEAR_CACHE_NAMES <const> = {"SELECTED"}

local iobject = ecs.require "object"

local function get_vmin(w, h, ratio)
    local w = w / ratio
    local h = h / ratio
    return math.min(w, h)
end

local function _move_camera(pos)
    local mq = w:singleton("main_queue", "camera_ref:in")
    local e = world:entity(mq.camera_ref)

    local old = iom.get_position(e)
    local delta = math3d.inverse(math3d.sub(camera.get_central_position(), pos))
    local new = math3d.add(delta, old)

    camera.move({t = new})
end

function idetail.show(object_id)
    iui.open("detail_panel.rml", object_id)

    -- 显示环型菜单
    local vsobject = assert(vsobject_manager:get(object_id))
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName("entity", object.prototype_name)

    idetail.selected(object)
    _move_camera(vsobject:get_position())

    local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
    local ce = world:entity(mq.camera_ref)
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    local p = mu.world_to_screen(vp, vr, camera.get_central_position()) -- the position always in the center of the screen after move camera
    local vmin = get_vmin(vr.w, vr.h, vr.ratio)

    p = math3d.mul(p, math3d.vector {1 / vmin * 100, 1 / vmin * 100, 0})

    if typeobject.show_build_function ~= false then
        iui.open("build_function_pop.rml", object_id, math3d.index(p, 1), math3d.index(p, 2))
    elseif iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        iui.open("pipe_function_pop.rml", object_id, math3d.index(p, 1), math3d.index(p, 2))
    elseif iprototype.is_road(object.prototype_name) then
        iui.open("road_function_pop.rml", object_id, math3d.index(p, 1), math3d.index(p, 2))
    end

    do
        log.info(object.prototype_name, object.x, object.y, object.fluid_name, object.fluidflow_id)
    end
    return true
end

function idetail.unselected()
    for _, object in objects:all("SELECTED") do
        object.state = "constructed"
    end
    objects:clear({"SELECTED"})
end

function idetail.selected(object)
    idetail.unselected()

    object = objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone)
    object.state = "selected"
end