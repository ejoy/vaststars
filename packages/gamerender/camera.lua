local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local math_util = import_package "ant.math".util
local pt2D_to_NDC = math_util.pt2D_to_NDC
local ndc_to_world = math_util.ndc_to_world
local plane = math3d.ref(math3d.vector(0, 1, 0, 0))
local irq = ecs.import.interface "ant.render|irenderqueue"

local m = {}

-- in `camera_usage` stage
function m.screen_to_world(x, y)
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
    return math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, plane), ray.o)
end
return m