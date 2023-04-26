local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mu, mc = mathpkg.util, mathpkg.constant
local irq = ecs.import.interface "ant.render|irenderqueue"
local ic = ecs.import.interface "ant.camera|icamera"

local MOVE_SPEED <const> = 8.0
local DROP_SPEED <const> = 2.5
local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}
local platform = require "bee.platform"
local function is_ios()
	return "ios" == platform.os
end

local camera_controller = ecs.system "camera_controller"
local icamera_controller = ecs.interface "icamera_controller"

local ui_message_move_camera_mb = world:sub {"ui_message", "move_camera"}
local mouse_wheel_mb = world:sub {"mouse_wheel"}
local gesture_pinch = world:sub {"gesture", "pinch"}
local gesture_pan = world:sub {"gesture", "pan"}

local datalist = require "datalist"
local fs = require "filesystem"
local CAMERA_DEFAULT = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/camera_default.prefab")):read "a")[1].data.scene
local CAMERA_CONSTRUCT = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/camera_construct.prefab")):read "a")[1].data.scene

local CAMERA_DEFAULT_SCALE    = CAMERA_DEFAULT.s and math3d.constant("v4", CAMERA_DEFAULT.s)or mc.ONE
local CAMERA_DEFAULT_ROTATION = CAMERA_DEFAULT.r and math3d.constant("quat", CAMERA_DEFAULT.r) or mc.IDENTITY_QUAT
local CAMERA_DEFAULT_POSITION = CAMERA_DEFAULT.t and math3d.constant("v4", CAMERA_DEFAULT.t) or mc.ZERO_PT

local CAMERA_CONSTRUCT_SCALE    = CAMERA_CONSTRUCT.s and math3d.constant("v4", CAMERA_CONSTRUCT.s) or mc.ONE
local CAMERA_CONSTRUCT_ROTATION = CAMERA_CONSTRUCT.r and math3d.constant("quat", CAMERA_CONSTRUCT.r) or mc.IDENTITY_QUAT
local CAMERA_CONSTRUCT_POSITION = CAMERA_CONSTRUCT.t and math3d.constant("v4", CAMERA_CONSTRUCT.t) or mc.ZERO_PT

local CAMERA_DEFAULT_YAIXS <const> = CAMERA_DEFAULT.t[2]
local CAMERA_YAIXS_MIN <const> = CAMERA_DEFAULT_YAIXS - 280
local CAMERA_YAIXS_MAX <const> = CAMERA_DEFAULT_YAIXS + 150

local function zoom(v)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce<close> = w:entity(mq.camera_ref, "scene:update")
    local deltavec = math3d.mul(iom.get_direction(ce), v * MOVE_SPEED)
    local position = math3d.add(iom.get_position(ce), deltavec)
    local y = math3d.index(position, 2)
    if y >= CAMERA_YAIXS_MIN and y <= CAMERA_YAIXS_MAX then
        iom.set_position(ce, position)
    end
end

local __handle_drop_camera; do
    local last_position

    function __handle_drop_camera(ce)
        local position

        for _, _, e in gesture_pan:unpack() do
            if e.state == "began" then
                local x, y = e.translationInView.x, e.translationInView.y
                last_position = math3d.ref(icamera_controller.screen_to_world(x, y, PLANES)[1])
            elseif e.state == "changed" then
                local x, y = e.translationInView.x, e.translationInView.y
                if is_ios() then
                    x, y = x * DROP_SPEED, y * DROP_SPEED
                end
                position = {x = x, y = y}
            elseif e.state == "ended" then
                last_position = nil
            end
        end

        if last_position and position then
            local current = icamera_controller.screen_to_world(position.x, position.y, PLANES)[1]
            local delta = math3d.ref(math3d.sub(last_position, current))
            iom.move_delta(ce, delta)
            world:pub {"dragdrop_camera", delta}
        end
    end
end

function camera_controller:camera_usage()
    local mq = w:first("main_queue camera_ref:in")
    local ce <close> = w:entity(mq.camera_ref)

    for _, delta in mouse_wheel_mb:unpack() do
        zoom(delta)
    end

    for _, _, e in gesture_pinch:unpack() do
        zoom(e.velocity)
    end

    __handle_drop_camera(ce)

    for _, _, left, top, position in ui_message_move_camera_mb:unpack() do
        local mq = w:first("main_queue render_target:in")
        local vr = mq.render_target.view_rect
        local vmin = math.min(vr.w / vr.ratio, vr.h / vr.ratio)
        local ui_position = icamera_controller.screen_to_world(left / 100 * vmin, top / 100 * vmin, PLANES)[1]

        local delta = math3d.set_index(math3d.sub(position, ui_position), 2, 0) -- the camera is always moving in the x/z axis and the y axis is always 0
        iom.move_delta(ce, delta)
    end
end

-- the following interfaces must be called during the `camera_usage` stage
function icamera_controller.screen_to_world(x, y, planes)
    local mq = w:first("main_queue render_target:in camera_ref:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vpmat = ce.camera.viewprojmat

    local vr = mq.render_target.view_rect
    local nx, ny = mu.remap_xy(x, y, vr.ratio)
    local ndcpt = mu.pt2D_to_NDC({nx, ny}, vr)
    ndcpt[3] = 0
    local p0 = mu.ndc_to_world(vpmat, ndcpt)
    ndcpt[3] = 1
    local p1 = mu.ndc_to_world(vpmat, ndcpt)

    local ray = {o = p0, d = math3d.sub(p0, p1)}

    local t = {}
    for _, plane in ipairs(planes) do
        t[#t + 1] = math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, plane), ray.o)
    end
    return t
end

function icamera_controller.world_to_screen(position)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    return mu.world_to_screen(vp, vr, position)
end

function icamera_controller.get_central_position()
    local ce <close> = w:entity(irq.main_camera())
    local ray = {o = iom.get_position(ce), d = math3d.mul(math.maxinteger, iom.get_direction(ce))}
    return math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, YAXIS_PLANE), ray.o)
end

function icamera_controller.focus_on_position(position)
    local mq = w:first("main_queue camera_ref:in")
    local ce <close> = w:entity(mq.camera_ref)
    local p = icamera_controller.get_central_position()
    local delta = math3d.set_index(math3d.sub(position, p), 2, 0) -- the camera is always moving in the x/z axis and the y axis is always 0
    iom.move_delta(ce, delta)
end

function icamera_controller.toggle_view(v)
    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref)

    if v == "construct" then
        local delta = math3d.sub(iom.get_position(e), CAMERA_DEFAULT_POSITION)
        local position = math3d.add(delta, CAMERA_CONSTRUCT_POSITION)
        iom.set_srt(e, CAMERA_CONSTRUCT_SCALE, CAMERA_CONSTRUCT_ROTATION, position)
    else
        local delta = math3d.sub(iom.get_position(e), CAMERA_CONSTRUCT_POSITION)
        local position = math3d.add(delta, CAMERA_DEFAULT_POSITION)
        iom.set_srt(e, CAMERA_DEFAULT_SCALE, CAMERA_DEFAULT_ROTATION, position)
    end
end

function icamera_controller.set_camera_from_prefab(prefab)
    local data = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/" .. prefab)):read "a")
    if not data then
        return
    end
    assert(data[1] and data[1].data and data[1].data.camera)
    local c = data[1].data

    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref, "scene:update")
    iom.set_srt(e, c.scene.s or mc.ONE, c.scene.r, c.scene.t)
    ic.set_frustum(e, c.camera.frustum)
end