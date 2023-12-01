local type = require "register.type"
local prototype = require "prototype"
local iChest = require "interface.chest"

local c = type "factory"
    .starting "position"
    .road "network"
    .check_pos "position"
    .check_area "size"

function c:ctor(init, pt)
    local world = self
    local typeobject = prototype.queryByName(pt.item)
    local chest = iChest.create(world, {{
        type = "supply",
        item = typeobject.id,
        amount = init.amount,
        limit = typeobject.station_limit,
    }})
    return {
        factory = true,
        chest = {
            chest = chest,
        },
        starting = {
            neighbor = 0xffff,
        },
    }
end
