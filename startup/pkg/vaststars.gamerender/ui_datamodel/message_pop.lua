local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local global = require "global"
local M = {}

function M:create(content)
    return {
        left = content and content.left or "0vmin",
        top = content and content.top or "0vmin",
    }
end

function M:stage_ui_update(datamodel)
end

return M