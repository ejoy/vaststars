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

local function create_endpoint(world, init, pt)
    assert(#pt.crossing.connections == 1)
    local x, y, dir = rotate(pt.crossing.connections[1].position, DIRECTION[init.dir], pt.area)
    x = x + init.x
    y = y + init.y
    return world.roadnet:create_endpoint(x, y, mapping[DIRECTION[dir]]) -- endpoint equals 0xffff if doesn't connect to any road
end

return {
    create = create_endpoint,
}
