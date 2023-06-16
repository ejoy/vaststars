local ROAD_TILE_WIDTH_SCALE <const> = 2
local ROAD_TILE_HEIGHT_SCALE <const> = 2

local function pack(x, y)
    return (y << 8)|x
end

local function unpack(coord)
    return coord & 0xFF, coord >> 8
end

local function get(world, x, y, exclude_endpoint)
    local ecs = world.ecs
    local e = assert(ecs:first("road_cache:in"))
    local road_cache = e.road_cache
    x, y = x // ROAD_TILE_WIDTH_SCALE, y // ROAD_TILE_HEIGHT_SCALE
    local eid = road_cache[pack(x, y)]
    if not eid then
        return
    end

    local r = world.entity[eid]
    if exclude_endpoint and r.endpoint_road then
        return
    end
    return r.road.mask
end

local function set(world, x, y, classid, mask)
    assert(x % ROAD_TILE_WIDTH_SCALE == 0 and y % ROAD_TILE_HEIGHT_SCALE == 0)
    local ecs = world.ecs
    local e = assert(ecs:first("road_cache:in"))
    local road_cache = e.road_cache

    x, y = x // ROAD_TILE_WIDTH_SCALE, y // ROAD_TILE_HEIGHT_SCALE
    local key = pack(x, y)
    local eid = road_cache[key]
    if not eid then
        road_cache[key] = ecs:new {
            road = {
                x = x,
                y = y,
                mask = mask,
                classid = classid,
            },
            road_changed = true,
        }
    else
        local e = assert(world.entity[eid])
        e.road.classid = classid
        e.road.mask = mask
    end
end

local function remove(world, x, y)
    local ecs = world.ecs
    local e = assert(ecs:first("road_cache:in"))

    x, y = x // ROAD_TILE_WIDTH_SCALE, y // ROAD_TILE_HEIGHT_SCALE
    local eid = assert(e.road_cache[pack(x, y)])
    ecs:remove(eid)
end

local function all(world)
    local ecs = world.ecs
    local e = assert(ecs:first("road_cache:in"))

    local roads = {}
    for key, eid in pairs(e.road_cache) do
        local x, y = unpack(key)
        x, y = x * ROAD_TILE_WIDTH_SCALE, y * ROAD_TILE_HEIGHT_SCALE

        local r = assert(world.entity[eid])
        roads[pack(x, y)] = r.road.mask
    end
    return roads
end

return {
    all = all,
    get = get,
    set = set,
    remove = remove,
}
