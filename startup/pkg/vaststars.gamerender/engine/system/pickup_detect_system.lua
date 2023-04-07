local ecs   = ...
local world = ecs.world
local w     = world.w

local pickup_detect_sys = ecs.system "pickup_detect_system"
local ipu = ecs.import.interface "ant.objcontroller|ipickup"
local gesture_mb = world:sub{"gesture", "tap"}
local long_press_gesture_mb = world:sub{"long_press_gesture", "tap"}

local mathpkg = import_package "ant.math"
local mu      = mathpkg.util

local function remap_xy(x, y)
    local nx, ny = mu.remap_xy(x, y, world.args.framebuffer.ratio)
	local vp = world.args.viewport
	return nx-vp.x, ny-vp.y
end

local function __gesture(eid, pc)
    world:pub {"pickup_gesture", eid, pc.clickpt[1], pc.clickpt[2]}
end

local function __long_press_gesture(eid, pc)
    world:pub {"pickup_long_press_gesture", eid, pc.clickpt[1], pc.clickpt[2]}
end

function pickup_detect_sys:data_changed()
    for _, _, x, y in gesture_mb:unpack() do
        x, y = remap_xy(x, y)
        ipu.pick(x, y, __gesture)
    end
    for _, _, x, y in long_press_gesture_mb:unpack() do
        x, y = remap_xy(x, y)
        ipu.pick(x, y, __long_press_gesture)
    end
end
