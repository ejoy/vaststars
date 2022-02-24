local vector2 = require "vector2"

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
function m.rotate(dir, t)
    return DIRECTION_REV[(DIRECTION[dir] + t) % 4]
end

do
    local offset <const> = {
        N = vector2.UP,
        S = vector2.DOWN,
        W = vector2.RIGHT,
        E = vector2.LEFT,
    }

    function m.offset_of_entry(dir)
        return offset[dir]
    end
end

return m