local type = require "register.type"
local prototype = require "prototype"

local c = type "airport"
    .supply_area "size"

function c:ctor(init, pt)
    local world = self
    local e = {
        airport = {
            id = 0,
            item = 0,
        }
    }
    for _, name in ipairs(pt.drone) do
        world:create_entity(name) {
            x = init.x,
            y = init.y,
        }
    end
    if init.items ~= nil then
        local name = init.items[1]
        if name ~= nil and name ~= "" then
            local item_prototype = assert(prototype.queryByName(name), "Invalid item: " .. name)
            e.airport.item = item_prototype.id
        end
    end
    return e
end
