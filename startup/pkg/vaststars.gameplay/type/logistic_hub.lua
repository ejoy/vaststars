local type = require "register.type"
local iendpoint = require "interface.endpoint"

local c = type "logistic_hub"

function c:ctor(init, pt)
    local world = self
    local endpoint = iendpoint.create(world, init, pt, "logistic_hub")
    return {
        chest = {
            endpoint = endpoint,
            chest = world:container_create(0),
            fluidbox_in = 0,
            fluidbox_out = 0,
            lorry = 0xffff,
        },
        logistic_hub = true,
    }
end
