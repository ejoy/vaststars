local iChest = require "interface.chest"

local function set_item(world, e, item)
    iChest.hub_set(world, e, item)
end

return {
    set_item = set_item,
}
