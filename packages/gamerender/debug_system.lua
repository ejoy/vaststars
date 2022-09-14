local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system "debug_system"
local debug_mb = world:sub {"debug"}
local funcs = {}

funcs[1] = function ()
end

function debug_sys:ui_update()
    for msg in debug_mb:each() do
        local func = funcs[msg[2]]
        if func then
            func(table.unpack(msg, 3))
        end
    end
end

