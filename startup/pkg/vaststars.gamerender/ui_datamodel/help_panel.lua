local ecs, mailbox= ...
local world = ecs.world
local help_info = import_package "vaststars.prototype"("help")
local M = {}

function M:create(object_id)
    return {
        helps = help_info,
    }
end

function M:stage_ui_update(datamodel)

end

return M