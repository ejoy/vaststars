local system = require "register.system"
local prototype = require "prototype"
local query = prototype.queryById
local iroad = require "interface.road"

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

local MapRoad <const> = {
    Left         = 1 << 0,
    Top          = 1 << 1,
    Right        = 1 << 2,
    Bottom       = 1 << 3,
    Endpoint     = 1 << 4,
    NoHorizontal = 1 << 5,
    NoVertical   = 1 << 6,
}

local Direction <const> = {
    ["N"] = 0,
    ["E"] = 1,
    ["S"] = 2,
    ["W"] = 3,
}

local N <const> = 0
local E <const> = 1
local S <const> = 2
local W <const> = 3

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
    return bits | (1 << (DirectionToMapRoad[dir]))
end

local function close(bits, dir)
    assert(bits & (1 << (DirectionToMapRoad[dir])) ~= 0)
    return bits & ~(1 << (DirectionToMapRoad[dir]))
end

local function check(bits, dir)
    return (bits & (1 << (DirectionToMapRoad[dir]))) ~= 0
end

local function build_road(world, building_eid, building, map, road_cache, endpoint_keys)
    local ecs = world.ecs
    local pt = query(building.prototype)

    local affected_roads_mask = 0
    if building.direction == N or building.direction == S then
        affected_roads_mask = MapRoad.NoVertical
    else
        affected_roads_mask = MapRoad.NoHorizontal
    end

    local roads = {}
    for _, e in ipairs(pt.affected_roads) do
        local dx, dy = rotate(e.position, building.direction, pt.area)
        local key = pack((building.x + dx) // ROAD_TILE_WIDTH_SCALE, (building.y + dy) // ROAD_TILE_HEIGHT_SCALE)

        if not map[key] then
            return
        end
        local dir = (Direction[e.dir] + building.direction) % 4
        roads[key] = open(map[key], dir)
        roads[key] = roads[key] | affected_roads_mask
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
                x = (building.x + dx) // ROAD_TILE_WIDTH_SCALE,
                y = (building.y + dy) // ROAD_TILE_HEIGHT_SCALE,
                mask = map[key],
                classid = id,
            },
            endpoint_road = true,
            road_changed = true,
        }
    end
end

function m.prototype_restore(world)
    iroad.set_change(world)

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

local function move(d)
    if d == N then
        return 0, -1
    elseif d == E then
        return 1, 0
    elseif d == S then
        return 0, 1
    elseif d == W then
        return -1, 0
    end
end

local function reverse(d)
    if d == N then
        return S
    elseif d == E then
        return W
    elseif d == S then
        return N
    elseif d == W then
        return E
    end
end

local function repair(world, map, road_cache)
    local m
    for coord, mask in pairs(map) do
        m = mask
        local x, y = unpack(coord)
        for dir = 0, 3 do
            if check(m, dir) then
                local dx, dy = move(dir)
                dx, dy = x + dx, y + dy

                local neighbor_mask = map[pack(dx, dy)]
                if not neighbor_mask then
                    m = close(m, dir)
                else
                    if not check(neighbor_mask, reverse(dir)) then
                        m = close(m, dir)
                    end
                end
            end
        end

        if mask ~= m then
            map[coord] = m

            local r = assert(world.entity[road_cache[coord]])
            r.road.mask = m
        end
    end
    return map
end

local function mark_neighbor(valid, map, x, y)
    local m = map[pack(x, y)]
    for dir = 0, 3 do
        if not check(m, dir) then
            goto continue
        end

        local dx, dy = move(dir)
        dx, dy = x + dx, y + dy
        local key = pack(dx, dy)
        if valid[key] then
            goto continue
        end

        local neighbor_mask = map[key]
        if neighbor_mask then
            valid[key] = true
            mark_neighbor(valid, map, dx, dy)
        end
        ::continue::
    end
end

local function mark_invalid(world, map, road_cache, building)
    local pt = query(building.prototype)

    local valid = {}
    for _, e in ipairs(pt.affected_roads) do
        local dx, dy = rotate(e.position, building.direction, pt.area)
        dx, dy = (building.x + dx) // ROAD_TILE_WIDTH_SCALE, (building.y + dy) // ROAD_TILE_HEIGHT_SCALE
        local key = pack(dx, dy)
        local m = map[key]
        if m then
            valid[key] = true
            mark_neighbor(valid, map, dx, dy)
        end
    end

    for coord in pairs(map) do
        if not valid[coord] then
            local r = assert(world.entity[road_cache[coord]])
            r.road_invalid = true
        end
    end
end

function m.build(world)
    local ecs = world.ecs

    if not ecs:first("roadnet_changed:in") then
        return
    end
    ecs:clear "road_invalid"

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

    local building
    for v in ecs:select "lorry_factory:update building:in eid:in" do
        building = v.building
        build_road(world, v.eid, v.building, map, road_cache, endpoint_keys)
    end

    map = repair(world, map, road_cache)
    mark_invalid(world, map, road_cache, building)

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