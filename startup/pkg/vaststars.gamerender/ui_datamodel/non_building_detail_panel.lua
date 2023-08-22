local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.require "engine.system.ui_system"

local M = {}

function M:create(icon, name)
    iui.register_leave("/pkg/vaststars.resources/ui/non_building_detail_panel.rml")

    return {
        icon = icon,
        prototype_name = name,
    }
end

return M