local type = require "register.type"

local DIRECTION <const> = {
    N = 0, North = 0,
    E = 1, East  = 1,
    S = 2, South = 2,
    W = 3, West  = 3,
}

local c = type "entity"
    .area "size"

function c:ctor(init, pt)
    return {
        entity = {
            x = init.x,
            y = init.y,
            prototype = pt.id,
            direction = init.dir and DIRECTION[init.dir] or 0,
        }
    }
end
