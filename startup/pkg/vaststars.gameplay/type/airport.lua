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
        if init.items[1] == nil or init.items[1] == "" then
        else
            local item_prototype = assert(prototype.queryByName(init.items[1]), "Invalid item: " .. init.items[1])
            e.airport.item = item_prototype.id
        end
    elseif init.item == nil then
    else
        local item_prototype = assert(prototype.queryByName(init.item), "Invalid item: " .. init.item)
        e.airport.item = item_prototype.id
    end
    return e
end
