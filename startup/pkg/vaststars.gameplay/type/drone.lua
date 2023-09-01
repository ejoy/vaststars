local type = require "register.type"

local c = type "drone"
    .cost "energy"

function c:ctor(init, pt)
    local home = (init.x << 8) | init.y
    return {
        drone = {
            prototype = pt.id,
            home = home,
            prev_x = 0,
            prev_y = 0,
            prev_slot = 0,
            next_x = 0,
            next_y = 0,
            next_slot = 0,
            mov2_x = 0,
            mov2_y = 0,
            mov2_slot = 0,
            maxprogress = 0,
            progress = 0,
            item = 0,
            status = 0,
        }
    }
end
