local ecs = ...
local world = ecs.world
local w = world.w

local icamera = ecs.import.interface "ant.camera|icamera"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local math3d = require "math3d"

local icc = ecs.interface "icamera_controller"
local cc_sys = ecs.system "camera_controller_system"

local keyboard_mb = world:sub {"keyboard"}
local mouse_wheel_mb = world:sub {"mouse_wheel"}
local camera_move_speed <const> = 0.5

local controller = {}
function icc.attach(camera_ref)
	controller.camera_ref = camera_ref
end

function icc.camera()
	return controller.camera_ref
end

local function can_move(camera)
	local lock_target = camera.lock_target
	return lock_target and lock_target.type ~= "move" or true
end

local function zoom_camera(camera, delta)
	if delta[1] ~= 0 or delta[2] ~= 0 or delta[3] ~= 0 then
		local srt = camera.scene.srt
		local p = math3d.vector(srt.t)
		local srtmat = math3d.matrix(srt)
		for i = 1, 3 do
			p = math3d.muladd(delta[i], math3d.index(srtmat, i), p)
		end

		local y = math3d.index(p, 2)
		if y > 1 and y < 10 then
			iom.set_position(camera, p)
		end
	end
end

function cc_sys:init_world()
	for e in w:select "main_queue camera_ref:in" do
        icc.attach(e.camera_ref)
    end
end

do
	local funcs = {}
	funcs['A'] = function(camera)
		iom.move_delta(camera, {-camera_move_speed, 0, 0})
	end
	funcs['D'] = function(camera)
		iom.move_delta(camera, {camera_move_speed, 0, 0})
	end
	funcs['S'] = function(camera)
		iom.move_delta(camera, {0, 0, -camera_move_speed})
	end
	funcs['W'] = function(camera)
		iom.move_delta(camera, {0, 0, camera_move_speed})
	end

	local func
	function cc_sys:data_changed()
		local camera_ref = icc.camera()
		if can_move(camera_ref) then
			local keyboard_delta = {0, 0, 0}
			for _, delta in mouse_wheel_mb:unpack() do
				if delta > 0 then
					keyboard_delta[3] = keyboard_delta[3] + camera_move_speed
				else
					keyboard_delta[3] = keyboard_delta[3] - camera_move_speed
				end
			end
			zoom_camera(camera_ref, keyboard_delta)

			for _, code, press in keyboard_mb:unpack() do
				func = funcs[code]
				if func then
					func(camera_ref)
				end
			end
		end
	end
end
