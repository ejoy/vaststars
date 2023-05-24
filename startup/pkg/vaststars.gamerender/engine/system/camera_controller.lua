local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mu, mc = mathpkg.util, mathpkg.constant
local irq = ecs.import.interface "ant.render|irenderqueue"
local ic = ecs.import.interface "ant.camera|icamera"
local platform = require "bee.platform"
local create_queue = require("utility.queue")
local hierarchy = require "hierarchy"
local animation = hierarchy.animation
local skeleton = hierarchy.skeleton

local MOVE_SPEED <const> = 8.0
local PAN_SPEED = 1.0
if "ios" == platform.os then
    PAN_SPEED = 2.5
end

local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}

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

local CAMERA_DELTA_Z <const> = math3d.index(math3d.sub(CAMERA_CONSTRUCT_POSITION, CAMERA_DEFAULT_POSITION), 3)

local CAMERA_DEFAULT_YAIXS <const> = CAMERA_DEFAULT.t[2]
local CAMERA_YAIXS_MIN <const> = CAMERA_DEFAULT_YAIXS - 280
local CAMERA_YAIXS_MAX <const> = CAMERA_DEFAULT_YAIXS + 150

local cam_cmd_queue = create_queue()
local cam_motion_matrix_queue = create_queue()

local function zoom(factor, x, y)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref)

    local position = iom.get_position(ce)
    local target = icamera_controller.screen_to_world(x, y, PLANES)[1]
    local dir = math3d.normalize(math3d.sub(target, position))
    local position = math3d.muladd(dir, factor * MOVE_SPEED, position)

    local y = math3d.index(position, 2)
    if y >= CAMERA_YAIXS_MIN and y <= CAMERA_YAIXS_MAX then
        iom.set_position(ce, position)
        world:pub {"camera_zoom"}
    end
end

local function focus_on_position(position)
    local mq = w:first("main_queue camera_ref:in")
    local ce <close> = w:entity(mq.camera_ref)
    local p = icamera_controller.get_central_position()
    local delta = math3d.set_index(math3d.sub(position, p), 2, 0) -- the camera is always moving in the x/z axis and the y axis is always 0
    return iom.get_scale(ce), iom.get_rotation(ce), math3d.add(iom.get_position(ce), delta)
end

local function toggle_view(v)
    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref)

    -- using the properties of similar triangles to calculate the position of the z-axis
    if v == "construct" then
        local position = iom.get_position(e)
        local z = CAMERA_DELTA_Z * (math3d.index(position, 2) / math3d.index(CAMERA_DEFAULT_POSITION, 2))
        local position = math3d.add(iom.get_position(e), math3d.vector(0, 0, z))
        return CAMERA_CONSTRUCT_SCALE, CAMERA_CONSTRUCT_ROTATION, position
    else
        local position = iom.get_position(e)
        local z = -CAMERA_DELTA_Z * (math3d.index(position, 2) / math3d.index(CAMERA_DEFAULT_POSITION, 2))
        local position = math3d.add(iom.get_position(e), math3d.vector(0, 0, z))
        return CAMERA_DEFAULT_SCALE, CAMERA_DEFAULT_ROTATION, position
    end
end

local function __set_camera_from_prefab(prefab)
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

local function __set_camera_srt(s, r, t)
    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref, "scene:update")
    iom.set_srt(e, s, r, t)
end

local function __check_camera_editable()
    return cam_cmd_queue:size() <= 0 and cam_motion_matrix_queue:size() <= 0
end

local function __add_camera_track(s, r, t)
    local raw_animation = animation.new_raw_animation()
    local skl = skeleton.build({{name = "root", s = mc.T_ONE, r = mc.T_IDENTITY_QUAT, t = mc.T_ZERO}})
    raw_animation:setup(skl, 2)

    local mq = w:first("main_queue camera_ref:in")
    local ce <close> = w:entity(mq.camera_ref)

    raw_animation:push_prekey(
        "root",
        0,
        iom.get_scale(ce),
        iom.get_rotation(ce),
        iom.get_position(ce)
    )

    raw_animation:push_prekey(
        "root",
        1,
        s,
        r,
        t
    )

    local ani = raw_animation:build()
    local poseresult = animation.new_pose_result(#skl)
    poseresult:setup(skl)

    local ratio = 0
    local step = 2 / 30

    while ratio <= 1.0 do
        poseresult:do_sample(animation.new_sampling_context(1), ani, ratio, 0)
        poseresult:fetch_result()
        cam_motion_matrix_queue:push( math3d.ref(poseresult:joint(1)) )
        ratio = ratio + step
    end
end

local function __handle_camera_motion()
    if cam_motion_matrix_queue:size() == 0 then
        if cam_cmd_queue:size() == 0 then
            return
        end

        local cmd = assert(cam_cmd_queue:pop())
        local c = cmd[1]
        if c[1] == "focus_on_position" then
            __add_camera_track(focus_on_position(table.unpack(c, 2)))
        elseif c[1] == "toggle_view" then
            __add_camera_track(toggle_view(table.unpack(c, 2)))
        elseif c[1] == "callback" then
            c[2]()
        elseif c[1] == "set_camera_from_prefab" then
            __set_camera_from_prefab(c[2])
        elseif c[1] == "set_camera_srt" then
            __set_camera_srt(c[2], c[3], c[4])
        else
            assert(false)
        end
    end

    if cam_motion_matrix_queue:size() > 0 then
        local mat = cam_motion_matrix_queue:pop()
        if mat then
            local mq = w:first("main_queue camera_ref:in")
            local e <close> = w:entity(mq.camera_ref)
            iom.set_srt(e, math3d.srt(mat))
        end
    end
end

local __handle_drop_camera; do
    local last_position

    function __handle_drop_camera(ce)
        local position

        for _, _, e in gesture_pan:unpack() do
            if __check_camera_editable() then
                if e.state == "began" then
                    local x, y = e.translationInView.x, e.translationInView.y
                    last_position = math3d.ref(icamera_controller.screen_to_world(x, y, PLANES)[1])
                elseif e.state == "changed" then
                    local x, y = e.translationInView.x * PAN_SPEED, e.translationInView.y * PAN_SPEED
                    position = {x = x, y = y}
                elseif e.state == "ended" then
                    last_position = nil
                end
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

    for _, delta, x, y in mouse_wheel_mb:unpack() do
        if __check_camera_editable() then
            zoom(delta, x, y)
        end
    end

    for _, _, e in gesture_pinch:unpack() do
        if __check_camera_editable() then
            zoom(e.velocity, e.locationInView.x, e.locationInView.y)
        end
    end

    __handle_drop_camera(ce)
    __handle_camera_motion()

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

function icamera_controller.set_camera_from_prefab(prefab, callback)
    cam_cmd_queue:push {{"set_camera_from_prefab", prefab}}
    if callback then
        cam_cmd_queue:push {{"callback", callback}}
    end
end

function icamera_controller.focus_on_position(position, callback)
    cam_cmd_queue:push {{"focus_on_position", position}}
    if callback then
        cam_cmd_queue:push {{"callback", callback}}
    end
end

function icamera_controller.toggle_view(v, callback)
    cam_cmd_queue:push {{"toggle_view", v}}
    if callback then
        cam_cmd_queue:push {{"callback", callback}}
    end
end

function icamera_controller.set_camera_srt(s, r, t, callback)
    cam_cmd_queue:push {{"set_camera_srt", s, r, t}}
    if callback then
        cam_cmd_queue:push {{"callback", callback}}
    end
end