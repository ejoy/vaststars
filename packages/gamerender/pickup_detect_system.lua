local ecs   = ...
local world = ecs.world
local w     = world.w

local dpd_sys = ecs.system "pickup_detect_system"
local ipu = ecs.import.interface "ant.objcontroller|ipickup"
local touch_mb = world:sub{"touch"}

local function remap_xy(x, y)
	local tmq = w:singleton("tonemapping_queue", "render_target:in")
	local vr = tmq.render_target.view_rect
	return x-vr.x, y-vr.y
end

function dpd_sys:data_changed()
    for _, state, data in touch_mb:unpack() do
        if state == "START" then
            local x, y = remap_xy(data[1].x, data[1].y)
            ipu.pick(x, y)
        end
    end
end
