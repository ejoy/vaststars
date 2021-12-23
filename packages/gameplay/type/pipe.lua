local type = require "register.type"

local pi = type "pipe"

function pi:ctor(init, pt)
    return {
        pipe = init.fluid,
    }
end

local pg = type "pipe-to-ground"
    .max_distance "number"

function pg:ctor(init, pt)
    return {}
end

local st = type "storage-tank"
    .fluidbox "fluidbox"

function st:ctor(init, pt)
    return {}
end
