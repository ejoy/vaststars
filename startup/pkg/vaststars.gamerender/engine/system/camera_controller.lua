local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.require "ant.objcontroller|obj_motion"
local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mu, mc = mathpkg.util, mathpkg.constant
local irq = ecs.require "ant.render|render_system.renderqueue"
local ic = ecs.require "ant.camera|camera"
local create_queue = require("utility.queue")
local hierarchy = require "hierarchy"
local animation = hierarchy.animation
local skeleton = hierarchy.skeleton
local math_max = math.max
local math_min = math.min

local MOVE_SPEED <const> = 8.0
local XZ_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})

local camera_controller = ecs.system "camera_controller"
local icamera_controller = {}

local gesture_pinch = world:sub {"gesture", "pinch"}
local gesture_pan = world:sub {"gesture", "pan"}

local function read_datalist(path)
    local fs = require "filesystem"
    local datalist = require "datalist"
    local fastio = require "fastio"
    return datalist.parse(fastio.readall(fs.path(path):localpath():string(), path))
end
local CAMERA_DEFAULT <const> = read_datalist "/pkg/vaststars.resources/camera_default.prefab" [1].data.scene
local CAMERA_CONSTRUCT <const> = read_datalist "/pkg/vaststars.resources/camera_construct.prefab" [1].data.scene
local CAMERA_PICKUP <const> = read_datalist "/pkg/vaststars.resources/camera_pickup.prefab" [1].data.scene

local CAMERA_DEFAULT_SCALE <const> = CAMERA_DEFAULT.s and math3d.constant("v4", CAMERA_DEFAULT.s)or mc.ONE
local CAMERA_DEFAULT_ROTATION <const> = CAMERA_DEFAULT.r and math3d.constant("quat", CAMERA_DEFAULT.r) or mc.IDENTITY_QUAT

local CAMERA_CONSTRUCT_SCALE <const> = CAMERA_CONSTRUCT.s and math3d.constant("v4", CAMERA_CONSTRUCT.s) or mc.ONE
local CAMERA_CONSTRUCT_ROTATION <const> = CAMERA_CONSTRUCT.r and math3d.constant("quat", CAMERA_CONSTRUCT.r) or mc.IDENTITY_QUAT
local CAMERA_CONSTRUCT_POSITION <const> = CAMERA_CONSTRUCT.t and math3d.constant("v4", CAMERA_CONSTRUCT.t) or mc.ZERO_PT
assert(math3d.index(CAMERA_CONSTRUCT_POSITION, 1) == 0)
assert(math3d.index(CAMERA_CONSTRUCT_POSITION, 2) == 0)
assert(math3d.index(CAMERA_CONSTRUCT_POSITION, 3) == 0)

local CAMERA_PICKUP_SCALE <const> = CAMERA_PICKUP.s and math3d.constant("v4", CAMERA_PICKUP.s) or mc.ONE
local CAMERA_PICKUP_ROTATION <const> = CAMERA_PICKUP.r and math3d.constant("quat", CAMERA_PICKUP.r) or mc.IDENTITY_QUAT
local CAMERA_PICKUP_POSITION <const> = CAMERA_PICKUP.t and math3d.constant("v4", CAMERA_PICKUP.t) or mc.ZERO_PT
assert(math3d.index(CAMERA_PICKUP_POSITION, 1) == 0)
assert(math3d.index(CAMERA_PICKUP_POSITION, 3) == 0)

local CAMERA_DEFAULT_YAIXS <const> = CAMERA_DEFAULT.t[2]
local CAMERA_YAIXS_MIN <const> = CAMERA_DEFAULT_YAIXS - 280
local CAMERA_YAIXS_MAX <const> = CAMERA_DEFAULT_YAIXS + 150

local CAMERA_XAIXS_MIN <const> = -1000
local CAMERA_XAIXS_MAX <const> = 1000
local CAMERA_ZAIXS_MIN <const> = -1450
local CAMERA_ZAIXS_MAX <const> = 800

