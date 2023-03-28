import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"
local iprototype = gameplay.prototype

local mapping = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

local function packcoord(x, y)
    assert(x & 0xFF == x)
    assert(y & 0xFF == y)
    return x | (y<<8)
end

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}

local DIRECTION_REV = {}
for dir, v in pairs(DIRECTION) do
    DIRECTION_REV[v] = dir
end

local function rotate_dir(dir, rotate_dir, anticlockwise)
    if anticlockwise == nil then
        return DIRECTION_REV[(DIRECTION[dir] + DIRECTION[rotate_dir]) % 4]
    else
        return DIRECTION_REV[(DIRECTION[dir] - DIRECTION[rotate_dir]) % 4]
    end
end

local function convert(t)
    local res = {}

    for _, r in ipairs(t) do
        local k = packcoord(r.x, r.y)
        local v = 0

        local typeobject = iprototype.queryByName(r.prototype_name)
        local connections = typeobject.crossing.connections
        for _, connection in ipairs(connections) do
            local dir = assert(mapping[rotate_dir(connection.position[3], r.dir)])
            v = v | (1 << (dir * 1))
        end

        res[k] = v
    end

    return res
end
return convert