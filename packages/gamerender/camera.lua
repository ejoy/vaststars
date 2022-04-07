local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local fs = require "filesystem"
local datalist  = require "datalist"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local math3d = require "math3d"
local math_util = import_package "ant.math".util
local pt2D_to_NDC = math_util.pt2D_to_NDC
local ndc_to_world = math_util.ndc_to_world
local irq = ecs.import.interface "ant.render|irenderqueue"

-- local YAXIS_PLANE <const> = math3d.ref(math3d.constant("v4", 0, 1, 0, 0))
local YAXIS_PLANE <const> = math3d.ref(math3d.vector(0, 1, 0, 0))

local camera_prefab_path <const> = fs.path "/pkg/vaststars.resources/"
local camera_prefab_file_name

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

    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref
    local e = world:entity(camera_ref)

    iom.set_srt(e, data.scene.srt.s or mc.ONE, data.scene.srt.r, data.scene.srt.t)
    iom.set_view(e, iom.get_position(e), iom.get_direction(e), data.scene.updir)
    camera_prefab_file_name = prefab_file_name
end

function camera.update(prefab_file_name)
    local sdata, ddata = get_camera_prefab_data(camera_prefab_file_name), get_camera_prefab_data(prefab_file_name)
    if not sdata or not ddata then
        return
    end

    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref
    local e = world:entity(camera_ref)

    local delta = math3d.sub(iom.get_position(e), sdata.scene.srt.t)
    local position = math3d.tovalue(math3d.add(delta, ddata.scene.srt.t))

    iom.set_srt(e, ddata.scene.srt.s or mc.ONE, ddata.scene.srt.r, position)
    iom.set_view(e, iom.get_position(e), iom.get_direction(e), ddata.scene.updir)
    camera_prefab_file_name = prefab_file_name
end

-- in `camera_usage` stage
function camera.screen_to_world(x, y)
    local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
    local ce = world:entity(mq.camera_ref)
    local vpmat = ce.camera.viewprojmat

    local vr = irq.view_rect "main_queue"
    local ndcpt = pt2D_to_NDC({x, y}, vr)
    ndcpt[3] = 0
    local p0 = ndc_to_world(vpmat, ndcpt)
    ndcpt[3] = 1
    local p1 = ndc_to_world(vpmat, ndcpt)

    local ray = {o = p0, d = math3d.sub(p0, p1)}
    return math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, YAXIS_PLANE), ray.o)
end

-- in `camera_usage` stage
function camera.get_central_position()
    local ce = world:entity(irq.main_camera())
    local ray = {o = iom.get_position(ce), d = math3d.mul(math.maxinteger, iom.get_direction(ce))}
    return math3d.tovalue(math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, YAXIS_PLANE), ray.o))
end

return camera