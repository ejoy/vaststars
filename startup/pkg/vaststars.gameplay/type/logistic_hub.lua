local type = require "register.type"
local iendpoint = require "interface.endpoint"

local c = type "logistic_hub"

function c:ctor(init, pt)
    local world = self

    local chest = {}
    local endpoint = iendpoint.create(world, init, pt, "logistic_hub")
    local asize = #chest
    local index = world:container_create(endpoint, table.concat(chest), asize)

    return {
        chest = {
            endpoint = endpoint,
            index = index,
            asize = asize,
            fluidbox_in = 0,
            fluidbox_out = 0,
            lorry = 0xffff,
        },
        logistic_hub = true,
    }
end
