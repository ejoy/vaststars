local ecs, mailbox = ...
local world = ecs.world
local w = world.w

---------------
local M = {}
function M:create(object_id, object_position, ui_x, ui_y)
    return {
        object_id = object_id,
        left = ui_x,
        top = ui_y,
        object_position = object_position,
    }
end

function M:stage_ui_update(datamodel)
end

return M