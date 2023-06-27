local iBuilding = require "interface.building"

local m = {}

local InvalidChest <const> = 0

function m.reset(world, e, items)
    local chest = e.chest
    if chest.chest ~= InvalidChest then
        world:container_destroy(chest)
        if items == nil then
            iBuilding.dirty(world, "hub")
            chest.chest = InvalidChest
            return
        end
    end
    if items ~= nil then
        chest.chest = world:container_create(items)
        iBuilding.dirty(world, "hub")
    end
end

return m
