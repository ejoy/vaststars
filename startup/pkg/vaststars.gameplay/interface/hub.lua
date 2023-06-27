local prototype = require "prototype"
local building = require "interface.building"

local function set_item(world, e, item)
    local hub = e.hub
    world:container_destroy(hub)

    local typeobject = prototype.queryByName(item)
    assert(typeobject and typeobject.pile, "Invalid item: " .. item)

    local w, h, d = typeobject.pile:match("(%d+)x(%d+)x(%d+)")
    assert(w and h and d, "Invalid pile: " .. typeobject.pile)
    local capacity = w * h * d

    local c = {}
    c[#c+1] = world:chest_slot {
        type = "blue",
        item = typeobject.id,
        limit = capacity,
    }
    hub.chest = world:container_create(table.concat(c))
    building.dirty(world, "hub")
end

return {
    set_item = set_item,
}
