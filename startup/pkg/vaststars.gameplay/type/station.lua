local type = require "register.type"
local iendpoint = require "interface.endpoint"

local c = type "station"

function c:ctor(init, pt)
    local world = self

    local endpoint = iendpoint.create(world, init, pt, "station")
    local l = world:roadnet_create_lorry()
    world:roadnet_place_lorry(endpoint, l)

    return {
        station = {
            endpoint = endpoint,
            lorry = 0xffff,
            lorry_count = 1,
        }
    }
end
