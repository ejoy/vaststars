local type = require "register.type"

local c = type "inner_building"

function c:ctor(init, pt)
    return {
        inner_building = true,
    }
end