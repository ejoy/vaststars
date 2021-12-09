local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars|iui"

local ui_route_close_mb = world:sub {"ui", "route", "close"}
local route_sys = ecs.system "route_system"

function route_sys:data_changed()
    for _ in ui_route_close_mb:unpack() do
        -- todo bad taste
        iui.close("route")
        iui.open("construct", "construct.rml")
    end
end
