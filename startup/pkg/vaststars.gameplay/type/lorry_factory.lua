local type = require "register.type"
local c = type "lorry_factory"

function c:ctor(init, pt)
    return {
        lorry_factory = {
            endpoint = 0xffff,
        }
    }
end
