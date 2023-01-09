local type = require "register.type"

local c = type "mining"
    .mining_area "size"
    .speed "percentage"

function c:ctor(init, pt)
    return {
        mining = true
    }
end
