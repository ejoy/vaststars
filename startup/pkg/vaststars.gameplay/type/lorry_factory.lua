local type = require "register.type"
local prototype = require "prototype"

local c = type "lorry_factory"
    .endpoint "position"
    .road "network"

function c:ctor(init, pt)
    local world = self
    local typeobject = prototype.queryByName(pt.item)
    local items = {
        world:chest_slot {
            type = "red",
            item = typeobject.id,
            amount = 0,
            limit = typeobject.stack,
        }
    }

    return {
        lorry_factory = true,
        chest = {
            chest = world:container_create(table.concat(items)),
        },
        endpoint = {
            neighbor = 0xffff,
            rev_neighbor = 0xffff,
            lorry = 0,
        },
    }
end
