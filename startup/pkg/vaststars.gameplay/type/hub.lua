local type = require "register.type"
local prototype = require "prototype"

local c = type "hub"
    .supply_area "size"

function c:ctor(init, pt)
    local world = self

    local chest
    local c = {}
    if init.item then
        local typeobject = prototype.queryByName(init.item)
        assert(typeobject and typeobject.pile, "Invalid item: " .. init.item)

        local w, h, d = typeobject.pile:match("(%d+)x(%d+)x(%d+)")
        assert(w and h and d, "Invalid pile: " .. typeobject.pile)
        local capacity = w * h * d

        c[#c+1] = world:chest_slot {
            type = "blue",
            item = typeobject.id,
            limit = capacity,
        }
    else
        c[#c+1] = world:chest_slot {
            type = "blue",
            item = 0,
            limit = 0,
        }
    end
    chest = world:container_create(table.concat(c))

    return {
        hub = {
            id = 0,
            chest = chest
        }
    }
end
