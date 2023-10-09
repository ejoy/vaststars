local ecs   = ...
local world = ecs.world
local w     = world.w

local MOUNTAIN = import_package "vaststars.prototype"("mountain")
local ism = ecs.require "ant.landform|stone_mountain_system"
local terrain = ecs.require "terrain"

local UNIT <const> = 10
local WIDTH <const> = 256
local HEIGHT <const> = 256
local OFFSET <const> = WIDTH // 2
assert(OFFSET == HEIGHT // 2)

local MIN_X <const> = 1
local MAX_X <const> = WIDTH
local MIN_Y <const> = 1
local MAX_Y <const> = HEIGHT

local function coord2idx(x, y)
    return (MAX_Y - y) * (MAX_X - MIN_X + 1) + (x - MIN_X + 1)
end

local function idx2coord(v)
    local x = (v - 1) % (MAX_X - MIN_X + 1) + MIN_X
    local y = MAX_Y - math.floor((v - 1) // (MAX_X - MIN_X + 1))
    return x, y
end

local mt = {}
mt.__index = function (t, k)
    t[k] = setmetatable({}, mt)
    return t[k]
end

local M = {}
local cache = setmetatable({}, mt)

function M:create()
    local idx_string = ism.create_random_sm(MOUNTAIN.density, WIDTH, HEIGHT, OFFSET, UNIT)
    for key = 1, #idx_string do
        cache[key] = string.unpack("B", idx_string, key)
    end

    for _, v in ipairs(MOUNTAIN.excluded_rects) do
        local x1, y1, w, h = v[1], v[2], v[3], v[4]
        for x = x1, x1 + w - 1 do
            for y = y1, y1 + h - 1 do
                cache[coord2idx(x,y)] = 0
            end
        end
    end

    for _, v in ipairs(MOUNTAIN.mountain_coords) do
        local x1, y1, w, h = v[1], v[2], v[3], v[4]
        for x = x1, x1 + w - 1 do
            for y = y1, y1 + h - 1 do
                cache[coord2idx(x,y)] = 0
            end
        end
    end

    local t = {}
    for i = 1, WIDTH * HEIGHT do
        local x, y = idx2coord(i)
        if cache[i] == 1 then
            if x & 0xff ~= x or y & 0xff ~= y then
                t[i] = 0
            else
                t[i] = terrain:get_group_id(x, y)
            end
        end
    end

    ism.create_sm_entity(t)
end

function M:has_mountain(x, y)
    local key = coord2idx(x, y)
    return (cache[key] == 1)
end

return M