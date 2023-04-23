local ecs = ...
local world = ecs.world
local w = world.w

local LONG_PRESS_DURATION <const> = 1000
local LONG_PRESS_OFFSET <const> = 50

local now = require "engine.time".now
local sys = ecs.system "input_simulate_system"
local mouse_mb = world:sub {"mouse", "LEFT"}
local math_abs = math.abs

local __simulate_tap; do
    local lasttime
    function __simulate_tap(state, x, y)
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

local __simulate_pan; do
    local active = false
    function __simulate_pan(state, x, y)
        if state == "DOWN" then
            world:pub {"gesture", "pan", {state = "began", translationInView = {x = x, y = y}}}
            active = true
        elseif state == "MOVE" then
            if active then
                world:pub {"gesture", "pan", {state = "changed", translationInView = {x = x, y = y}}}
            end
        elseif state == "UP" then
            world:pub {"gesture", "pan", {state = "ended", translationInView = {x = x, y = y}}}
            active = false
        end
    end
end

local __simulate_long_press, __simulate_long_press_update; do
    local lasttime
    local lastx, lasty
    function __simulate_long_press(state, x, y)
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

    function __simulate_long_press_update()
        if lasttime and now() - lasttime > LONG_PRESS_DURATION then
            world:pub {"gesture", "long_press", {
                locationInView = {
                    x = lastx,
                    y = lasty,
                },
            }}
            lasttime = nil
        end
    end
end

function sys:data_changed()
    for _, _, state, x, y in mouse_mb:unpack() do
        __simulate_tap(state, x, y)
        __simulate_pan(state, x, y)
        __simulate_long_press(state, x, y)
    end
    __simulate_long_press_update()
end
