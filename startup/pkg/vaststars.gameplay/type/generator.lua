local type = require "register.type"

local c1 = type "solar_panel"
function c1:ctor(init, pt)
    return {
        solar_panel = {
            efficiency = 0,
        }
    }
end

local c2 = type "wind_turbine"
function c2:ctor(init, pt)
    return {
        wind_turbine = true
    }
end

local c3 = type "base"
function c3:ctor(init, pt)
    return {
        base = true,
    }
end
