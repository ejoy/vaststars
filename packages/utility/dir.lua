--[[
                        North:(y + 1):(0, 1)
West:(x - 1):(-1, 0)                             East:(x + 1):(1, 0)
                        South:(y - 1):(0, -1)
--]]
local North <const> = 0
local East  <const> = 1
local South <const> = 2
local West  <const> = 3

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}

local DIRECTION_REV = {}
for dir, v in pairs(DIRECTION) do
    DIRECTION_REV[v] = dir
end

local m = {}
function m.rotate_cntclkws(dir, t)
    return DIRECTION_REV[(DIRECTION[dir] + t) % 4]
end

do
    local offset <const> = {
        N = {0, -1},
        S = {0,  1},
        W = {1, 0},
        E = {-1,  0},
    }

    function m.offset_of_entry(dir)
        return offset[dir]
    end
end

return m