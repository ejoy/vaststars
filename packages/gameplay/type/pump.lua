local type = require "register.type"

local c = type "pump"

function c:ctor(init, pt)
    return {
        pump = true
    }
end
