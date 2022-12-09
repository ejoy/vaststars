local prototype = require "prototype"
local type = require "register.type"

local c = type "chest"
    .chest_type "chest_type"
    .slots "number"

function c:ctor(init, pt)
    local world = self
    local asize = 0
    local index = world:container_create(0xffff, "", 0)
    return {
        endpoint_changed = true,
        chest = {
            endpoint = 0xffff,
            index = index,
            asize = asize,
            fluidbox_in = 0,
            fluidbox_out = 0,
        }
    }
end
