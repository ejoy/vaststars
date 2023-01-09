local ecs = ...
local M = {}
function M:create(text)
    return {
        main_text = text[1],
        sub_text = text[2],
    }
end

function M:stage_ui_update(datamodel)

end

return M