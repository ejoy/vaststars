local prototype = require "prototype"
local type = require "register.type"

local c = type "chest"
    .slots "number"

function c:ctor(init, pt)
    local world = self
    local chest = {}
    for _ = 1, pt.slots do
        chest[#chest+1] = string.pack("<I2I2I2I2I2", 1, 0, 0, 0, 0)
    end
    local id = world:container_create("none", table.concat(chest))
    if init.items then
        for _, item in pairs(init.items) do
            local what = prototype.queryByName("item", item[1])
            assert(pt, "unknown item: " .. item[1])
            self:container_place(id, what.id, item[2])
        end
    end
    return {
        chest = {
            chest = id
        }
    }
end
