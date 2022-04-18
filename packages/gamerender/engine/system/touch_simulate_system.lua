local ecs = ...
local world = ecs.world
local w = world.w

local touch_simulate_sys = ecs.system "touch_simulate_system"
local mouse_mb = world:sub {"mouse", "LEFT"}
local active = false

function touch_simulate_sys:data_changed()
    for _, _, state, x, y in mouse_mb:unpack() do
        if state == "DOWN" then
            world:pub {"touch", "START", {{x = x, y = y, id = 0}}}
            active = true
        elseif state == "MOVE" then
            if active then
                world:pub {"touch", "MOVE", {{x = x, y = y, id = 0}}}
            end
        elseif state == "UP" then
            world:pub {"touch", "END", {{x = x, y = y, id = 0}}}
            active = false
        end
    end
end
