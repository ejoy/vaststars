local query = require "prototype".queryById

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

local function getConnection(pt, type)
    for _, c in ipairs(pt.crossing.connections) do
        if c.type == type then
            return c
        end
    end
end

local function create_endpoint(world, init, pt, type)
    if not pt.crossing then
        return 0xffff -- Assembling that does not rely on logistics network, eg: groundwater excavator.
    end
    local c = assert(getConnection(pt, type))
    local x, y, dir = rotate(c.position, DIRECTION[init.dir], pt.area)
    x = x + init.x
    y = y + init.y
    return world:roadnet_create_endpoint(x, y, mapping[DIRECTION[dir]]) -- endpoint equals 0xffff if doesn't connect to any road
end

local function update_chest_endpoint(world, e)
    local ecs = world.ecs
    ecs:extend(e, "chest:update building:in")

    local pt = query(e.building.prototype)
    local x, y, dir = rotate(pt.crossing.connections[1].position, e.building.direction, pt.area)
    x = x + e.building.x
    y = y + e.building.y
    local endpoint = world:roadnet_create_endpoint(x, y, mapping[DIRECTION[dir]]) -- endpoint equals 0xffff if doesn't connect to any road
    if endpoint == 0xffff then
        return
    end

    local chest = e.chest
    chest.endpoint = endpoint
end

return {
    create = create_endpoint,
    update_chest_endpoint = update_chest_endpoint,
}
