local ecs = ...
local world = ecs.world

local MESSAGES = import_package "vaststars.prototype"("messages")
local iRmlUi = ecs.require "ant.rmlui|rmlui_system"

local window
local function show_message(tip, ...)
    local v = MESSAGES[tip] or error("No message for tip: " .. tip)
    local url = "/pkg/vaststars.resources/ui/message_pop.html"

    if window then
        window.close()
    end
    window = iRmlUi.open(url, url, {type = "message", message = string.format(v.text, ...)})
end

local function show_items_mesage(x, y, items)
    local url = "/pkg/vaststars.resources/ui/message_pop.html"

    if window then
        window.close()
    end
    window = iRmlUi.open(url, url, {type = "item", action = "down", left = x, top = y, items = items})
end

return {
    show_message = show_message,
    show_items_mesage = show_items_mesage,
}