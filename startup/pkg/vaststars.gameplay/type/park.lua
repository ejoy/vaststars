local type = require "register.type"

local c = type "park"
    .endpoint "position"
    .road "network"

function c:ctor(init, pt)
    local e = {
        park = true,
        endpoint = {
            neighbor = 0xffff,
            rev_neighbor = 0xffff,
        }
    }
    return e
end
