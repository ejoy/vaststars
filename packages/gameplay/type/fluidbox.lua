local type = require "register.type"
local prototype = require "prototype"

local function fluidId(name)
    local what = prototype.query("fluid", name)
    if what then
        return what.id
    end
    return 0
end

local fbs = type "fluidboxes"
    .fluidboxes "fluidbox"

function fbs:ctor(init, pt)
    assert(#pt.fluidboxes.input <= 4)
    assert(#pt.fluidboxes.output <= 3)
    local r = { fluidboxes={}, init_fluidbox={} }
    for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
        local what, i = classify:match "(%a*)(%d)"
        what = what.."put"
        i = tonumber(i)
        if init.fluids and init.fluids[what] and init.fluids[what][i] then
            local v = init.fluids[what][i]
            r.fluidboxes[classify.."_fluid"] = fluidId(v[1])
            r.init_fluidbox[classify] = v[2]
        else
            r.fluidboxes[classify.."_fluid"] = 0
        end
        r.fluidboxes[classify.."_id"] = 0
    end
    return r
end

local fb = type "fluidbox"
    .fluidbox "fluidbox"

function fb:ctor(init, pt)
    if not init.fluid or not init.fluid[1] then
        return {
            fluidbox = { fluid = 0, id = 0 }
        }
    end
    return {
        fluidbox = {
            fluid = fluidId(init.fluid[1]),
            id = 0,
        },
        init_fluidbox = init.fluid[2]
    }
end

local pg = type "pipe-to-ground"
    .max_distance "number"

function pg:ctor(init, pt)
    return {}
end
