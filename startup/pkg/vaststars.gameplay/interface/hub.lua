local iChest = require "interface.chest"

local function set_item(world, e, items)
    iChest.hub_set(world, e, items)
end

return {
    set_item = set_item,
}
