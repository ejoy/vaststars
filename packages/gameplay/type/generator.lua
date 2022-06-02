local type = require "register.type"

local c1 = type "solar_panel"
function c1:ctor(init, pt)
    return {
        solar_panel = true
    }
end

local c2 = type "base"
function c2:ctor(init, pt)
    return {
        base = true
    }
end
