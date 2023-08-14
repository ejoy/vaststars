local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local close_mb = mailbox:sub {"close"}
local iguide = require "gameplay.interface.guide"
local iui = ecs.require "engine.system.ui_system"

local M = {}

function M:create(content)
    iguide.set_running(false)
    return {
        message = content.message or "none",
        items = content.items or {},
        left = content.left,
        top = content.top,
    }
end

function M:stage_ui_update(datamodel)
    for _ in close_mb:unpack() do
        iguide.set_running(true)
        iui.close("ui/tech_tips.rml")
    end
end

return M