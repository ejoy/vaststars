local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local pick_object_sys = ecs.system "pick_object_sys"
local ipick_object = ecs.interface "ipick_object"
local objects = require "objects"
local terrain = ecs.require "terrain"
local imountain = ecs.require "engine.mountain"
local iprototype = require "gameplay.interface.prototype"
local ilorry = ecs.import.interface "vaststars.gamerender|ilorry"

local ROAD_TILE_WIDTH_SCALE <const> = 2
local ROAD_TILE_HEIGHT_SCALE <const> = 2
local CLASS = {
    Lorry = 1,
    Object = 2,
    Mineral = 3,
    Mountain = 4,
}

local pointer = 0
local last_x, last_y

function pick_object_sys:update_world()

end

local function __pack(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function __push_object(lorries, x, y, objs)
    local lorry_ids = lorries[__pack(x, y)]
    if lorry_ids then
        for _, lorry_id in ipairs(lorry_ids) do
            local lorry = ilorry.get(lorry_id)
            if lorry then
                objs[#objs + 1] = {class = CLASS.Lorry, id = lorry_id, lorry = lorry}
            end
        end
    end

    local o

    o = objects:coord(x, y)
    if o then
        objs[#objs + 1] = {class = CLASS.Object, id = o.id, object = o}
    end

    o = terrain:get_mineral(x, y)
    if o then
        objs[#objs + 1] = {class = CLASS.Mineral, id = math.maxinteger, mineral = o}
    end

    if imountain:has_mountain(x, y) then
        objs[#objs + 1] = {class = CLASS.Mountain, id = math.maxinteger, mountain = assert(iprototype.queryFirstByType("mountain")).name}
    end

    return objs
end

function ipick_object.blur_pick(x, y)
    if last_x ~= x and last_y ~= y then
        last_x, last_y = x, y
        pointer = 0
    end

    local gameplay_world = gameplay_core.get_world()

    local dx, dy
    local lorries = {}
    for lorry_id, classid, item_classid, item_amount, mc, progress, maxprogress in gameplay_world:roadnet_each_lorry() do
        dx, dy = mc & 0xFF, (mc >> 8) & 0xFF
        dx, dy = dx * ROAD_TILE_WIDTH_SCALE, dy * ROAD_TILE_HEIGHT_SCALE
        local coord = __pack(dx, dy)
        lorries[coord] = lorries[coord] or {}
        lorries[coord][#lorries[coord] + 1] = lorry_id
    end

    local objs = {}
    objs = __push_object(lorries, x, y, objs)
    if pointer == 0 and #objs > 0 then
        pointer = pointer + 1
        return objs[1]
    end

    for dx = x - 1, x + 1 do
        for dy = y - 1, y + 1 do
            if dx ~= x or dy ~= y then
                objs = __push_object(lorries, dx, dy, objs)
            end
        end
    end
    table.sort(objs, function(a, b)
        if a.class == b.class then
            return a.id < b.id
        else
            return a.class < b.class
        end
    end)

    if #objs > 0 then
        pointer = ((pointer + 1) % #objs) + 1
    end
    return objs[pointer]
end
