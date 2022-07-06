local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local M = {}

function M:create(content)
    return {
        show_id = content.id or 0,
        message = content.message or "none",
        item_icon = content.icon or "none",
        item_name = content.name or "none",
        item_count = content.count or 0
    }
end

function M:stage_ui_update(datamodel)

end

return M