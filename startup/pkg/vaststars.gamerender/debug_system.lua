local ecs = ...
local world = ecs.world
local w = world.w

local debug_sys = ecs.system "debug_system"
local kb_mb = world:sub{"keyboard"}
local gameplay_core = require "gameplay.core"
local export_startup = ecs.require "export_startup"

function debug_sys:init_world()
end

function debug_sys:ui_update()
    for _, key, press in kb_mb:unpack() do
        if key == "T" and press == 0 then
            local gameplay_world = gameplay_core.get_world()
            print(("current tick value of the gameplay world is: %d"):format(gameplay_world:now()))

            for e in gameplay_world.ecs:select "building:in eid:in solar_panel:in" do
                print(("solar panel %d efficiency: %f"):format(e.eid, e.solar_panel.efficiency))
                break
            end
        end

        if key == "S" and press == 0 then
            export_startup()
        end
    end
end

