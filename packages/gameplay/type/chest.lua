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
    local id = world:container_create(table.concat(chest))
    if init.items then
        for _, item in pairs(init.items) do
            local what = prototype.queryByName("item", item[1])
            assert(pt, "unknown item: " .. item[1])
            self:container_place(id, what.id, item[2])
        end
    end
    return {
        chest = {
            endpoint = 0xffff,
            id = id,
            fluidbox_in = 0,
            fluidbox_out = 0,
        }
    }
end
