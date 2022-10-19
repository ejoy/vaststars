local system = require "register.system"
local query = require "prototype".queryById
local m = system "endpoint"

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
    [0] = 'N',
    [1] = 'E',
    [2] = 'S',
    [3] = 'W',
}

local mapping = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

local function rotate(position, direction, area)
    local w, h = area >> 8, area & 0xFF
    local x, y = position[1], position[2]
    local dir = (DIRECTION[position[3]] + direction) % 4
    w = w - 1
    h = h - 1
    if direction == DIRECTION.N then
        return x, y, dir
    elseif direction == DIRECTION.E then
        return h - y, x, dir
    elseif direction == DIRECTION.S then
        return w - x, h - y, dir
    elseif direction == DIRECTION.W then
        return y, w - x, dir
    end
end

function m.build(world)
    -- local ecs = world.ecs
    -- for e in ecs:select "endpoint_changed:in entity:in chest_2?update station?update " do
    --     local pt = query(e.entity.prototype)
    --     assert(#pt.crossing.connections == 1)
    --     local x, y, dir = rotate(pt.crossing.connections[1].position, e.entity.direction, pt.area)
    --     x = x + e.entity.x
    --     y = y + e.entity.y
    --     dir = mapping[DIRECTION[dir]] -- TODO
    --     local endpoint = world.roadnet:create_endpoint(x, y, dir)
    --     if e.chest_2 then
    --         local chest = e.chest_2
    --         chest.endpoint = endpoint
    --         world:container_set_endpoint(chest.chest_in, endpoint)
    --         world:container_set_endpoint(chest.chest_out, endpoint)
    --     elseif e.station then
    --         e.station.endpoint = endpoint
    --         local l = world.roadnet:create_lorry()
    --         world.roadnet:place_lorry(endpoint, l)
    --     else
    --         assert(false)
    --     end
    -- end
    -- ecs:clear "endpoint_changed"
end
