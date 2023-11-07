local ecs = ...
local world = ecs.world
local w = world.w

local camera_sys = ecs.system "camera_system"
local icamera_controller = ecs.require "engine.system.camera_controller"
local igroup = ecs.require "group"
local math3d = require "math3d"

function camera_sys:camera_usage()
    local mq = w:first "main_queue camera_ref:in"
    local ce = world:entity(mq.camera_ref, "camera_changed?in camera:in scene:in")
    if ce.camera_changed then
        local points = icamera_controller.get_interset_points(ce)
        igroup.enable(points[2], math3d.set_index(points[3], 1, math3d.index(points[4], 1)))
    end
end