local type = require "register.type"

local c = type "pole"
    .supply_area "size"

function c:ctor(init, pt)
    return {
        pole = true
    }
end
