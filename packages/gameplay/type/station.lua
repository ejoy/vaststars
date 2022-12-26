local type = require "register.type"
local iendpoint = require "interface.endpoint"

local c = type "station"

function c:ctor(init, pt)
    local world = self

    return {
        endpoint_changed = true,
        station = {
            endpoint = iendpoint.create(world, init, pt),
        }
    }
end
