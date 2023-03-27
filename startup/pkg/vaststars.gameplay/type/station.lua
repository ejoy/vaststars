local type = require "register.type"
local iendpoint = require "interface.endpoint"
local c = type "station"
    .station_type "station_type"
    .chest_type "chest_type"
    .weights "count"

local CHEST_TYPE <const> = {
    [0] = 0,
    [1] = 1,
    [2] = 2,
    [3] = 3,
    red = 0,
    blue = 1,
    green = 2,
    none = 3,
}

function c:ctor(init, pt)
    local world = self

    local res = {
        station = {
            endpoint = iendpoint.endpoint_id(world, init, pt, "station"),
            weights = pt.weights,
            lorry = 0,
        }
    }

    local c = {}
    c[#c+1] = world:chest_slot {
        type = pt.chest_type,
        item = 0,
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
