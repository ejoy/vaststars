local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local global = require "global"
local M = {}

function M:create(content)
    return {
        show_id = content.show_id or "message",
        message = content.message or "none",
        items = content.items or {},
        left = content.left,
        top = content.top,
    }
end

function M:stage_ui_update(datamodel)
end

return M