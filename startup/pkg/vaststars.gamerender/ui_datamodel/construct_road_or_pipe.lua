local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local create_event_handler = require "ui_datamodel.common.event_handler"
local iprototype = require "gameplay.interface.prototype"
local click_main_button_mb = mailbox:sub {"click_main_button"}

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
    function(event, ...)
        iui.redirect("construct.rml", event, ...)
    end
)

function M:create(prototype_name, kv)
    local datamodel = {
        is_concise_mode = false,
        show_start_laying = false,
        show_finish_laying = false,
        show_remove_one = false,
        show_start_teardown = false,
        show_finish_teardown = false,
        main_button_icon = iprototype.queryByName(prototype_name).icon,
    }

    for k, v in pairs(kv) do
        datamodel[k] = v
    end

    return datamodel
end

function M:stage_ui_update(datamodel, prototype_name)
    event_handler(prototype_name)

    for _ in click_main_button_mb:unpack() do
        if datamodel.show_finish_laying then
            iui.redirect("construct.rml", "finish_laying")
        elseif datamodel.show_finish_teardown then
            iui.redirect("construct.rml", "finish_teardown")
        end
    end
end

return M