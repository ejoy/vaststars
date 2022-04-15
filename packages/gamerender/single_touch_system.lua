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
                if not touch_id then
                    world:pub {"single_touch", "START", data}
                    touch_id = data.id
                end

            elseif state == "MOVE" then
                if touch_id == data.id then
                    world:pub {"single_touch", "MOVE", data}
                end

            elseif state == "CANCEL" or state == "END" then
                if touch_id == data.id then
                    world:pub {"single_touch", state, data}
                    touch_id = nil
                end
            end
        end
    end
end
