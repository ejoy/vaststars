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

local function endpoint_id(world, init, pt, type)
    assert(pt.crossing)
    local c = assert(getConnection(pt, type))
    local x, y, dir = rotate(c.position, DIRECTION[init.dir], pt.area)
    x = x + init.x
    y = y + init.y
    return world:roadnet_endpoint_id(x, y, mapping[DIRECTION[dir]])
end

return {
    endpoint_id = endpoint_id,
}
