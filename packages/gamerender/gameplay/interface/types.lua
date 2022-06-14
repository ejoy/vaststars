local UPS <const> = 50

local M = {}

function M.time(n)
    return ("%ss"):format(n // UPS)
end

return M