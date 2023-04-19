local ecs = ...
local world = ecs.world
local w = world.w

local LONG_PRESS_DURATION <const> = 1000
local LONG_PRESS_OFFSET <const> = 50

local now = require "engine.time".now
local sys = ecs.system "input_simulate_system"
local mouse_mb = world:sub {"mouse", "LEFT"}
local math_abs = math.abs

local __touch; do
    local active = false
    function __touch(state, x, y)
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

local __long_press_gesture, __long_press_gesture_update; do
    local lasttime
    local lastx, lasty
    function __long_press_gesture(state, x, y)
        if state == "DOWN" then
            lasttime = now()
            lastx, lasty = x, y
        elseif state == "MOVE" then
            if lastx and lasty and math_abs(x - lastx) > LONG_PRESS_OFFSET and math_abs(y - lasty) > LONG_PRESS_OFFSET then
                lasttime = nil
            end
        elseif state == "UP" then
            lasttime = nil
        end
    end

    function __long_press_gesture_update()
        if lasttime and now() - lasttime > LONG_PRESS_DURATION then
            world:pub {"long_press_gesture", "tap", lastx, lasty}
            lasttime = nil
        end
    end
end

local __gesture; do
    local lasttime
    function __gesture(state, x, y)
        if state == "DOWN" then
            lasttime = now()
        elseif state == "UP" then
            if lasttime and now() - lasttime < LONG_PRESS_DURATION then
                world:pub {"gesture", "tap", {
                    locationInView = {
                        x = x,
                        y = y,
                    }
                }}
            end
            lasttime = nil
        end
    end
end

function sys:data_changed()
    for _, _, state, x, y in mouse_mb:unpack() do
        __touch(state, x, y)
        __gesture(state, x, y)
        __long_press_gesture(state, x, y)
    end
    __long_press_gesture_update()
end
