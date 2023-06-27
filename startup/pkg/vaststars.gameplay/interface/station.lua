local iBuilding = require "interface.building"
local iChest = require "interface.chest"

local m = {}

function m.set_item(world, e, item)
    iChest.station_set(world, e, item)
end

function m.set_weights(world, e, v)
    if e.station_producer.weights ~= v then
        e.station_producer.weights = v
        iBuilding.dirty(world, "station_producer")
    end
end

function m.set_maxlorry(world, e, v)
    if e.station_consumer.maxlorry ~= v then
        e.station_consumer.maxlorry = v
        iBuilding.dirty(world, "station_consumer")
    end
end

return m
