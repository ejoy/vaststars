local type = require "register.type"
local iendpoint = require "interface.endpoint"

local c1 = type "solar_panel"
function c1:ctor(init, pt)
    return {
        solar_panel = true
    }
end

local c2 = type "base"
function c2:ctor(init, pt)
    local world = self
    local chest = {}
    for _, v in ipairs(init.items or {}) do
        chest[#chest+1] = world:chest_slot {
            type = "blue",
            item = v[1],
            amount = v[2],
            limit = v[2],
        }
    end

    local endpoint = iendpoint.create(world, init, pt)
    local asize = #chest
    local index = world:container_create(endpoint, table.concat(chest), asize)

    return {
        base = true,
        manual = {
            recipe = 0,
            speed = 100,
            status = 0,
            progress = 0,
        },
        chest = {
            endpoint = endpoint,
            index = index,
            asize = asize,
            fluidbox_in = 0,
            fluidbox_out = 0,
        },
    }
end
