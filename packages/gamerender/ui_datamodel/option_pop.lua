---------------
local M = {}

function M:create(archival_files)
    return {
        archival_files = archival_files,
    }
end

return M