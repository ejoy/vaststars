local ecs = ...
local world = ecs.world

local MESSAGES = import_package "vaststars.prototype"("messages")
local iui = ecs.require "engine.system.ui_system"

local function show_message(tip, ...)
    local v = MESSAGES[tip] or error("No message for tip: " .. tip)
    iui.send("/pkg/vaststars.resources/ui/message_pop.html", "message", {message = string.format(v.text, ...)})
end
return show_message