local cam_cmd_queue = create_queue()
local cam_motion_matrix_queue = create_queue()
local LockAxis
local DeltaY

local function __clamp(v, min, max)
    return math_max(min, math_min(v, max))
end

local function zoom(factor, x, y)
    local ce <close> = world:entity(irq.main_camera())

    local pos = iom.get_position(ce)
    local target = icamera_controller.screen_to_world(x, y, XZ_PLANE)
    local dir = math3d.normalize(math3d.sub(target, pos))
    local pos = math3d.muladd(dir, factor * MOVE_SPEED, pos)

    local y = math3d.index(pos, 2)
    if y >= CAMERA_YAIXS_MIN and y <= CAMERA_YAIXS_MAX then
        pos = math3d.set_index(pos, 1, __clamp(math3d.index(pos, 1), CAMERA_XAIXS_MIN, CAMERA_XAIXS_MAX))
        pos = math3d.set_index(pos, 3, __clamp(math3d.index(pos, 3), CAMERA_ZAIXS_MIN, CAMERA_ZAIXS_MAX))
        iom.set_position(ce, pos)
        world:pub {"camera_zoom"}
    end
end

local function focus_on_position(position)
    math3d.unmark(position)

    local ce <close> = world:entity(irq.main_camera())
    local p = icamera_controller.get_central_position()
    local delta = math3d.set_index(math3d.sub(position, p), 2, 0) -- the camera is always moving in the x/z axis and the y axis is always 0
    return iom.get_scale(ce), iom.get_rotation(ce), math3d.add(iom.get_position(ce), delta)
end

