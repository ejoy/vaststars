local type = require "register.type"
local prototype = require "prototype"
local iChest = require "interface.chest"

local c = type "hub"
    .supply_area "size"

function c:ctor(init, pt)
    local world = self

    local chest
    local c = {}
    if init.item then
        c[#c+1] = {
            type = "blue",
            item = init.item,
            limit = prototype.queryByName(init.item).pile & 0xffffff,
        }
    else
        c[#c+1] = {
            type = "blue",
            item = 0,
            limit = 0,
        }
    end
    chest = iChest.create(world, c)
    return {
        hub = {
            id = 0,
            chest = chest
        }
    }
end
