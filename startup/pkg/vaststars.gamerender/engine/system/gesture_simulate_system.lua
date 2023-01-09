local ecs = ...
local world = ecs.world
local w = world.w

local gesture_simulate_sys = ecs.system "gesture_simulate_system"
local mouse_mb = world:sub {"mouse", "LEFT"}
local active = false

function gesture_simulate_sys:data_changed()
    for _, _, state, x, y in mouse_mb:unpack() do
        if state == "DOWN" then
            active = true
        elseif state == "UP" then
            if active then
                world:pub {"gesture", "tap", x, y}
            end
            active = false
        end
    end
end