--[[ local function get_dst_r_t_sample(p, v, src_r, src_t, dst_r, xzpoint, distance)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local vr = mq.render_target.view_rect
    local vp = math3d.mul(p, v)
    local screen_point = mu.world_to_screen(vp, vr, xzpoint)

    local wm = math3d.matrix{r = dst_r, t = src_t}
    local vm = math3d.inverse(wm)
    local vp1 = math3d.mul(p, vm)

    local sx, sy = math3d.index(screen_point, 1, 2)

    local src_dir = math3d.inverse(math3d.todirection(src_r))
    local src_plane = math3d.plane(xzpoint, src_dir)
    local src_distance = math3d.dot(src_t, src_dir) - math3d.index(src_plane, 4)

    local dst_dir = math3d.inverse(math3d.todirection(dst_r))
    local dst_xzpoint = math3d.sub(src_t, math3d.mul(dst_dir, src_distance + distance))
    local dst_plane = math3d.plane(dst_xzpoint, dst_dir)

    -- xzpoint_intersect_dst_plane_point
    local inter_point = icamera_controller.screen_to_world(sx, sy, dst_plane, vp1)

    local delta_t = math3d.sub(xzpoint, inter_point)
    local dst_t = math3d.add(src_t, delta_t)
    return math3d.mark(dst_t)
end

local function get_dst_pos(snum, p, v, src_r, src_t, dst_r, xzpoint, dis)
    local distance = dis and dis or 0
    local delta = 1 / snum
    local delta_distance = distance * delta
    local dst_table = {}
    local cur_src_r, cur_src_t = src_r, src_t
    for i = 1, snum do
        local t = delta * i
        if i == snum then t = 1 end
        local cur_dst_r = math3d.slerp(src_r, dst_r, t)
        local cur_dst_t = get_dst_r_t_sample(p, v, cur_src_r, cur_src_t, cur_dst_r, xzpoint, delta_distance)
        dst_table[#dst_table+1] = math3d.mark(math3d.matrix{r = cur_dst_r, t = cur_dst_t})
        cur_src_r, cur_src_t = cur_dst_r, cur_dst_t
    end
    return dst_table
end

local xzpoint, viewmat, projmat, dst_r, dst_t, delta_distance, sample_num

local function toggle_view(v, xzpos, snum)

    local function get_delta_distance(src_r, src_t, dst_r, dst_t, xzpoint)
        local src_dir = math3d.inverse(math3d.todirection(src_r))
        local src_plane = math3d.plane(xzpoint, src_dir)
        local src_dis = math3d.dot(src_t, src_dir) - math3d.index(src_plane, 4)
    
        local dst_dir = math3d.inverse(math3d.todirection(dst_r))
        local dst_plane = math3d.plane(xzpoint, dst_dir)
        local dst_dis = math3d.dot(dst_t, dst_dir) - math3d.index(dst_plane, 4)
        
        return dst_dis - src_dis
    end

    local function adjust_camera_rt(target_rot, target_pos)
        math3d.unmark(xzpos)

        local ce <close> = world:entity(irq.main_camera(), "camera:in scene:in")
        assert(math3d.index(xzpos, 2) == 0, "y axis should be zero!")

        local src_r, src_t = ce.scene.r, ce.scene.t
        dst_r, xzpoint, viewmat, projmat = target_rot, math3d.mark(xzpos), ce.camera.viewmat, math3d.mark(ce.camera.projmat)
        delta_distance = get_delta_distance(src_r, src_t, target_rot, target_pos, xzpoint)

        local dst_table = get_dst_pos(sample_num, projmat, viewmat, src_r, src_t, dst_r, xzpoint, delta_distance)
        dst_t = dst_table[#dst_table].t
        viewmat = math3d.mark(math3d.inverse(math3d.matrix{r=dst_r,t=dst_t}))
        return dst_table
    end

    local function restore_camera_rt(target_rot)
        local delta_dis = delta_distance and -delta_distance or 0
        local dst_table = get_dst_pos(sample_num, projmat, viewmat, dst_r, dst_t, target_rot, xzpoint, delta_dis)
        return dst_table
    end

    -- sample_num should be set
    sample_num = snum and snum or 20

    if v == "construct" then
        return adjust_camera_rt(CAMERA_CONSTRUCT_ROTATION, CAMERA_CONSTRUCT_POSITION)
    elseif v == "pickup" then
        return adjust_camera_rt(CAMERA_PICKUP_ROTATION, CAMERA_PICKUP_POSITION)
    elseif v == "default" then
        return restore_camera_rt(CAMERA_DEFAULT_ROTATION)
    else
        assert(false)
    end

end ]]

local function get_world_delta(rotation, xzpos, delta_y)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = world:entity(mq.camera_ref, "camera:in scene:in")
    local vr = mq.render_target.view_rect

    local vp0 = ce.camera.viewprojmat
    local screen_point = mu.world_to_screen(vp0, vr, xzpos)
    local dy = delta_y and math3d.vector(0, delta_y, 0) or math3d.vector(0, 0, 0)
    local wm = math3d.matrix{s=ce.scene.s,r=rotation,t=math3d.add(ce.scene.t, dy)}
    local vm = math3d.inverse(wm)
    local vp1 = math3d.mul(ce.camera.projmat, vm)

    local sx, sy = math3d.index(screen_point, 1, 2)
    return math3d.add(math3d.sub(xzpos, icamera_controller.screen_to_world(sx, sy, XZ_PLANE, vp1)), dy)
end

local function toggle_view(v, xzpos)
    math3d.unmark(xzpos)

    local ce <close> = world:entity(irq.main_camera())
    assert(math3d.index(xzpos, 2) == 0, "y axis should be zero!")
    local position = iom.get_position(ce)

    if v == "construct" then
        local world_delta = get_world_delta(CAMERA_CONSTRUCT_ROTATION, xzpos)
        return CAMERA_CONSTRUCT_SCALE, CAMERA_CONSTRUCT_ROTATION, math3d.add(position, world_delta)
    elseif v == "pickup" then
            DeltaY = math3d.index(CAMERA_PICKUP_POSITION, 2) - math3d.index(position, 2)
            local world_delta = get_world_delta(CAMERA_PICKUP_ROTATION, xzpos, DeltaY)
            return CAMERA_PICKUP_SCALE, CAMERA_PICKUP_ROTATION, math3d.add(position, world_delta)
    elseif v == "default" then
        local y
        if DeltaY then
            y = -DeltaY
            DeltaY = nil
        end
        local world_delta = get_world_delta(CAMERA_DEFAULT_ROTATION, xzpos, y)
        return CAMERA_DEFAULT_SCALE, CAMERA_DEFAULT_ROTATION, math3d.add(position, world_delta)
    else
        assert(false)
    end
end

local function __set_camera_from_prefab(prefab)
    local data = read_datalist("/pkg/vaststars.resources/" .. prefab)
    if not data then
        return
    end
    assert(data[1] and data[1].data and data[1].data.camera)
    local c = data[1].data

    local ce <close> = world:entity(irq.main_camera())
    iom.set_srt(ce, c.scene.s or mc.ONE, c.scene.r, c.scene.t)
    ic.set_frustum(ce, c.camera.frustum)
end

local function __set_camera_srt(s, r, t)
    local ce <close> = world:entity(irq.main_camera())
    iom.set_srt(ce, s, r, t)
end

local function __check_camera_editable()
    return cam_cmd_queue:size() <= 0 and cam_motion_matrix_queue:size() <= 0
end

local function __add_camera_track(s, r, t)
    local raw_animation = animation.new_raw_animation()
    local skl = skeleton.build({{name = "root", s = mc.T_ONE, r = mc.T_IDENTITY_QUAT, t = mc.T_ZERO}})
    raw_animation:setup(skl, 2)

    local ce <close> = world:entity(irq.main_camera())

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
        cam_motion_matrix_queue:push( math3d.mark(poseresult:joint(1)) )
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
            math3d.unmark(mat)

            local ce <close> = world:entity(irq.main_camera())
            iom.set_srt(ce, math3d.srt(mat))
            world:pub {"dragdrop_camera"}
        end
    end
end

local __handle_drop_camera; do
    local starting = math3d.ref()

    function __handle_drop_camera(ce)
        local ending_x, ending_y
        for _, _, e in gesture_pan:unpack() do
            if __check_camera_editable() then
                if e.state == "began" then
                    starting.v = icamera_controller.screen_to_world(e.x, e.y, XZ_PLANE)
                else
                    ending_x, ending_y = e.x, e.y
                end
            end
        end

        if starting.v and ending_x and ending_y then
            w:extend(ce, "scene:in")
            local scene = ce.scene

            local ending = icamera_controller.screen_to_world(ending_x, ending_y, XZ_PLANE)
            local delta_vec = math3d.sub(starting, ending)
            local pos = math3d.add(scene.t, delta_vec)

            if LockAxis then
                if LockAxis == "x-axis" then
                    pos = math3d.set_index(pos, 1, math3d.index(scene.t, 1))
                elseif LockAxis == "z-axis" then
                    pos = math3d.set_index(pos, 3, math3d.index(scene.t, 3))
                elseif LockAxis == "xz-axis" then
                    return
                else
                    assert(false)
                end
            end

            pos = math3d.set_index(pos, 1, __clamp(math3d.index(pos, 1), CAMERA_XAIXS_MIN, CAMERA_XAIXS_MAX))
            pos = math3d.set_index(pos, 3, __clamp(math3d.index(pos, 3), CAMERA_ZAIXS_MIN, CAMERA_ZAIXS_MAX))

            iom.set_position(ce, pos)
            world:pub {"dragdrop_camera", math3d.ref(delta_vec)}
        end
    end
end

function camera_controller:camera_usage()
    local ce <close> = world:entity(irq.main_camera())

    for _, _, e in gesture_pinch:unpack() do
        if __check_camera_editable() then
            zoom(e.velocity, e.x, e.y)
        end
    end

    __handle_drop_camera(ce)
    __handle_camera_motion()
end

-- the following interfaces must be called during the `camera_usage` stage
function icamera_controller.screen_to_world(x, y, plane, vp)
    local ce <close> = world:entity(irq.main_camera(), "camera:in")
    local vpmat = vp and vp or ce.camera.viewprojmat

    local vr = irq.view_rect("main_queue")
    local nx, ny = mu.remap_xy(x, y, vr.ratio)
    local ndcpt = mu.pt2D_to_NDC({nx, ny}, vr)
    ndcpt[3] = 0
    local p0 = mu.ndc_to_world(vpmat, ndcpt)
    ndcpt[3] = 1
    local p1 = mu.ndc_to_world(vpmat, ndcpt)

    local ray = {o = p0, d = math3d.sub(p0, p1)}
    return math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, plane), ray.o)
