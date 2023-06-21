local system = require "register.system"
local prototype = require "prototype"
local query = prototype.queryById

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

local roadbits_rev = setmetatable({}, mt)

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

-- see also clibs\gameplay\src\roadnet\network.cpp - enum class MapRoad
local MapRoad <const> = {
    Left         = 1 << 0,
    Top          = 1 << 1,
    Right        = 1 << 2,
    Bottom       = 1 << 3,
    Endpoint     = 1 << 4,
    NoHorizontal = 1 << 5,
    NoVertical   = 1 << 6,
}

-- see also clibs\gameplay\src\roadnet\type.h - enum class direction
local RoadDirection = {
    l = 0,
    t = 1,
    r = 2,
    b = 3,
}

local DirectionToMapRoad <const> = {
    [N] = RoadDirection.t,
    [E] = RoadDirection.r,
    [S] = RoadDirection.b,
    [W] = RoadDirection.l,
}

local function pack(x, y)
    return (y << 8)|x
end

local function buildingPostion(x, y, building, area)
    local direction = building.direction
    local w, h = area >> 8, area & 0xFF
    local dx, dy
    w = w - 1
    h = h - 1
    if direction == N then
        dx, dy = x, y
    elseif direction == E then
        dx, dy = h - y - 1, x
    elseif direction == S then
        dx, dy = w - x - 1, h - y - 1
    elseif direction == W then
        dx, dy = y, w - x - 1
    end
    assert((building.x + dx) % 2 == 0)
    assert((building.y + dy) % 2 == 0)
    return building.x + dx, building.y + dy
end

local function calc_roadbits(pt, direction)
    local bits = 0
    for _, c in ipairs(pt.crossing.connections) do
        local dir = (Direction[c.position[3]] + direction) % 4
        bits = bits | (1 << (DirectionToMapRoad[dir]))
    end
    return bits
end

local function rotateMask(mask, dir)
    return ((mask << dir) | (mask >> (4-dir))) & 0xF
end

function m.prototype_restore(world)
    roadbits_rev = setmetatable({}, mt)

    for _, pt in pairs(prototype.all()) do
        if is_roadid(pt) then
            for _, dir in pairs(pt.building_direction) do
                local bits = calc_roadbits(pt, Direction[dir])
                assert(rawget(roadbits_rev[pt.building_category], bits) == nil)
                roadbits_rev[pt.building_category][bits] = { prototype = pt.id, direction = Direction[dir] }
            end
        end
    end
end

local DIRTY_ROADNET <const> = 1 << 4

function m.build(world)
    local ecs = world.ecs

    if world._dirty & DIRTY_ROADNET == 0 then
        return
    end

    do
        local function getRoadMask(e)
            local building = e.building
            local pt = query(building.prototype)
            assert(#pt.road == 4)
            local x, y, mask = string.unpack("<I1I1I2", pt.road)
            assert(x == 0 and y == 0)
            return rotateMask(mask, building.direction)
        end
        local eid_cache = {}
        for v in ecs:select "road building:in eid:in" do
            local building = v.building
            local pt = query(building.prototype)
            local dx, dy = buildingPostion(0, 0, building, pt.area)
            local key = pack(dx, dy)
            eid_cache[key] = v.eid
        end
        for v in ecs:select "endpoint building:in eid:in" do
            local building = v.building
            local pt = query(building.prototype)
            for i = 1, #pt.road, 4 do
                local x, y, mask = string.unpack("<I1I1I2", pt.road, i)
                local dx, dy = buildingPostion(x, y, building, pt.area)
                local key = pack(dx, dy)
                local eid = eid_cache[key]
                if eid then
                    local e = assert(world.entity[eid])
                    local pt = prototype.queryById(e.building.prototype)
                    local f = roadbits_rev[pt.building_category][mask | getRoadMask(e)]
                    e.building.prototype = f.prototype
                    e.building.direction = f.direction
                    e.building_changed = true
                end
            end
        end
    end

    do
        local map = {}
        for v in ecs:select "road building:in" do
            local building = v.building
            local pt = query(building.prototype)
            for i = 1, #pt.road, 4 do
                local x, y, mask = string.unpack("<I1I1I2", pt.road, i)
                local dx, dy = buildingPostion(x, y, building, pt.area)
                local mapkey = pack(dx, dy)
                assert(not map[mapkey])
                map[mapkey] = rotateMask(mask, building.direction)
            end
        end
        for v in ecs:select "endpoint building:in" do
            local building = v.building
            local pt = query(building.prototype)
            local affected_roads_mask = 0
            if building.direction == N or building.direction == S then
                affected_roads_mask = MapRoad.NoVertical
            else
                affected_roads_mask = MapRoad.NoHorizontal
            end
            for i = 1, #pt.road, 4 do
                local x, y, mask = string.unpack("<I1I1I2", pt.road, i)
                local dx, dy = buildingPostion(x, y, building, pt.area)
                local mapkey = pack(dx, dy)
                if not map[mapkey] then
                    map[mapkey] = rotateMask(mask, building.direction)
                else
                    map[mapkey] = map[mapkey] | rotateMask(mask, building.direction) | affected_roads_mask
                end
            end
        end
        world:roadnet_reset(map)
    end
end
