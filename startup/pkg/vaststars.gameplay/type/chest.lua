local type = require "register.type"
local iendpoint = require "interface.endpoint"

local c = type "chest"
    .chest_type "chest_type"

function c:ctor(init, pt)
    local world = self
    local items = {}
    for _, v in ipairs(init.items or {}) do
        items[#items+1] = world:chest_slot {
            type = pt.chest_type,
            item = v[1],
            amount = v[2],
        }
    end

    local endpoint = iendpoint.create(world, init, pt, "chest")
    local asize = #items
    local index = world:container_create(asize)
    local chest = {
        endpoint = endpoint,
        index = index,
        asize = asize,
        fluidbox_in = 0,
        fluidbox_out = 0,
        lorry = 0xffff,
    }
    world:container_reset(chest, table.concat(items))
    return {
        chest = chest
    }
end
