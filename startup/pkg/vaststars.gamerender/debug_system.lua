local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system "debug_system"
local kb_mb = world:sub{"keyboard"}
local get_setting = require "debugger".get
local iui = ecs.import.interface "vaststars.gamerender|iui"

function debug_sys:ui_update()
    for _, key, press in kb_mb:unpack() do
        if key == "G" and press == 0 then
            local building = get_setting("create_building")
            iui.redirect("construct.rml", "construct_entity", building)
        end
    end
end

