local ecs = ...
local world = ecs.world
local w = world.w

local camera_sys = ecs.system "camera_system"
local icamera_controller = ecs.require "engine.system.camera_controller"
local igroup = ecs.require "group"
local math3d = require "math3d"
local irq = ecs.require "ant.render|renderqueue"

function camera_sys:camera_usage()
	local e = irq.main_camera_changed()
	if e then
		local points = icamera_controller.get_interset_points(e)
		igroup.enable(points[2], math3d.set_index(points[3], 1, math3d.index(points[4], 1)))

		world:pub {"game_camera_changed"}
	end
end