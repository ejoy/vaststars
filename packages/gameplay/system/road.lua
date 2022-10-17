local system = require "register.system"
local query = require "prototype".queryById

local m = system "endpoint"

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

local function rotate(dir, rotate_dir)
    return (DIRECTION[dir] + rotate_dir) % 4
end

local road_mask; do
    local mt = {}
    function mt:__index(k)
        self[k] = {}
        return self[k]
    end
    local cache = setmetatable({}, mt)
    function road_mask(prototype, dir)
        if cache[prototype] and cache[prototype][dir] then
            return cache[prototype][dir]
        end

        local bits = 0
        local c = 0

        local pt = query(prototype)

        local connections = pt.crossing.connections
        for _, connection in ipairs(connections) do
            assert(DIRECTION[connection.position[3]])
            local d = (DIRECTION[connection.position[3]] + dir) % 4
            local value
            if connection.roadside then
                value = 2
            else
                value = 1
            end
            bits = bits | (value << (d * 2))
            c = c + 1
        end

        assert(cache[pt.id][dir] == nil)
        cache[pt.id][dir] = bits
        return bits
    end
end

function m.init(world)
    local ecs = world.ecs
    if ecs:first("road_changed:in entity:in") then
        local map = {}
        -- pre 2 bits represent one direction of a road, 00 means nothing, 01 means road, 10 means roadside, total 8 bits represent 4 directions
        for e in ecs:select "road entity:in" do
            local loc = (e.entity.y << 8) | e.entity.x -- see also: get_location(lua_State *L, int idx)
            map[loc] = road_mask(e.entity.prototype, e.entity.direction)
        end
        -- world.roadnet:load_map(map)
    end
    ecs:clear "road_changed"
end
