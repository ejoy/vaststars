local type = require "register.type"
local iChest = require "interface.chest"

local c = type "chest"
    .chest_type "chest_type"

function c:ctor(init, pt)
    local world = self
    local items = {}
    for _, v in ipairs(init.items or {}) do
        items[#items+1] = {
            type = pt.chest_type,
            item = v[1],
            amount = v[2],
        }
    end

    local chest = {
        chest = iChest.create(world, items),
    }
    return {
        chest = chest
    }
end
