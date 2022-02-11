local type = require "register.type"
local prototype = require "prototype"

local fbs = type "fluidboxes"
    .fluidboxes "fluidbox"

function fbs:ctor(init, pt)
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

local fb = type "fluidbox"
    .fluidbox "fluidbox"

function fb:ctor(init, pt)
    if not init.fluid or not init.fluid[1] then
        return {
            fluidbox = { fluid = 0, id = 0 }
        }
    end
    local what = prototype.query("fluid", init.fluid[1])
    if not what then
        return {
            fluidbox = { fluid = 0, id = 0 }
        }
    end
    return {
        fluidbox = {
            fluid = what.id,
            id = 0,
        },
        fluidbox_build = {
            volume = init.fluid[2]
        }
    }
end

local pg = type "pipe-to-ground"
    .max_distance "number"

function pg:ctor(init, pt)
    return {}
end
