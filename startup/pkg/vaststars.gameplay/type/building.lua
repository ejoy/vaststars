local type = require "register.type"

local DIRECTION <const> = {
    N = 0, North = 0,
    E = 1, East  = 1,
    S = 2, South = 2,
    W = 3, West  = 3,
}

local c = type "building"
    .area "size"

function c:ctor(init, pt)
    return {
        building = {
            x = init.x,
            y = init.y,
            prototype = pt.id,
            direction = init.dir and DIRECTION[init.dir] or 0,
        },
        building_new = true,
    }
end
