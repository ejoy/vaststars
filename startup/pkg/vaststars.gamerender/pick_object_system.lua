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

local function __push_object(lorries, x, y, objs, duplicates)
    local lorry_ids = lorries[__pack(x, y)]
    if lorry_ids then
        for _, lorry_id in ipairs(lorry_ids) do
            local lorry = ilorry.get(lorry_id)
            if lorry then
                objs[#objs + 1] = {class = CLASS.Lorry, id = lorry_id, lorry = lorry, x = x, y = y}
            end
        end
    end

    local o

    o = objects:coord(x, y)
    if o and not duplicates[o.id] then
        objs[#objs + 1] = {class = CLASS.Object, id = o.id, object = o, x = x, y = y}
        duplicates[o.id] = true
    end

    o = terrain:get_mineral(x, y)
    if o then
        objs[#objs + 1] = {class = CLASS.Mineral, id = math.maxinteger, mineral = o, x = x, y = y}
    end

    if imountain:has_mountain(x, y) then
        objs[#objs + 1] = {class = CLASS.Mountain, id = math.maxinteger, mountain = assert(iprototype.queryFirstByType("mountain")).name, x = x, y = y}
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
    for e in gameplay_world.ecs:select "lorry:in eid:in" do
        local lorry = e.lorry
        local classid = lorry.classid
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
    local duplicates = {}
    for dx = x - 1, x + 1 do
        for dy = y - 1, y + 1 do
            objs = __push_object(lorries, dx, dy, objs, duplicates)
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
