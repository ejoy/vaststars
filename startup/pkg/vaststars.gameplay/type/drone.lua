local type = require "register.type"

local c = type "drone"

function c:ctor(init, pt)
    local home = (init.slot << 16) | (init.x << 8) | init.y
    return {
        drone = {
            prototype = pt.id,
            home = home,
            prev = 0,
            next = 0,
            mov2 = 0,
            maxprogress = 0,
            progress = 0,
            item = 0,
            status = 0,
        }
    }
end
