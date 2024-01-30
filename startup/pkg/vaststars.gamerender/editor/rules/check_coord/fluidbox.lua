local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local ifluidbox = ecs.require "render_updates.fluidbox"

local function _get_neighbor_fluid_types(typeobject, x, y, dir)
    local fluids = {}
    for _, connection in ipairs(typeobject.fluidbox.connections) do
        local dx, dy, ddir = iprototype.rotate_connection(connection.position, dir, typeobject.area)
        dx, dy = iprototype.move_coord(x + dx, y + dy, ddir, 1)
        local fluid = ifluidbox.get(dx, dy, iprototype.reverse_dir(ddir))
        if fluid then
            fluids[fluid] = true
        end
    end
    local array = {}
    for fluid in pairs(fluids) do
        array[#array + 1] = fluid
    end
    return array
end

return function (x, y, dir, typeobject, exclude_coords)
    assert(iprototype.has_type(typeobject.type, "fluidbox"))
    local fluids = _get_neighbor_fluid_types(typeobject, x, y, dir)
    if #fluids > 1 then
        return false, "different fluids do not mix"
    end

    return true
end