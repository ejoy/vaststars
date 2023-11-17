local type = require "register.type"
local prototype = require "prototype"
local iChest = require "interface.chest"

local c = type "chest"
    .chest_type "chest_type"

function c:ctor(init, pt)
    local world = self
    local items = {}
    if init.items then
        for _, v in ipairs(init.items) do
            local typeobject = prototype.queryByName(v[1])
            items[#items+1] = {
                type = pt.chest_type,
                item = typeobject.id,
                amount = v[2],
                limit = typeobject.chest_limit,
            }
        end
    end

    local chest = {
        chest = iChest.create(world, items),
    }
    return {
        chest = chest
    }
end
