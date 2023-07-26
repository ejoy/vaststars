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
local pick_object_sys = ecs.system "pick_object_sys"
local ROAD_TILE_SCALE_WIDTH <const> = 2
local ROAD_TILE_SCALE_HEIGHT <const> = 2

local MountainName = ""

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

local function get_pos(self)
    local lorry = ilorry.get(self.id)
    return lorry.objs[1].last_srt.t
end

local function __push_object(lorries, pick_x, pick_y, x, y, status)
    local lorry_ids = lorries[__pack(x, y)]
    if lorry_ids then
        for _, lorry_id in ipairs(lorry_ids) do
            local lorry = ilorry.get(lorry_id)
            if lorry then
                status.lorry[lorry_id] = {
                    class = CLASS.Lorry,
                    name = iprototype.queryById(lorry.classid).name,
                    id = lorry_id,
                    dist_x = x,
                    dist_y = y,
                    lorry = lorry,
                    get_pos = get_pos,
                }
            end
        end
    end

    local o, id

    o = objects:coord(x, y)
    if o then
        local building = status.building[o.id]
        if not building then
            status.building[o.id] = {class = CLASS.Object, id = o.id, dist_x = x, dist_y = y, x = x, y = y, object = o, name = o.prototype_name}
        else
            if __distance(pick_x, pick_y, x, y) < __distance(pick_x, pick_y, building.dist_x, building.dist_y) then
                building.dist_x, building.dist_y = x, y
            end
        end
    end

    o, id = terrain:get_mineral(x, y)
    if o then
        local mineral = status.mineral[id]
        if not mineral then
            status.mineral[id] = {class = CLASS.Mineral, id = id, dist_x = x, dist_y = y, x = x, y = y, name = o.mineral}
        else
            if __distance(pick_x, pick_y, x, y) < __distance(pick_x, pick_y, mineral.dist_x, mineral.dist_y) then
                mineral.dist_x, mineral.dist_y = x, y
            end
        end
    end

    if imountain:has_mountain(x, y) then
        status.mountain[__pack(x, y)] = {
            class = CLASS.Mountain,
            name = MountainName,
            id = __pack(x, y),
            dist_x = x,
            dist_y = y,
            x = x,
            y = y,
        }
    end

    o = ibuilding.get(x, y)
    if o then
        local road = status.road[o.eid]
        if not road then
            status.road[o.eid] = {
                class = CLASS.Road,
                name = iprototype.queryByName(o.prototype).name,
                id = o.eid,
                dist_x = o.x,
                dist_y = o.y,
                x = o.x,
                y = o.y,
                w = ROAD_TILE_SCALE_WIDTH,
                h = ROAD_TILE_SCALE_HEIGHT,
                get_pos = function(self)
                    return assert(terrain:get_position_by_coord(self.x, self.y, self.w, self.h))
                end,
            }
        else
            if __distance(pick_x, pick_y, x, y) < __distance(pick_x, pick_y, road.dist_x, road.dist_y) then
                road.dist_x, road.dist_y = x, y
            end
        end
    end
end

function pick_object_sys:prototype_restore()
    MountainName = assert(iprototype.queryFirstByType("mountain")).name
end

function ipick_object.pick_road(x, y)
    local o = assert(ibuilding.get(x, y))
    return {
        class = CLASS.Road,
        name = iprototype.queryByName(o.prototype).name,
        id = o.eid,
        dist_x = o.x,
        dist_y = o.y,
        x = o.x,
        y = o.y,
        w = ROAD_TILE_SCALE_WIDTH,
        h = ROAD_TILE_SCALE_HEIGHT,
        get_pos = function(self)
            return assert(terrain:get_position_by_coord(self.x, self.y, self.w, self.h))
        end,
    }
end

function ipick_object.pick_obj(x, y)
    local o = objects:coord(x, y)
    if o then
        local typeobject = iprototype.queryByName(o.prototype_name)
        local w, h = iprototype.unpackarea(typeobject.area)
        return {
            class = CLASS.Object,
            name = o.prototype_name,
            id = o.id,
            dist_x = x,
            dist_y = y,
            object = o,
            x = x,
            y = y,
            w = w,
            h = h,
            get_pos = function(self)
                return assert(terrain:get_position_by_coord(self.x, self.y, self.w, self.h))
            end,
        }
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
        local dist_a = (a.dist_x - x) ^ 2 + (a.dist_y - y) ^ 2
        local dist_b = (b.dist_x - x) ^ 2 + (b.dist_y - y) ^ 2
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
