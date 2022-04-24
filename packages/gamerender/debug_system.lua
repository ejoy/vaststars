local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system "debug_system"
local debug_mb = world:sub {"debug"}
local funcs = {}

funcs[1] = function ()
    local iui = ecs.import.interface "vaststars.gamerender|iui"
    iui.open("option_pop.rml")
end

function debug_sys:ui_update()
    for _, i in debug_mb:unpack() do
        local func = funcs[i]
        if func then
            func()
        end
    end
end

