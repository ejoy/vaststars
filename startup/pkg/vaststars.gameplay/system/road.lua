local system = require "register.system"
local prototype = require "prototype"
local query = prototype.queryById

local ROAD_TILE_WIDTH_SCALE <const> = 2
local ROAD_TILE_HEIGHT_SCALE <const> = 2

local m = system "road"

local mt = {}
mt.__index = function (t, k)
    t[k] = setmetatable({}, mt)
    return t[k]
end

local function is_roadid(pt)
    for _, t in ipairs(pt.type) do
        if t == "road" then
            return true
        end
    end
    return false
end

local roadbits = setmetatable({}, mt)

local N <const> = 0
local E <const> = 1
local S <const> = 2
local W <const> = 3

local MapRoad <const> = {
    Left       = 1 << 0,
    Top        = 1 << 1,
    Right      = 1 << 2,
    Bottom     = 1 << 3,
    Endpoint   = 1 << 4,
    NoLeftTurn = 1 << 5,
    NoUTurn    = 1 << 6,
}

local Direction <const> = {
    ["N"] = 0,
    ["E"] = 1,
    ["S"] = 2,
    ["W"] = 3,
}

-- see also roadnet/network.h - MapRoad 
local DirectionToMapRoad <const> = {
    [0] = 1,
    [1] = 2,
    [2] = 3,
    [3] = 0,
}

local function pack(x, y)
    return (y << 8)|x
end

local function unpack(coord)
    return coord & 0xFF, coord >> 8
end

local function rotate(position, direction, area)
    local w, h = area >> 8, area & 0xFF
    local x, y = position[1], position[2]
    w = w - 1
    h = h - 1
    if direction == N then
        return x, y
    elseif direction == E then
        return h - y, x
    elseif direction == S then
        return w - x, h - y
    elseif direction == W then
        return y, w - x
    end
end

local function calc_roadbits(pt, direction)
    local bits = 0
    for _, c in ipairs(pt.crossing.connections) do
        local dir = (Direction[c.position[3]] + direction) % 4
        bits = bits | (1 << (DirectionToMapRoad[dir]))
    end
    return bits
end

local function open(bits, dir)
    -- assert(bits & (1 << (DirectionToMapRoad[dir])) == 0)
    return bits | (1 << (DirectionToMapRoad[dir]))
end

local function build_road(world, building_eid, building, map, road_cache, endpoint_keys)
    local ecs = world.ecs
    local pt = query(building.prototype)

    local roads = {}
    for _, e in ipairs(pt.affected_roads) do
        local dx, dy = rotate(e.position, building.direction, pt.area)
        local key = pack((building.x + dx) // ROAD_TILE_WIDTH_SCALE, (building.y + dy) // ROAD_TILE_HEIGHT_SCALE)

        if not map[key] then
            return
        end
        local dir = (Direction[e.dir] + building.direction) % 4
        roads[key] = open(map[key], dir)
        for _, m in ipairs(e.mask) do
            roads[key] = roads[key] | MapRoad[m]
        end
    end

    for key, mask in pairs(roads) do
        map[key] = mask

        local eid = assert(road_cache[key])
        local e = assert(world.entity[eid])
        e.road.mask = mask
        e.road_changed = true
    end

    for _, e in ipairs(pt.endpoint) do
        local dx, dy = rotate(e.position, building.direction, pt.area)
        local key = pack((building.x + dx) // ROAD_TILE_WIDTH_SCALE, (building.y + dy) // ROAD_TILE_HEIGHT_SCALE)
        local id = prototype.queryByName(e.prototype).id -- TODO: remove prototype

        assert(not map[key])
        local dir = (Direction[e.dir]+ building.direction) % 4
        map[key] = roadbits[id][dir]
        for _, m in ipairs(e.mask) do
            map[key] = map[key] | MapRoad[m]

            if m == "Endpoint" then
                endpoint_keys[building_eid] = key
            end
        end

        road_cache[key] = ecs:new {
            road = {
                x = building.x + dx,
                y = building.y + dy,
                mask = map[key],
                classid = id,
            },
            endpoint_road = true,
            road_changed = true,
        }
    end
end

function m.prototype_restore()
    roadbits = setmetatable({}, mt)
    for _, pt in pairs(prototype.all()) do
        if is_roadid(pt) then
            for _, dir in pairs(pt.building_direction) do
                local bits = calc_roadbits(pt, Direction[dir])
                assert(rawget(roadbits[pt.id], dir) == nil)
                roadbits[pt.id][Direction[dir]] = bits
            end
        end
    end
end

--
local dir_move_delta = {
    [0] = {x = 0,  y = -1},
    [1] = {x = 1,  y = 0},
    [2] = {x = 0,  y = 1},
    [3] = {x = -1, y = 0},
}
local function move_coord(x, y, dir, dx, dy)
    dx = dx or 1
    dy = dy or dx

    local c = assert(dir_move_delta[dir])
    return x + c.x * dx, y + c.y * dy
end

local function fix(world, map, road_cache)
    local ecs = world.ecs

    local res = {}
    for coord, mask in pairs(map) do
        local x, y = unpack(coord)
        for i = 0, 3 do
            local maproad = DirectionToMapRoad[i]
            if mask & (1 << maproad) ~= 0 then
                local dx, dy = move_coord(x, y, i, 1, 1)
                if not map[pack(dx, dy)] then
                    mask = mask & ~(1 << maproad)
                else
                    local neighbor_mask = map[pack(dx, dy)]
                    if neighbor_mask & (1 << ((maproad + 2) % 4)) == 0 then
                        mask = mask & ~(1 << maproad)
                    end
                end
            end
        end
        if mask ~= 0 then
            res[coord] = mask
            local r = assert(world.entity[road_cache[coord]])
            r.road.mask = mask
        else
            ecs:remove(road_cache[coord])
        end
    end
    return res
end

function m.build(world)
    local ecs = world.ecs

    local map = {}
    local road_cache = {}
    local endpoint_keys = {}

    for v in ecs:select "endpoint_road:in eid:in" do
        ecs:remove(v.eid)
    end

    for v in ecs:select "road:in eid:in REMOVED:absent" do
        local key = pack(v.road.x, v.road.y)
        map[key] = v.road.mask
        road_cache[key] = v.eid
    end

    for v in ecs:select "station:update building:in eid:in" do
        build_road(world, v.eid, v.building, map, road_cache, endpoint_keys)
    end

    for v in ecs:select "lorry_factory:update building:in eid:in" do
        build_road(world, v.eid, v.building, map, road_cache, endpoint_keys)
    end

    map = fix(world, map, road_cache)
    world:roadnet_reset(map)

    for v in ecs:select "station:update eid:in" do
        local key = endpoint_keys[v.eid]
        v.station.endpoint = key and (world._endpoints[key] or 0xFFFF) or 0xFFFF
    end

    for v in ecs:select "lorry_factory:update eid:in" do
        local key = endpoint_keys[v.eid]
        v.lorry_factory.endpoint = key and (world._endpoints[key] or 0xFFFF) or 0xFFFF
    end

    ecs:clear "road_cache"
    ecs:new {
        road_cache = road_cache,
    }
end