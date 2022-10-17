local type = require "register.type"

local c = type "station"

function c:ctor(init, pt)
    return {
        endpoint_changed = true,
        station = {
            endpoint = 0 --TODO
        }
    }
end
