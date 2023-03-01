local type = require "register.type"
local prototype = require "prototype"

local c = type "hub"

function c:ctor(init, pt)
    local world = self

    local c = {}
    c[#c+1] = world:chest_slot {
        type = "blue",
        item = prototype.queryByName("item", init.name).id,
        limit = init.stack,
    }
    local chest = world:container_create(1)
    world:container_reset(chest, table.concat(c))

    return {
        hub = {
            chest = chest
        }
    }
end
