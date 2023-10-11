local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.require "engine.system.ui_system"
local create_event_handler = require "ui_datamodel.common.event_handler"

local event_handler = create_event_handler(
    mailbox,
    {
        "rotate",
        "quit",
        "build",
    },
    function(event)
        iui.redirect("/pkg/vaststars.resources/ui/construct.rml", event)
    end
)

---------------
local M = {}

function M.create(show_rotate)
    return {
        show_rotate  = show_rotate,
        show_quit  = true,
        show_confirm = true,
    }
end

function M.update(datamodel)
    event_handler()
end

return M