local prototype = require "prototype"
local type = require "register.type"

local c = type "chest"
    .slots "number"

function c:ctor(init, pt)
    local id = self:container_create("chest", pt.slots)
    if init.items then
        for _, item in pairs(init.items) do
            local what = prototype.queryByName("item", item[1])
            assert(pt, "unknown item: " .. item[1])
            self:container_place(id, what.id, item[2])
        end
    end
    return {
        chest = {
            container = id
        }
    }
end
