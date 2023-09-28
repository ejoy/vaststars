local ecs   = ...
local world = ecs.world
local w     = world.w

local ism = ecs.require "ant.landform|stone_mountain_system"
local terrain = ecs.require "terrain"

local MOUNTAIN = import_package "vaststars.prototype"("mountain")
local CONSTANT <const> = require("gameplay.interface.constant")
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local MAP_WIDTH <const> = CONSTANT.MAP_WIDTH
local MAP_HEIGHT <const> = CONSTANT.MAP_HEIGHT
local OFFSET <const> = MAP_WIDTH // 2
assert(OFFSET == MAP_HEIGHT // 2)

local MIN_X <const> = 1
local MAX_X <const> = MAP_WIDTH
local MIN_Y <const> = 1
local MAX_Y <const> = MAP_HEIGHT

local function coord2idx(x, y)
    return (MAX_Y - y) * (MAX_X - MIN_X + 1) + (x - MIN_X + 1)
end

local function idx2coord(v)
    local x = (v - 1) % (MAX_X - MIN_X + 1) + MIN_X
    local y = MAX_Y - math.floor((v - 1) // (MAX_X - MIN_X + 1))
    return x, y
end

local MOUNTAIN_MASKS
local M = {}
function M:create()
    local idx_string = ism.create_random_sm(MOUNTAIN.density, MAP_WIDTH, MAP_HEIGHT, OFFSET, TILE_SIZE)
    for key = 1, #idx_string do
        cache[key] = string.unpack("B", idx_string, key)
    end

    for _, v in ipairs(MOUNTAIN.excluded_rects) do
        local x1, y1, w, h = v[1], v[2], v[3], v[4]
        for x = x1, x1 + w - 1 do
            for y = y1, y1 + h - 1 do
                MOUNTAIN_MASKS[coord2idx(x,y)] = 0
            end
        end
    end

    for _, v in ipairs(MOUNTAIN.mountain_coords) do
        local x1, y1, w, h = v[1], v[2], v[3], v[4]
        for x = x1, x1 + w - 1 do
            for y = y1, y1 + h - 1 do
                MOUNTAIN_MASKS[coord2idx(x,y)] = 0
            end
        end
    end

    local t = {}
    for i = 1, MAP_WIDTH * MAP_HEIGHT do
        local x, y = idx2coord(i)
        if cache[i] == 1 then
            if x & 0xff ~= x or y & 0xff ~= y then
                t[i] = 0
            else
                t[i] = terrain:get_group_id(x, y)
            end
        end
    end

    im.create(groups, OFFSET, UNIT)
end

function M:has_mountain(x, y)
    local idx = coord2idx(x, y)
    return (assert(MOUNTAIN_MASKS[idx], ("Invalid x:%d, y:%d, idx"):format(x, y, idx)) == 1)
end

return M