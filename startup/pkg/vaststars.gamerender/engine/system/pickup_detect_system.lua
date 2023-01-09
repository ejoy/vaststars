local ecs   = ...
local world = ecs.world
local w     = world.w

local pickup_detect_sys = ecs.system "pickup_detect_system"
local ipu = ecs.import.interface "ant.objcontroller|ipickup"
local gesture_mb = world:sub{"gesture", "tap"}
local mathpkg = import_package "ant.math"
local mu      = mathpkg.util

local function remap_xy(x, y)
    local nx, ny = mu.remap_xy(x, y, world.args.framebuffer.ratio)
	local vp = world.args.viewport
	return nx-vp.x, ny-vp.y
end

function pickup_detect_sys:data_changed()
    for _, _, x, y in gesture_mb:unpack() do
        x, y = remap_xy(x, y)
        ipu.pick(x, y)
    end
end
