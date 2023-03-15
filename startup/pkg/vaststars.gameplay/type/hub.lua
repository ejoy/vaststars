local type = require "register.type"
local prototype = require "prototype"

local c = type "hub"
    .supply_area "size"

function c:ctor(init, pt)
    local world = self
    local chest
    local c = {}
    if init.item then
        c[#c+1] = world:chest_slot {
            type = "blue",
            item = prototype.queryByName(init.item).id,
            limit = init.stack,
        }
    else
        c[#c+1] = world:chest_slot {
            type = "blue",
            item = 0,
            limit = 0,
        }
    end
    chest = world:container_create(table.concat(c))

    return {
        hub = {
            chest = chest
        }
    }
end
