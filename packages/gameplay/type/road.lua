local type = require "register.type"

local c = type "road"

function c:ctor(init, pt)
    return {
        road = {
            road_type = assert(init.road_type),
            coord = 0,
        }
    }
end
