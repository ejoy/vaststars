local type = require "register.type"

local c = type "chest"
    .chest_type "chest_type"

function c:ctor(init, pt)
    local world = self
    local items = {}
    for _, v in ipairs(init.items or {}) do
        items[#items+1] = world:chest_slot {
            type = pt.chest_type,
            item = v[1],
            amount = v[2],
        }
    end

    local chest = {
        chest = world:container_create(table.concat(items)),
    }
    return {
        chest = chest
    }
end
