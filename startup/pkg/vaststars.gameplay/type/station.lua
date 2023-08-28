local type = require "register.type"
local prototype = require "prototype"
local iStation = require "interface.station"

local InvalidChest <const> = 0

local c = type "station"
    .endpoint "position"
    .road "network"
    .supply_max "integer"
    .demand_max "integer"

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
    if init.items then
        local items = {}
        for i, v in ipairs(init.items) do
            local id = assert(prototype.queryByName(v[2]), "Invalid item: " .. v[2]).id
            items[i] = { v[1], id, v[3] }
        end
        iStation.set_item(world, e, items)
    end
    return e
end
