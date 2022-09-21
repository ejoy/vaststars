local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local global = require "global"
local tech_finish_pop_close_mb = mailbox:sub {"tech_finish_pop_close"}
local M = {}

function M:create(content)
    return {
        show_id = content.id or "message",
        message = content.message or "none",
        items = content.items or {},
        left = content.left,
        top = content.top,
    }
end

function M:stage_ui_update(datamodel)
    for _ in tech_finish_pop_close_mb:unpack() do
        global.tech_finish_pop = false
    end
end

return M