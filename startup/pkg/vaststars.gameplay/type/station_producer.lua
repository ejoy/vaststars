local type = require "register.type"
local prototype = require "prototype"
local iChest = require "interface.chest"

local c = type "station_producer"
    .weights "integer"
    .endpoint "position"
    .road "network"

function c:ctor(init, pt)
    local world = self
    local item = 0
    local stack = 0
    if init.item then
        local typeobject = assert(prototype.queryByName(init.item), "Invalid item: " .. init.item)
        item = typeobject.id
        stack = typeobject.stack
    end
    local chest = iChest.create(world, {{
        type = "blue",
        item = item,
        amount = 0,
        limit = stack,
    }})
    return {
        chest = {
            chest = chest,
        },
        station_producer = {
            weights = pt.weights,
        },
        endpoint = {
            neighbor = 0xffff,
            rev_neighbor = 0xffff,
            lorry = 0,
        }
    }
end
