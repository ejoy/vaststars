local type = require "register.type"
local prototype = require "prototype"
local iHub = require "interface.hub"

local InvalidChest <const> = 0

local c = type "hub"
    .supply_area "size"

function c:ctor(init, pt)
    local world = self
    local e = {
        hub = {
            id = 0,
            chest = InvalidChest
        }
    }
    if init.item then
        local id = assert(prototype.queryByName(init.item), "Invalid item: " .. init.item).id
        iHub.set_item(world, e, id)
    end
    for _ = 1, pt.drone_count do
        world:create_entity(pt.drone_entity) {
            x = init.x,
            y = init.y,
        }
    end
    return e
end
