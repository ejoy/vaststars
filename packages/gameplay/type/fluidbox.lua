local type = require "register.type"

local c = type "fluidboxes"

function c:ctor(init, pt)
    assert(#pt.fluidboxes.input <= 4)
    assert(#pt.fluidboxes.output <= 3)
    return {
        fluidboxes = {
            in_count = #pt.fluidboxes.input,
            out_count = #pt.fluidboxes.output,
            in1 = 0,
            in2 = 0,
            in3 = 0,
            in4 = 0,
            out1 = 0,
            out2 = 0,
            out3 = 0,
        }
    }
end
