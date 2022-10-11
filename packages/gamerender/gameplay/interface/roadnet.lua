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

-- starting & ending road coord
function mt:push_lorry(starting, ending)
    return self.cworld:push_lorry(starting, ending)
end

-- map = {loc = roadmask, ...}
-- loc = (y << 8) | x -- see also: get_location(lua_State *L, int idx)
local function create(map, callback)
    local cworld = roadnet_core.create_world()

    local w = {}
    w.callback = callback
    w.cworld = cworld
    w.cworld:load_map(map)
    return setmetatable(w, mt)
end

local get_road_mask, is_cross, entry_count, all_prototype_bits; do -- TODO: we really need the entry_count api?
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

    -- every 2 bits represent one direction of a road, 00 means nothing, 01 means road, 10 means roadside, total 8 bits represent 4 directions
    for _, typeobject in pairs(iprototype.each_maintype("entity", "road")) do
        for _, entity_dir in pairs(typeobject.flow_direction) do
            local bits = 0
            local c = 0

            local connections = typeobject.crossing.connections
            for _, connection in ipairs(connections) do
                local dir = assert(mapping[iprototype.rotate_dir(connection.position[3], entity_dir)])
                local value
                if connection.roadside then
                    value = 2
                else
                    value = 1
                end
                bits = bits | (value << (dir * 2))
                c = c + 1
            end

            assert(prototype_bits[typeobject.name][entity_dir] == nil)
            prototype_bits[typeobject.name][entity_dir] = {bits = bits, is_cross = (c >= 3), c = c}
        end
    end

    function get_road_mask(prototype_name, dir)
        return assert(prototype_bits[prototype_name][dir]).bits
    end

    function is_cross(prototype_name, dir)
        return assert(prototype_bits[prototype_name][dir]).is_cross
    end

    function entry_count(prototype_name, dir)
        return assert(prototype_bits[prototype_name][dir]).c
    end

    function all_prototype_bits()
        return prototype_bits
    end
end

return {
    create = create,
    is_cross = is_cross,
    entry_count = entry_count,
    road_mask = get_road_mask,
    prototype_bits = all_prototype_bits,
}