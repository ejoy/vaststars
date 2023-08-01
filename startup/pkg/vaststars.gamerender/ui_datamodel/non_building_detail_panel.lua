local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"

local M = {}

function M:create(icon, name)
    iui.register_leave("ui/non_building_detail_panel.rml")

    return {
        icon = icon,
        prototype_name = name,
    }
end

return M