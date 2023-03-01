local ecs = ...
local world = ecs.world
local w = world.w

local single_touch_system = ecs.system "single_touch_system"
local touch_mb = world:sub {"touch"}

function single_touch_system:data_changed()
    for _, state, touches in touch_mb:unpack() do
        if #touches == 1 then
            world:pub {"single_touch", state, touches[1]}
        end
    end
end
