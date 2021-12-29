local type = require "register.type"

local c = type "fluidboxes"

function c:ctor(init, pt)
    assert(#pt.fluidboxes.input <= 4)
    assert(#pt.fluidboxes.output <= 3)
    return {
        fluidboxes = {
            in1_fluid = 0,
            in1_id = 0,
            in2_fluid = 0,
            in2_id = 0,
            in3_fluid = 0,
            in3_id = 0,
            in4_fluid = 0,
            in4_id = 0,
            out1_fluid = 0,
            out1_id = 0,
            out2_fluid = 0,
            out2_id = 0,
            out3_fluid = 0,
            out3_id = 0,
        }
    }
end
