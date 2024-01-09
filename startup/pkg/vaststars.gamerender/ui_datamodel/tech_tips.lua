local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local close_mb = mailbox:sub {"close"}
local iguide = require "gameplay.interface.guide"
local iui = ecs.require "engine.system.ui_system"

local M = {}

function M.create(content)
    iguide.set_running(false)
    return {
        message = content.message or "none",
        items = content.items or {},
        left = content.left,
        top = content.top,
    }
end

function M.update(datamodel)
    for _ in close_mb:unpack() do
        iguide.set_running(true)
        iui.close("/pkg/vaststars.resources/ui/tech_tips.html")
    end
end

return M