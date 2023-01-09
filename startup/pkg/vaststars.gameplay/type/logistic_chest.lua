local type = require "register.type"

local c = type "logistic_chest"

function c:ctor(init, pt)
    return {
        logistic_chest = {
            head_index = init.head_index or 0xffff,
            index = 0xffff,
        }
    }
end
