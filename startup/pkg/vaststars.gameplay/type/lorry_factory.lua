local type = require "register.type"
local c = type "lorry_factory"
local iendpoint = require "interface.endpoint"

function c:ctor(init, pt)
    local world = self

    return {
        lorry_factory = {
            endpoint = iendpoint.endpoint_id(world, init, pt),
        }
    }
end
