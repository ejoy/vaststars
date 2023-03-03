local type = require "register.type"
local prototype = require "prototype"

local c = type "drone"

function c:ctor(init, pt)
    local world = self

    return {
        drone = {
            prev = 0,
            next = 0,
            mov2 = 0,
            home = ((init.sumOfYCoord & 0x1FF) << 14) | ((init.sumOfXCoord & 0x1FF) << 23),
            classid = pt.id,
            maxprogress = 0,
            progress = 0,
            item = 0,
            status = 0,
        }
    }
end
