local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local ROAD_SIZE <const> = CONSTANT.ROAD_SIZE

local gameplay_core = require "gameplay.core"
local ipick_object = {}
local objects = require "objects"
local icoord = require "coord"
local imountain = ecs.require "engine.mountain"
local iprototype = require "gameplay.interface.prototype"
local ilorry = ecs.require "render_updates.lorry"
local ibuilding = ecs.require "render_updates.building"
local imineral = ecs.require "mineral"

local pick_object_sys = ecs.system "pick_object_sys"
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

local function distance(x1, y1, x2, y2)
    return (x1 - x2) ^ 2 + (y1 - y2) ^ 2
end

local function get_lorry_pos(self)
    local lorry = ilorry.get(self.id)
    return lorry.objs[1].last_srt.t
end

local function convert(x, y)
    return x//2*2, y//2*2
end

local function push_objects(lorries, pick_x, pick_y, x, y, mark, blur)
    if blur then
        local lorry_ids = lorries[iprototype.packcoord(convert(x, y))]
        if lorry_ids then
            for _, lorry_id in ipairs(lorry_ids) do
                local lorry = ilorry.get(lorry_id)
                if lorry then
                    mark.lorry[lorry_id] = {
                        name = iprototype.queryById(lorry.classid).name,
                        get_pos = get_lorry_pos,
                        class = CLASS.Lorry,
                        id = lorry_id,
                        dist_x = x,
                        dist_y = y,
                        lorry = lorry,
                        eid = lorry_id,
                    }
                end
            end
        end
    end

    local o, id

    o = objects:coord(x, y)
    if o then
        local building = mark.building[o.id]
        if not building then
            mark.building[o.id] = {class = CLASS.Object, id = o.id, dist_x = x, dist_y = y, x = o.x, y = o.y, object = o, name = o.prototype_name}
        else
            if distance(pick_x, pick_y, x, y) < distance(pick_x, pick_y, building.dist_x, building.dist_y) then
                building.dist_x, building.dist_y = x, y
            end
        end
        return
    end

    o = ibuilding.get(convert(x, y))
    if o then
        local road = mark.road[o.eid]
        if not road then
            mark.road[o.eid] = {
                class = CLASS.Road,
                name = iprototype.queryByName(o.prototype).name,
                id = o.eid,
                dist_x = o.x,
                dist_y = o.y,
                x = o.x,
                y = o.y,
                w = ROAD_SIZE,
                h = ROAD_SIZE,
                get_pos = function(self)
                    return assert(icoord.position(self.x, self.y, self.w, self.h))
                end,
            }
        else
            if distance(pick_x, pick_y, x, y) < distance(pick_x, pick_y, road.dist_x, road.dist_y) then
                road.dist_x, road.dist_y = x, y
            end
        end
        return
    end

    o, id = imineral.get(x, y)
    if o then
        local mineral = mark.mineral[id]
        if not mineral then
            mark.mineral[id] = {class = CLASS.Mineral, id = id, dist_x = x, dist_y = y, x = x, y = y, name = o.mineral}
        else
            if distance(pick_x, pick_y, x, y) < distance(pick_x, pick_y, mineral.dist_x, mineral.dist_y) then
                mineral.dist_x, mineral.dist_y = x, y
            end
        end
        return
    end

    if imountain:has_mountain(x, y) then
        mark.mountain[iprototype.packcoord(x, y)] = {
            class = CLASS.Mountain,
            name = MountainName,
            id = iprototype.packcoord(x, y),
            dist_x = x,
            dist_y = y,
            x = x,
            y = y,
        }
        return
    end
end

function pick_object_sys:prototype_restore()
    MountainName = assert(iprototype.queryFirstByType("mountain")).name
end

function ipick_object.pick(x, y, blur)
    if last_x ~= x and last_y ~= y then
        last_x, last_y = x, y
        pointer = 0
    end

    local gameplay_world = gameplay_core.get_world()

    local lorries = {}
    for e in gameplay_world.ecs:select "lorry:in eid:in" do
        local lorry = e.lorry
        if lorry.prototype == 0 then
            goto continue
        end
        local coord = iprototype.packcoord(convert(lorry.x, lorry.y))
        lorries[coord] = lorries[coord] or {}
        lorries[coord][#lorries[coord] + 1] = e.eid
        ::continue::
    end

    local objs = {}
    local mark = setmetatable({}, mt) -- Avoid adding duplicate objects
    push_objects(lorries, x, y, x, y, mark, blur)

    for _, v in pairs(mark) do
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
    -- log.info("pick", #objs, pointer)
    return objs[pointer]
end

return ipick_object
