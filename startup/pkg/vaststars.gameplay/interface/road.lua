local function get_road(world, x, y)
    local ecs = world.ecs
    local e = assert(ecs:first("road_cache:in"))
    local road_cache = e.road_cache
    x, y = x // 2, y // 2
    local key = (y << 8)|x
    local eid = road_cache[key]
    if not eid then
        return
    end
    local e = assert(world.entity[eid])
    return e.road.mask
end

local function set_road(world, x, y, prototype, mask)
    assert(x % 2 == 0 and y % 2 == 0)
    local ecs = world.ecs
    local e = assert(ecs:first("road_cache:in"))
    local road_cache = e.road_cache
    x, y = x // 2, y // 2
    local key = (y << 8)|x
    local eid = road_cache[key]
    if not eid then
        road_cache[key] = ecs:new {
            road = {
                x = x,
                y = y,
                prototype = prototype,
                mask = mask,
            },
            road_changed = true,
        }
    else
        local e = assert(world.entity[eid])
        e.road.mask = mask
        e.road.prototype = prototype
    end
end

local function get(world)
    local ecs = world.ecs
    local e = assert(ecs:first("road_cache:in"))
    local road_cache = e.road_cache
    local roads = {}

    for key, eid in pairs(road_cache) do
        local x, y = key & 0xff, key >> 8
        x, y = x * 2, y * 2
        local e = assert(world.entity[eid])
        roads[(y << 8) | x] = e.road.mask
    end
    return roads
end

return {
    get = get,
    get_road = get_road,
    set_road = set_road,
}
