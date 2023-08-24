local iChest = require "interface.chest"

local m = {}

function m.set_item(world, e, items)
    iChest.station_set(world, e, items)
end

return m
