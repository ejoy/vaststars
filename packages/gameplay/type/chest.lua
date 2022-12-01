local prototype = require "prototype"
local type = require "register.type"

local c = type "chest"
    .chest_type "chest_type"
    .slots "number"

function c:ctor(init, pt)
    local world = self
    local chest = {}
    for _ = 1, pt.slots do
        chest[#chest+1] = world:chest_slot {
            type = pt.chest_type,
        }
    end
    local asize = #chest
    local index = world:container_create(asize, table.concat(chest))
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
