local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local create_event_handler = require "ui_datamodel.common.event_handler"

local event_handler = create_event_handler(
    mailbox,
    {
        "rotate",
        "quit",
        "build",
    },
    function(event)
        iui.redirect("construct.rml", event)
    end
)

---------------
local M = {}

function M:create(show_rotate)
    return {
        show_rotate  = show_rotate,
        show_quit  = true,
        show_confirm = true,
    }
end

function M:stage_ui_update(datamodel)
    event_handler()
end

return M