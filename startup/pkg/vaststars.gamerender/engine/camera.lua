local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local mathpkg = import_package "ant.math"
local mc, mu = mathpkg.constant, mathpkg.util
local math3d = require "math3d"
local irq = ecs.import.interface "ant.render|irenderqueue"
local ic = ecs.import.interface "ant.camera|icamera"
local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local prefab_parse = require("engine.prefab_parser").parse

---
local camera = {}
function camera.init(prefab_file_name)
    local data = prefab_parse("/pkg/vaststars.resources/" .. prefab_file_name)
    if not data then
        return
    end
    assert(data[1] and data[1].data and data[1].data.camera)
    local c = data[1].data

    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref, "scene:update")
    e.scene.updir = mc.NULL -- TODO: use math3d.lookto() to reset updir

    iom.set_srt(e, c.scene.s or mc.ONE, c.scene.r, c.scene.t)
    -- Note: It will be inversed when the animation exceeds 90 degrees
    -- iom.set_view(e, iom.get_position(e), iom.get_direction(e), math3d.vector(data.scene.updir)) -- don't need to set updir, it will cause nan error
    ic.set_frustum(e, c.camera.frustum)
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

-- in `camera_usage` stage
function camera.focus_on_position(position)
    local mq = w:first("main_queue camera_ref:in")
    local ce <close> = w:entity(mq.camera_ref)
    local p = camera.get_central_position()
    local delta = math3d.set_index(math3d.sub(position, p), 2, 0) -- the camera is always moving in the x/z axis and the y axis is always 0
    iom.move_delta(ce, delta)
end

return camera