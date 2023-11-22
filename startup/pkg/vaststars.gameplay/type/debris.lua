local type = require "register.type"

local c = type "debris"

function c:ctor(init, pt)
    return {
        debris = true,
    }
end
