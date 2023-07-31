local ecs   = ...
local world = ecs.world
local w     = world.w

local MOUNTAIN = import_package "vaststars.prototype".load("mountain")
local ism = ecs.import.interface "mod.stonemountain|istonemountain"
local terrain = ecs.require "terrain"

local UNIT <const> = 10
local BORDER <const> = 5
local MAP_WIDTH <const> = 256
local MAP_HEIGHT <const> = 256
local WIDTH <const> = MAP_WIDTH + BORDER * 2
local HEIGHT <const> = MAP_HEIGHT + BORDER * 2
local OFFSET <const> = WIDTH // 2
assert(OFFSET == HEIGHT // 2)

local MIN_X <const> = -BORDER + 1
local MAX_X <const> = MAP_WIDTH + BORDER
local MIN_Y <const> = -BORDER + 1
local MAX_Y <const> = MAP_HEIGHT + BORDER

-- local function __coord2idx(x, y)
--     return (MAX_Y - y) * (MAX_X - MIN_X + 1) + (x - MIN_X + 1)
-- end

local function __idx2coord(v)
    local x = (v - 1) % (MAX_X - MIN_X + 1) + MIN_X
    local y = MAX_Y - math.floor((v - 1) / (MAX_X - MIN_X + 1))
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
    for i = 1, #idx_string do
        local c = string.unpack("B", idx_string, i)
        local x, y = __idx2coord(i)
        cache[x][y] = c
    end

    for _, v in ipairs(MOUNTAIN.excluded_rects) do
        local x1, y1, w, h = v[1], v[2], v[3], v[4]
        for x = x1, x1 + w - 1 do
            for y = y1, y1 + h - 1 do
                cache[x][y] = 0
            end
        end
    end

    for _, v in ipairs(MOUNTAIN.mountain_coords) do
        local x1, y1, w, h = v[1], v[2], v[3], v[4]
        for x = x1, x1 + w - 1 do
            for y = y1, y1 + h - 1 do
                cache[x][y] = 1
            end
        end
    end

    local t = {}
    for i = 1, WIDTH * HEIGHT do
        local x, y = __idx2coord(i)
        if cache[x][y] == 1 then
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
    return (cache[x][y] == 1)
end

return M