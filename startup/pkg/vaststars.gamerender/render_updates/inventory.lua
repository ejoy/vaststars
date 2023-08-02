local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local gameplay_core = require "gameplay.core"
local inventory_sys = ecs.system "inventory_system"

function inventory_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    for _ in gameplay_world.ecs:select "base_changed:in" do
        iui.call_datamodel_method("ui/inventory.rml", "update")
    end
end