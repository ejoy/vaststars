local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.require "engine.system.ui_system"
local gameplay_core = require "gameplay.core"
local backpack_sys = ecs.system "backpack_system"

function backpack_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    for _ in gameplay_world.ecs:select "backpack_changed:in" do
        iui.call_datamodel_method("/pkg/vaststars.resources/ui/backpack.rml", "update_backpack")
    end
end