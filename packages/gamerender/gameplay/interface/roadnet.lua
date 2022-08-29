local roadnet_core = require "vaststars.roadnet.core"
local iprototype = require "gameplay.interface.prototype"

local mt = {}
mt.__index = mt

function mt:update()
    local w = self
	w.cworld:update()

    local is_cross, mc, x, y, z
	for lorry_id, rc, tick in w.cworld:each_lorry() do
        is_cross = (rc & 0x8000 ~= 0) -- see also: push_road_coord() in c code
        mc = w.map_coord[rc]
        x = (mc >>  0) & 0xFF
        y = (mc >>  8) & 0xFF
        z = (mc >> 16) & 0xFF
		w.callback(lorry_id, is_cross, x, y, z, tick)
	end
end

function mt:bfs(S, E)
    return self.cworld:bfs(self.road_coord[S], self.road_coord[E])
end

function mt:add_line(...)
    return self.cworld:add_line(...)
end

function mt:add_lorry(lineid, idx, x, y, z)
    local l = ((y & 0xFF) << 8) | (x & 0xFF)
    return self.cworld:add_lorry(lineid, idx, l, z)
end

-- TODO: optimize -> strmap
local function create(strmap, callback)
    local cworld = roadnet_core.create_world()

    local w = {}
    w.callback = callback
    w.cworld = cworld
    w.cworld:load_map(strmap)

    local road_coord = {}
    local map_coord  = {}
    w.road_coord = setmetatable(road_coord, {
        __index = function (_, mc)
            local rc = cworld:road_coord(mc)
            assert(cworld:map_coord(rc) == mc)
            road_coord[mc] = rc
            map_coord[rc]  = mc
            return rc
        end
    })
    w.map_coord  = setmetatable(map_coord, {
        __index = function (_, rc)
            local mc = cworld:map_coord(rc)
            assert(cworld:road_coord(mc) == rc)
            road_coord[mc] = rc
            map_coord[rc]  = mc
            return mc
        end
    })

    return setmetatable(w, mt)
end

local get_road_mask; do
    local mt = {}
    function mt:__index(k)
        local v = {}
        rawset(self, k, v)
        return v
    end
    local prototype_bits = setmetatable({}, mt) -- = [prototype][direction] = bits

    local mapping = {
        W = 0, -- left
        N = 1, -- top
        E = 2, -- right
        S = 3, -- bottom
    }

    for _, typeobject in pairs(iprototype.each_maintype("entity", "road")) do
        for _, entity_dir in pairs(typeobject.flow_direction) do
            local bits = 0
            local connections = typeobject.crossing.connections
            for _, connection in ipairs(connections) do
                local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
                bits = bits | (1 << mapping[dir])
            end

            assert(prototype_bits[typeobject.name][entity_dir] == nil)
            prototype_bits[typeobject.name][entity_dir] = bits
        end
    end

    function get_road_mask(prototype_name, dir)
        return assert(prototype_bits[prototype_name][dir])
    end
end

return {
    create = create,
    road_mask = get_road_mask,
}