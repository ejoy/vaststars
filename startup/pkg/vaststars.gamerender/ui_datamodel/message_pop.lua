local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local M = {}

function M.create(content)
    return {
        left = content and content.left or "0vmin",
        top = content and content.top or "0vmin",
    }
end

return M