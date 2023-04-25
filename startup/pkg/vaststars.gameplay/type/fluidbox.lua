local type = require "register.type"
local prototype = require "prototype"

local function fluidId(name)
    local what = prototype.queryByName(name)
    if what then
        return what.id
    end
    return 0
end

local fbs = type "fluidboxes"
    .fluidboxes "fluidbox"

function fbs:ctor(init, pt)
    return {}
end

local fb = type "fluidbox"
    .fluidbox "fluidbox"

function fb:ctor(init, pt)
    if not init.fluid then
        return {
            fluidbox_changed = true,
            fluidbox = { fluid = 0, id = 0 }
        }
    end
    return {
        fluidbox_changed = true,
        fluidbox = {
            fluid = fluidId(init.fluid),
            id = 0,
        },
    }
end
