local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"

return function(gameplay_world)
    for e in gameplay_world.ecs:select "inventory_changed:in inventory:in eid:in" do
        iui.call_datamodel_method("construct.rml", "update_construct_menu")
    end
    gameplay_world.ecs:clear "inventory_changed"
    return false
end