local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system "debug_system"
local debug_mb = world:sub {"debug"}
local funcs = {}

local saveload = ecs.require "saveload"

funcs[1] = function ()
    saveload:backup()
end

funcs[2] = function ()
    saveload:restore()
end

funcs[3] = function ()
end

function debug_sys:ui_update()
    for _, i in debug_mb:unpack() do
        local func = funcs[i]
        if func then
            func()
        end
    end
end

