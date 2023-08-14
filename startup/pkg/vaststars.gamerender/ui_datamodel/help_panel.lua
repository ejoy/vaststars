local ecs, mailbox= ...
local world = ecs.world

local help_info = import_package "vaststars.prototype"("help")
local iui = ecs.require "engine.system.ui_system"

local M = {}

function M:create()
    iui.register_leave("ui/help_panel.rml")
    return {
        helps = help_info,
    }
end

return M