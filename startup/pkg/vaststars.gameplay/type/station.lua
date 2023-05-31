local type = require "register.type"
local prototype = require "prototype"

local c = type "station"
    .station_type "station_type"
    .chest_type "chest_type"
    .weights "integer"

function c:ctor(init, pt)
    local world = self

    local res = {
        station = {
            endpoint = 0xffff,
            weights = pt.weights,
            lorry = 0,
        }
    }

    local item = 0
    local stack = 0
    if init.item then
        local typeobject = assert(prototype.queryByName(init.item), "Invalid item: " .. init.item)
        item = typeobject.id
        stack = typeobject.stack
    end

    local c = {}
    c[#c+1] = world:chest_slot {
        type = pt.chest_type,
        item = item,
        amount = 0,
        limit = stack,
    }
    res.station.chest = world:container_create(table.concat(c))
    res[pt.station_type] = true

    res.chest = {
        chest = res.station.chest,
        fluidbox_in = 0,
        fluidbox_out = 0,
    }
    return res
end
