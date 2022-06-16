local UPS <const> = 50

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

return M