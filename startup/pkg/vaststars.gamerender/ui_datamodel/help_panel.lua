local ecs, mailbox= ...
local world = ecs.world

local guide_on_going_mb = mailbox:sub {"guide_on_going"}
local help_info = import_package "vaststars.prototype"("help")
local iui = ecs.import.interface "vaststars.gamerender|iui"

local M = {}

function M:create(object_id)
    return {
        helps = help_info,
    }
end

function M:stage_ui_update(datamodel)
    for _ in guide_on_going_mb:unpack() do
        iui.close("help_panel.rml")
    end
end

return M