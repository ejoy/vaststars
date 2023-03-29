local type = require "register.type"
local prototype = require "prototype"

local c = type "drone"

function c:ctor(init, pt)
    local world = self

    return {
        drone = {
            prev = ((init.y & 0x1ff) << 9) | (init.x & 0x1ff),
            next = 0,
            mov2 = 0,
            home = ((init.sumOfYCoord & 0x1FF) << 14) | ((init.sumOfXCoord & 0x1FF) << 23), -- local x, y = ((home >> 23) & 0x1FF) // 2, ((home >> 14) & 0x1FF) // 2
            classid = pt.id,
            maxprogress = 0,
            progress = 0,
            item = 0,
            status = 0,
        }
    }
end
