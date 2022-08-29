local type = require "register.type"

local c = type "road"

function c:ctor(init, pt)
    return {
        road = {
            road_type = 0,
            coord = 0,
        }
    }
end
