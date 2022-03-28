local ecs = ...
local world = ecs.world
local w = world.w

local gesture_sys = ecs.system "gesture_system"
local touch_mb = world:sub {"touch"}

local active = false
local pos_x, pos_y = 0, 0
local gesture_min_distance <const> = 5

local function get_distance(x, y)
    return x ^ 2 + y ^ 2
end

function gesture_sys:data_changed()
    for _, state, data in touch_mb:unpack() do
        if state == "START" then
            pos_x, pos_y = data[1].x, data[1].y

        elseif state == "MOVE" then
            local distance_x = data[1].x - pos_x
            local distance_y = data[1].y - pos_y

            if get_distance(distance_x, distance_y) > gesture_min_distance then
                if math.abs(distance_x) > math.abs(distance_y) then
                    if distance_x > 0 then
                        world:pub{"gesture", "right"}
                    elseif distance_x < 0 then
                        world:pub{"gesture", "left"}
                    end
                elseif math.abs(distance_x) < math.abs(distance_y) then
                    if distance_y > 0 then
                        world:pub{"gesture", "up"}
                    elseif distance_y < 0 then
                        world:pub{"gesture", "down"}
                    end
                end
                active = true
            end
        elseif state == "END" or state == "CANCEL" then
            if active then
                world:pub{"gesture", "end"}
                active = false
            end
        end
    end
end
