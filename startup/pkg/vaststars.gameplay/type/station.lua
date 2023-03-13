local type = require "register.type"
local iendpoint = require "interface.endpoint"
local c = type "station"

function c:ctor(init, pt)
    local world = self

    return {
        station = {
            endpoint = iendpoint.create(world, init, pt, "station"),
        },
    }
end
