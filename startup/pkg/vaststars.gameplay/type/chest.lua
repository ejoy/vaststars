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
            local typeobject
            if v[1] ~= "" then
                typeobject = prototype.queryByName(v[1])
            end
            items[#items+1] = {
                type = pt.chest_type,
                item = typeobject and typeobject.id or 0,
                amount = v[2],
                limit = typeobject and typeobject.chest_limit or 0,
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
