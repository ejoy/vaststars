local ecs   = ...
local world = ecs.world
local w     = world.w

local pickup_detect_sys = ecs.system "pickup_detect_system"
local ipu = ecs.import.interface "ant.objcontroller|ipickup"
local gesture_mb = world:sub{"gesture", "tap"}

local function remap_xy(x, y)
	local tmq = w:singleton("tonemapping_queue", "render_target:in")
	local vr = tmq.render_target.view_rect
	return x-vr.x, y-vr.y
end

function pickup_detect_sys:data_changed()
    for _, _, x, y in gesture_mb:unpack() do
        x, y = remap_xy(x, y)
        ipu.pick(x, y)
    end
end
