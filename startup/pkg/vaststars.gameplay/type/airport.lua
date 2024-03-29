local type = require "register.type"
local prototype = require "prototype"

local c = type "airport"
    .supply_area "size"

function c:ctor(init, pt)
    local world = self
    local e = {
        airport = {
            id = 0,
        }
    }
    for _, name in ipairs(pt.drone) do
        world:create_entity(name) {
            x = init.x,
            y = init.y,
        }
    end
    return e
end
