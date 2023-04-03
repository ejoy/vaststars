local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local fs = require "filesystem"
local datalist  = require "datalist"
local mathpkg = import_package "ant.math"
local mc, mu = mathpkg.constant, mathpkg.util
local math3d = require "math3d"
local irq = ecs.import.interface "ant.render|irenderqueue"
local ic = ecs.import.interface "ant.camera|icamera"
local create_queue = require "utility.queue"
local hierarchy = require "hierarchy"
local animation = hierarchy.animation
local skeleton = hierarchy.skeleton
local terrain = ecs.require "terrain"

local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})

local camera_prefab_path <const> = fs.path "/pkg/vaststars.resources/"
local camera_prefab_file_name
local camera_matrix = create_queue()

local function get_camera_prefab_data(prefab_file_name)
    local f <close> = fs.open(camera_prefab_path .. prefab_file_name)
    if not f then
        log.error(("can nof found prefab `%s`"):format(prefab_file_name))
        return
    end

    local data = datalist.parse(f:read "a")[1].data
    if not data then
        log.error(("invalid data `%s`"):format(prefab_file_name))
        return
    end

    return data
end

---
local camera = {}
function camera.init(prefab_file_name)
    local data = get_camera_prefab_data(prefab_file_name)
    if not data then
        return
    end

    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref, "scene:update")
    e.scene.updir = mc.NULL -- TODO: use math3d.lookto() to reset updir

    iom.set_srt(e, data.scene.s or mc.ONE, data.scene.r, data.scene.t)
    -- Note: It will be inversed when the animation exceeds 90 degrees
    -- iom.set_view(e, iom.get_position(e), iom.get_direction(e), math3d.vector(data.scene.updir)) -- don't need to set updir, it will cause nan error
    ic.set_frustum(e, data.camera.frustum)
    camera_prefab_file_name = prefab_file_name
end

function camera.move(srt)
    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref)

    local s = iom.get_scale(e)
    local r = iom.get_rotation(e)
    local t = iom.get_position(e)

    local new_s, new_r, new_t = s, r, t
    if srt.s then
        new_s = srt.s
    end
    if srt.r then
        new_r = srt.r
    end
    if srt.t then
        new_t = srt.t
    end

    local raw_animation = animation.new_raw_animation()
    local skl = skeleton.build({{name = "root", s = mc.T_ONE, r = mc.T_IDENTITY_QUAT, t = mc.T_ZERO}})
    raw_animation:setup(skl, 2)

    raw_animation:push_prekey(
        "root",
        0,
        s,
        r,
        t
    )

    raw_animation:push_prekey(
        "root",
        1,
        new_s,
        new_r,
        new_t
    )

    local ani = raw_animation:build()
    local poseresult = animation.new_pose_result(#skl)
    poseresult:setup(skl)

    local ratio = 0
    local step = 2 / 30

    while ratio <= 1.0 do
        poseresult:do_sample(animation.new_sampling_context(1), ani, ratio, 0)
        poseresult:fetch_result()
        camera_matrix:push( math3d.ref(poseresult:joint(1)) )
        ratio = ratio + step
    end
end

function camera.transition(prefab_file_name)
    local sdata, ddata = get_camera_prefab_data(camera_prefab_file_name), get_camera_prefab_data(prefab_file_name)
    if not sdata or not ddata then
        return
    end

    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref)

    local old = iom.get_position(e)
    local delta = math3d.sub(old, sdata.scene.t)
    local new = math3d.add(delta, ddata.scene.t)

    camera.move({r = ddata.scene.r, t = new})
    camera_prefab_file_name = prefab_file_name
end

function camera.update()
    local mat = camera_matrix:pop()
    if mat then
        local mq = w:first("main_queue camera_ref:in")
        local e <close> = w:entity(mq.camera_ref)
        local s, r, t = math3d.srt(mat)
        iom.set_scale(e, s)
        iom.set_rotation(e, r)
        iom.set_position(e, t)

        if terrain.init then
            local coord = terrain:align(camera.get_central_position(), 1, 1)
            if coord then
                terrain:enable_terrain(coord[1], coord[2])
            end
        end
    end
end

-- in `camera_usage` stage
function camera.screen_to_world(x, y, planes)
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

-- in `camera_usage` stage
function camera.get_central_position()
    local ce <close> = w:entity(irq.main_camera())
    local ray = {o = iom.get_position(ce), d = math3d.mul(math.maxinteger, iom.get_direction(ce))}
    return math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, YAXIS_PLANE), ray.o)
end

function camera.print_viewprojmat(prefix)
    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vpmat = ce.camera.viewprojmat
    if vpmat then
        log.info(("%s viewprojmat: %s"):format(prefix, math3d.tostring(vpmat)))
    else
        log.info(("%s viewprojmat: %s"):format(prefix, "nil"))
    end
end

return camera