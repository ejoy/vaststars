local ecs, mailbox= ...
local world = ecs.world

local help_info = import_package "vaststars.prototype"("help")
local iui = ecs.import.interface "vaststars.gamerender|iui"

local M = {}

function M:create()
    iui.register_leave("help_panel.rml")
    return {
        helps = help_info,
    }
end

return M