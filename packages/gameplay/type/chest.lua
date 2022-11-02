local prototype = require "prototype"
local type = require "register.type"

local c = type "chest"
    .chest_type "chest_type"
    .slots "number"

local CHEST_RED <const> = 0
local CHEST_BLUE <const> = 1
local CHEST_GREEN <const> = 2

function c:ctor(init, pt)
    local world = self
    local chest = {}
    for _ = 1, pt.slots do
        chest[#chest+1] = world:chest_slot {
            type = pt.chest_type,
        }
    end
    local id = world:container_create(table.concat(chest))
    if init.items then
        for _, item in pairs(init.items) do
            local what = prototype.queryByName("item", item[1])
            assert(pt, "unknown item: " .. item[1])
            self:container_place(id, what.id, item[2])
        end
    end
    if pt.chest_type == CHEST_GREEN then
        return {
            chest = {
                endpoint = 0xffff,
                chest_in = id,
                chest_out = id,
                fluidbox_in = 0,
                fluidbox_out = 0,
            }
        }
    elseif pt.chest_type == CHEST_RED then
        return {
            chest = {
                endpoint = 0xffff,
                chest_in = 0xffff,
                chest_out = id,
                fluidbox_in = 0,
                fluidbox_out = 0,
            }
        }
    elseif pt.chest_type == CHEST_BLUE then
        return {
            chest = {
                endpoint = 0xffff,
                chest_in = id,
                chest_out = 0xffff,
                fluidbox_in = 0,
                fluidbox_out = 0,
            }
        }
    end
end
