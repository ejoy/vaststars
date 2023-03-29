local type = require "register.type"
local prototype = require "prototype"

local c = type "drone"

function c:ctor(init, pt)
    local world = self
    -- local x, y = ((home >> 23) & 0x1FF) // 2, ((home >> 14) & 0x1FF) // 2
    local home = ((init.sumOfYCoord & 0x1FF) << 14) | ((init.sumOfXCoord & 0x1FF) << 23)

    return {
        drone = {
            prev = home,
            next = 0,
            mov2 = 0,
            home = home,
            classid = pt.id,
            maxprogress = 0,
            progress = 0,
            item = 0,
            status = 0,
        }
    }
end
