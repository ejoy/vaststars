local ecs = ...
local world = ecs.world
local w = world.w

local ui_route_edit_mb = world:sub {"ui", "route", "edit"}
local route_sys = ecs.system "route_system"

function route_sys:data_changed()
    for _ in ui_route_edit_mb:unpack() do
        
    end
end
