local iprototype = require "gameplay.interface.prototype"

local mapping = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

local function convert(t)
    local res = {}

    for _, r in ipairs(t) do
        local k = iprototype.packcoord(r.x, r.y)
        local v = 0

        local typeobject = iprototype.queryByName("entity", r.prototype_name)
        local connections = typeobject.crossing.connections
        for _, connection in ipairs(connections) do
            local dir = assert(mapping[iprototype.rotate_dir(connection.position[3], r.dir)])
            local value
            if connection.roadside then
                value = 2
            else
                value = 1
            end
            v = v | (value << (dir * 2))
        end

        res[k] = v
    end

    return res
end

local function from(t)
    local res = {}

    for k, r in pairs(t) do
        local v = 0

        for _, b in pairs(mapping) do
            if r & (1 << b) ~= 0 then
                v = v | (1 << (b * 2))
            end
        end

        res[k] = v
    end

    return res
end

return {
    convert = convert,
    from = from,
}