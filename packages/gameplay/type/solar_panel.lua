local type = require "register.type"

local c = type "solar_panel"

function c:ctor(init, pt)
    return {
        solar_panel = true
    }
end
