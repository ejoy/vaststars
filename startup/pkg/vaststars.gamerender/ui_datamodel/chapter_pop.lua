local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local M = {}
function M.create(text)
    return {
        main_text = text[1],
        sub_text = text[2],
    }
end

return M