end

function icamera_controller.world_to_screen(position)
    local ce <close> = world:entity(irq.main_camera(), "camera:in")
    local vp = ce.camera.viewprojmat
    local vr = irq.view_rect("main_queue")
    return mu.world_to_screen(vp, vr, position)
end

function icamera_controller.get_central_position()
    local ce <close> = world:entity(irq.main_camera())
    local ray = {o = iom.get_position(ce), d = math3d.mul(math.maxinteger, iom.get_direction(ce))}
    return math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, XZ_PLANE), ray.o)
end

function icamera_controller.get_interset_points()
    local ce <close> = world:entity(irq.main_camera(), "camera:in scene:in")
    local points = math3d.frustum_points(ce.camera.viewprojmat)
    local lb_raydir = math3d.sub(math3d.array_index(points, 5), math3d.array_index(points, 1))
    local lt_raydir = math3d.sub(math3d.array_index(points, 6), math3d.array_index(points, 2))
    local rb_raydir = math3d.sub(math3d.array_index(points, 7), math3d.array_index(points, 3))
    local rt_raydir = math3d.sub(math3d.array_index(points, 8), math3d.array_index(points, 4))

    local height = 0
    local xz_plane = math3d.vector(0, 1, 0, height)

    local eyepos = math3d.index(ce.scene.worldmat, 4)
    return {
        math3d.muladd(math3d.plane_ray(eyepos, lb_raydir, xz_plane), lb_raydir, eyepos),
        math3d.muladd(math3d.plane_ray(eyepos, lt_raydir, xz_plane), lt_raydir, eyepos),
        math3d.muladd(math3d.plane_ray(eyepos, rb_raydir, xz_plane), rb_raydir, eyepos),
        math3d.muladd(math3d.plane_ray(eyepos, rt_raydir, xz_plane), rt_raydir, eyepos),
    }
end

function icamera_controller.set_camera_from_prefab(prefab, callback)
    cam_cmd_queue:push {{"set_camera_from_prefab", prefab}}
    if callback then
        cam_cmd_queue:push {{"callback", callback}}
    end
end

function icamera_controller.focus_on_position(position, callback)
    cam_cmd_queue:push {{"focus_on_position", math3d.mark(position)}}
    if callback then
        cam_cmd_queue:push {{"callback", callback}}
    end
end

function icamera_controller.toggle_view(v, xzpos, callback)
    cam_cmd_queue:push {{"toggle_view", v, math3d.mark(xzpos)}}
    if callback then
        cam_cmd_queue:push {{"callback", callback}}
    end
end

function icamera_controller.lock_axis(v)
    LockAxis = v
end

function icamera_controller.unlock_axis()
    LockAxis = nil
end

-- for debug
function icamera_controller.set_camera_srt(s, r, t, callback)
    cam_cmd_queue:push {{"set_camera_srt", s, r, t}}
    if callback then
        cam_cmd_queue:push {{"callback", callback}}
    end
end

return icamera_controller
