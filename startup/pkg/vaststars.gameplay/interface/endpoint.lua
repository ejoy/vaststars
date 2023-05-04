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

local function rotate(position, direction, area)
    local w, h = area >> 8, area & 0xFF
    local x, y = position[1], position[2]
    w = w - 1
    h = h - 1
    if direction == DIRECTION.N then
        return x, y
    elseif direction == DIRECTION.E then
        return h - y, x
    elseif direction == DIRECTION.S then
        return w - x, h - y
    elseif direction == DIRECTION.W then
        return y, w - x
    end
end

local function get_tile(pt, type)
    assert(pt.endpoint)
    for _, r in ipairs(pt.endpoint) do
        if r.type == type then
            return r
        end
    end
    assert(false, "can not found type: " .. type)
end

local function endpoint_id(world, init, pt)
    assert(init.x and init.y and init.dir)
    local r = get_tile(pt, "endpoint")
    local x, y = rotate(r.position, DIRECTION[init.dir], pt.area)
    x = x + init.x
    y = y + init.y
    local endpoint_id =  world:roadnet_endpoint_id(x, y)
    if endpoint_id == 0xFFFF then
        print("can not find roadnet endpoint", pt.name, x, y)
    end
    return endpoint_id
end

return {
    endpoint_id = endpoint_id,
}
