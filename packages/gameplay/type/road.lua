local type = require "register.type"

local c = type "road"

function c:ctor(init, pt)
    return {
        road = true,
        road_changed = true,
    }
end
