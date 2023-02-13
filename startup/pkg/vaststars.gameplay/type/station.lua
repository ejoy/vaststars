local type = require "register.type"
local iendpoint = require "interface.endpoint"
local c = type "station"
local prototype = require "prototype"
local MAX_LORRY_COUNT <const> = 8
local INVALID_LORRY_ID <const> = 0xffff

function c:ctor(init, pt)
    local world = self

    local station = {
        endpoint = iendpoint.create(world, init, pt, "station"),
        count = 0,
    }
    local park = {
        endpoint = iendpoint.create(world, init, pt, "park"),
        count = #pt.lorry,
    }
    for i = 1, MAX_LORRY_COUNT do
        station["lorry" .. i] = INVALID_LORRY_ID
        park["lorry" .. i] = INVALID_LORRY_ID
    end
    for index, v in ipairs(pt.lorry) do
        local lpt = prototype.queryByName("entity", v)
        park["lorry" .. index] = world:roadnet_create_lorry(lpt.id)
    end

    return {
        station = station,
        park = park,
    }
end
