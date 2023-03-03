local type = require "register.type"
local prototype = require "prototype"

local c = type "hub"
    .supply_area "size"

function c:ctor(init, pt)
    local world = self

    local c = {}
    c[#c+1] = world:chest_slot {
        type = "blue",
        item = prototype.queryByName(init.name).id,
        limit = init.stack,
    }
    local chest = world:container_create(table.concat(c))

    return {
        hub = {
            chest = chest
        }
    }
end
