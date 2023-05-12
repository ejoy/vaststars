local M = {}

function M:create(icon, name)
    return {
        icon = icon,
        prototype_name = name,
    }
end

return M