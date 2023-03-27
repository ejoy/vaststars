local prototype = require "prototype"

local function set_item(world, e, item)
    local hub = e.hub
    world:container_destroy(hub)

    local typeobject = assert(prototype.queryByName(item))
    assert(typeobject.pile)
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
end

return {
    set_item = set_item,
}
