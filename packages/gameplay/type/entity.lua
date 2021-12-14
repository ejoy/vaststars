local type = require "base.register.type"
local component = require "base.register.component"

local DIRECTION <const> = {
    N = 0, North = 0,
    E = 1, East  = 1,
    S = 2, South = 2,
    W = 3, West  = 3,
}

component "entity" {
    "position:word",
    "prototype:word",
    "direction:byte",	-- 0:North 1:East 2:South 3:West
}

local c = type "entity"
    .area "size"

function c:ctor(init, pt)
    local pos = init.y << 8 | init.x
    return {
        entity = {
            position = pos,
            prototype = pt.id,
            direction = init.dir and DIRECTION[init.dir] or 0,
        }
    }
end
