local system = require "register.system"
local query = require "prototype".queryById

local m = system "endpoint"
local mapping = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

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
        local pt = query(prototype)

        local connections = pt.crossing.connections
        for _, connection in ipairs(connections) do
            assert(mapping[connection.position[3]])
            local d = (mapping[connection.position[3]] + dir) % 4
            local value = 0
            if not connection.roadside then
                value = 1
            end
            bits = bits | (value << d)
        end

        assert(bits == (bits & 0xF))
        assert(cache[prototype][dir] == nil)
        cache[prototype][dir] = bits
        return bits
    end
end

function m.init(world)
    local ecs = world.ecs
    if ecs:first("road_changed:in") then -- TODO: optimize
        local map = {}
        for e in ecs:select "road entity:in" do
            local loc = (e.entity.y << 8) | e.entity.x -- see also: get_location(lua_State *L, int idx)
            map[loc] = road_mask(e.entity.prototype, e.entity.direction)
        end
        world.roadnet:load_map(map)
    end
    ecs:clear "road_changed"
end

function m.pre_restore_finish(world)
    local ecs = world.ecs
    local map = {}
    for e in ecs:select "road entity:in" do
        local loc = (e.entity.y << 8) | e.entity.x -- see also: get_location(lua_State *L, int idx)
        map[loc] = road_mask(e.entity.prototype, e.entity.direction)
    end
    world.roadnet:load_map(map)
end
