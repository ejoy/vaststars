local type = require "register.type"
local c = type "lorry_factory"
    .endpoint "position"

function c:ctor(init, pt)
    return {
        lorry_factory = true,
        endpoint = {
            neighbor = 0xffff,
            rev_neighbor = 0xffff,
            lorry = 0,
        }
    }
end
