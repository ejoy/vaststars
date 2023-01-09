local UPS <const> = require("gameplay.interface.constant").UPS

local M = {}

function M.time(n)
    return ("%ss"):format(n // UPS)
end

function M.items(s)
    local r = {}
    for idx = 2, #s // 4 do
        local id, count = string.unpack("<I2I2", s, 4 * idx - 3)
        r[#r+1] = {id = id, count = count}
    end
    return r
end

-- return values between 0 and 1
function M.progress(progress, total)
    assert(progress <= total, ("progress must be less than total, %s - %s"):format(progress, total))
    progress = math.max(progress, 0)
    return (total - progress) / total -- the progress is decreasing from total to 0
end

function M.progress_str(progress, total)
    return ("%0.0f%%"):format(M.progress(progress, total) * 100)
end

return M