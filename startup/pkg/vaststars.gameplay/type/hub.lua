local type = require "register.type"
local c = type "hub"

function c:ctor(init, pt)
    local world = self
    return {
        hub = {
            chest = world:container_create(0),
        }
    }
end
