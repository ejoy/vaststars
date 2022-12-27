local type = require "register.type"
local iendpoint = require "interface.endpoint"

local c = type "chest"
    .chest_type "chest_type"

function c:ctor(init, pt)
    local world = self
    local chest = {}
    for _, v in ipairs(init.items or {}) do
        chest[#chest+1] = world:chest_slot {
            type = pt.chest_type,
            item = v[1],
            amount = v[2],
        }
    end

    local endpoint = iendpoint.create(world, init, pt)
    local asize = #chest
    local index = world:container_create(endpoint, table.concat(chest), asize)

    return {
        chest = {
            endpoint = endpoint,
            index = index,
            asize = asize,
            fluidbox_in = 0,
            fluidbox_out = 0,
        }
    }
end
