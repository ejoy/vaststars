local type = require "register.type"
local iendpoint = require "interface.endpoint"
local prototype = require "prototype"
local c = type "station"
    .station_type "chest_type"
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

    assert(pt.station_type)
    local c = {}
    c[#c+1] = world:chest_slot {
        type = pt.station_type,
        item = prototype.queryByName("铁板").id, -- TODO: remove this hardcode
        amount = 100,
        limit = 10,
    }
    res.station.chest = world:container_create(table.concat(c))

    if pt.station_type == CHEST_TYPE.blue then
        res.station_consumer = true
    elseif pt.station_type == CHEST_TYPE.red then
        res.station_producer = true
    else
        assert(false)
    end

    return res
end
