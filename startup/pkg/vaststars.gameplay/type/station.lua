local type = require "register.type"
local prototype = require "prototype"

local iendpoint = require "interface.endpoint"
local c = type "station"
    .station_type "station_type"
    .chest_type "chest_type"
    .weights "integer"

function c:ctor(init, pt)
    local world = self

    local res = {
        station = {
            endpoint = iendpoint.endpoint_id(world, init, pt),
            weights = pt.weights,
            lorry = 0,
        }
    }

    local item = 0
    if init.item then
        item = assert(prototype.queryByName(init.item), "Invalid item: " .. init.item).id
    end

    local c = {}
    c[#c+1] = world:chest_slot {
        type = pt.chest_type,
        item = item,
        amount = 0,
        limit = 1,
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
