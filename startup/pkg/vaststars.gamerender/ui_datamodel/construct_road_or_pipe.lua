local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local create_event_handler = require "ui_datamodel.common.event_handler"

---------------
local M = {}

local event_handler = create_event_handler(
    mailbox,
    {
        "start_laying",
        "finish_laying",
        "start_teardown",
        "finish_teardown",
        "cancel",
        "place_one",
        "remove_one",
        "quit",
    },
    function(event)
        iui.redirect("construct.rml", event)
    end
)

function M:create()
    local datamodel = {
        show_start_laying = false,
        show_finish_laying = false,
        show_start_teardown = false,
        show_finish_teardown = false,
        show_cancel = false,
        show_place_one = false,
        show_remove_one = false,
    }

    return datamodel
end

function M:stage_ui_update(datamodel)
    event_handler()
end

return M