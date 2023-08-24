local type = require "register.type"
local prototype = require "prototype"
local iStation = require "interface.station"

local InvalidChest <const> = 0

local c = type "station_producer"
    .weights "integer"
    .endpoint "position"
    .road "network"

function c:ctor(init, pt)
    local world = self
    local e = {
        chest = {
            chest = InvalidChest,
        },
        station = {
            chest = InvalidChest,
        },
        endpoint = {
            neighbor = 0xffff,
            rev_neighbor = 0xffff,
        }
    }
    if init.item then
        local id = assert(prototype.queryByName(init.item), "Invalid item: " .. init.item).id
        iStation.set_item(world, e, {{ "supply", id, 1 }})
    end
    return e
end
