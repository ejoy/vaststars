local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local ipick_object = ecs.interface "ipick_object"
local objects = require "objects"
local terrain = ecs.require "terrain"
local imountain = ecs.require "engine.mountain"
local iprototype = require "gameplay.interface.prototype"
local ilorry = ecs.import.interface "vaststars.gamerender|ilorry"
local ibuilding = ecs.import.interface "vaststars.gamerender|ibuilding"

local CLASS = {
    Lorry = 1,
    Object = 2,
    Mineral = 3,
    Mountain = 4,
    Road = 5,
}

local mt = {}
mt.__index = function (t, k)
    t[k] = {}
    return t[k]
end

local pointer = 0
local last_x, last_y

local function __pack(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function __distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

local function __push_object(lorries, pick_x, pick_y, x, y, status)
    local lorry_ids = lorries[__pack(x, y)]
    if lorry_ids then
        for _, lorry_id in ipairs(lorry_ids) do
            local lorry = ilorry.get(lorry_id)
            if lorry then
                status.lorry[lorry_id] = {class = CLASS.Lorry, id = lorry_id, x = x, y = y, lorry = lorry}
            end
        end
    end

    local o, id

    o = objects:coord(x, y)
    if o then
        local building = status.building[o.id]
        if not building then
            status.building[o.id] = {class = CLASS.Object, id = o.id, x = x, y = y, object = o}
        else
            if __distance(pick_x, pick_y, x, y) < __distance(pick_x, pick_y, building.x, building.y) then
                building.x, building.y = x, y
            end
        end
    end

    o, id = terrain:get_mineral(x, y)
    if o then
        local mineral = status.mineral[o.id]
        if not mineral then
            status.mineral[id] = {class = CLASS.Mineral, id = id, x = x, y = y, mineral = o}
        else
            if __distance(pick_x, pick_y, x, y) < __distance(pick_x, pick_y, mineral.x, mineral.y) then
                mineral.x, mineral.y = x, y
            end
        end
    end

    id = imountain:get_mountain(x, y)
    if id then
        status.mountain[id] = {class = CLASS.Mountain, id = id, x = x, y = y, mountain = assert(iprototype.queryFirstByType("mountain")).name}
    end

    o = ibuilding.get(x, y)
    if o then
        status.road[o.eid] = {class = CLASS.Road, id = o.eid, x = o.x, y = o.y, prototype_name = iprototype.queryByName(o.prototype).name}
    end
end

function ipick_object.blur_pick(x, y)
    if last_x ~= x and last_y ~= y then
        last_x, last_y = x, y
        pointer = 0
    end

    local gameplay_world = gameplay_core.get_world()

    local dx, dy
    local lorries = {}
    for e in gameplay_world.ecs:select "lorry:in eid:in" do
        local lorry = e.lorry
        local classid = lorry.prototype
        if classid == 0 then
            goto continue
        end
        dx, dy = e.lorry.x, e.lorry.y
        local coord = __pack(dx, dy)
        lorries[coord] = lorries[coord] or {}
        lorries[coord][#lorries[coord] + 1] = e.eid
        ::continue::
    end

    local objs = {}
    local status = setmetatable({}, mt)
    for dx = x - 1, x + 1 do
        for dy = y - 1, y + 1 do
            if dx & 0xFF == dx and dy & 0xFF == dy then
                __push_object(lorries, x, y, dx, dy, status)
            end
        end
    end
    for _, v in pairs(status) do
        for _, obj in pairs(v) do
            objs[#objs + 1] = obj
        end
    end
    table.sort(objs, function(a, b)
        local dist_a = (a.x - x) ^ 2 + (a.y - y) ^ 2
        local dist_b = (b.x - x) ^ 2 + (b.y - y) ^ 2
        if dist_a ~= dist_b then
            return dist_a < dist_b
        else
            if a.class == b.class then
                return a.id < b.id
            else
                return a.class < b.class
            end
        end
    end)

    if #objs > 0 then
        pointer = pointer + 1
        if pointer > #objs then
            pointer = 1
        end
    end
    -- log.info("blur_pick", #objs, pointer)
    return objs[pointer]
end
