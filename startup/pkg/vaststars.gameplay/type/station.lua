local type = require "register.type"
local iendpoint = require "interface.endpoint"
local c = type "station"
local LORRY_CAPACITY <const> = 8
local INVALID_LORRY_ID <const> = 0xffff

function c:ctor(init, pt)
    local world = self
    local station = {
        endpoint = iendpoint.create(world, init, pt, "station"),
    }

    station["lorry1"] = world:roadnet_create_lorry()
    for i = 2, LORRY_CAPACITY do
        station["lorry" .. i] = INVALID_LORRY_ID
    end

    return {
        station = station,
    }
end
