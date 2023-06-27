local type = require "register.type"

local c = type "road"
    .road "network"

function c:ctor(init, pt)
    return {
        road = true,
    }
end