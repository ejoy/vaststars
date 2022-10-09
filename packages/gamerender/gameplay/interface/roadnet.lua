local roadnet_core = require "vaststars.roadnet.core"
local iprototype = require "gameplay.interface.prototype"
local roadmap_core = require "vaststars.roadmap.core"

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

-- starting & ending road coord
function mt:add_lorry(lineid, starting, ending)
    return self.cworld:add_lorry(lineid, starting, ending)
end

local mapping_id, mapping_sid ; do
    local mapping = {}
    local mapping_s = {}
    local id = 0
    function mapping_id(v)
        if not mapping[v] then
            id = id + 1
            mapping[v] = id
            mapping_s[id] = v
            return id
        else
            return mapping[v]
        end
    end
    function mapping_sid(id)
        return assert(mapping_s[id])
    end
end

local route = {} ; do
    local cache
    function route.map(m)
        local r = {}
        for _, v in ipairs(m) do -- TODO: from, to, length avoid 0 for routecache
            r[#r+1] = {mapping_id(v[1]), mapping_id(v[2]), v[3] + 1}
        end
        cache = roadmap_core.routecache(roadmap_core.map(r))
    end
    function route.path(source, from, to)
        local r = {}
        source, from, to = mapping_id(source), mapping_id(from), mapping_id(to) -- TODO: source, from, to avoid 0 for routecache

        local checkpoint = from
        while checkpoint ~= to do
            local index = source << 32 | checkpoint << 16 | to
            local dest = assert(cache[index])
            r[#r+1] = {mapping_sid(checkpoint), mapping_sid(dest)} -- TODO: checkpoint, dest avoid 0 for routecache
            source = checkpoint
            checkpoint = dest
        end
        return r
    end
end

-- road id to map coord
local function rid_mc(w, roadid, offset)
    local road_coord = (offset or 1) << 16 | (roadid & 0xFFFF)
    local map_coord = w.map_coord[road_coord]
    return {x = map_coord & 0xFF, y = (map_coord >> 8) & 0xFF, z = (map_coord >> 16) & 0xFF}
end

local function rc_rid(rc)
    return rc & 0xFFFF
end

-- map = {loc = roadmask, ...}
-- loc = (y << 8) | x -- see also: get_location(lua_State *L, int idx)
local function create(map, callback)
    local cworld = roadnet_core.create_world()

    local w = {}
    w.callback = callback
    w.cworld = cworld
    w.cworld:load_map(map)
    local directionName = {
        [0] = 'L',
        [1] = 'T',
        [2] = 'R',
        [3] = 'B',
    }

    route.map(w.cworld:route_cost())
    w.path = function(self, S, E)
        local from, to = self.road_coord[S], self.road_coord[E]
        local endpoint = {}

        -- TODO: optimize
        endpoint[#endpoint+1] = {
            source = self.cworld:prev_roadid(from) or rc_rid(from),
            from = self.cworld:next_roadid(from) or rc_rid(from),
            to = self.cworld:next_roadid(to) or rc_rid(to),
        }
        endpoint[#endpoint+1] = { to = self.cworld:next_roadid(from) or rc_rid(from) }

        local paths = {}
        for i = 1, #endpoint do
            local e = endpoint[i]
            local prev = endpoint[i - 1] or {}
            local last = paths[#paths] or {prev.from, prev.to}
            local path = route.path(e.source or last[1], e.from or last[2], e.to)
            for _, v in ipairs(path) do
                paths[#paths+1] = v
            end
        end

        local r = {}
        for _, path in ipairs(paths) do
            r[#r+1] = directionName[self.cworld:route_dir(path[1], path[2])]
        end
        return table.concat(r), paths, endpoint
    end

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
    rid_mc = rid_mc,
    rc_rid = rc_rid,
}