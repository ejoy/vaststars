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
            home = init.sumOfXCoord & 0x1FF | (init.sumOfYCoord & 0x1FF) << 9,
            classid = 0,
            maxprogress = 0,
            progress = 0,
            item = 0,
            status = 0,
        }
    }
end
