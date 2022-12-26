local ecs = ...
local world = ecs.world
local w = world.w

local touch_simulate_sys = ecs.system "single_touch_system"
local touch_mb = world:sub {"touch"}
local touch_id

function touch_simulate_sys:data_changed()
    for _, state, datas in touch_mb:unpack() do
        for _, data in pairs(datas) do
            if state == "START" then
                world:pub {"single_touch", "START", data}
            elseif state == "MOVE" then
                world:pub {"single_touch", "MOVE", data}
            elseif state == "CANCEL" or state == "END" then
                world:pub {"single_touch", state, data}
            end
        end
    end
end
