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

    local groups = setmetatable({}, {__index=function (t, gid) local tt={}; t[gid]=tt; return tt end})
    for i = 1, WIDTH * HEIGHT do
        if 0 ~= MOUNTAIN_MASKS[i] then
            local x, y = idx2coord(i)
            assert(1<=x and x<=WIDTH and 1<=y and y<=HEIGHT)
            local indices = groups[terrain:get_group_id(x, y)]
            indices[#indices+1] = i
        end
    end

    local groups2 = {
        -- [5] = {coord2idx(130, 123)},
        -- [6] = {coord2idx(100, 116), coord2idx(98, 114)},
        -- [9] = {coord2idx(103, 115), coord2idx(107, 115), coord2idx(109, 115)},
        [11] = {coord2idx(106, 133), coord2idx(105, 135), coord2idx(105, 136), coord2idx(107, 137)},
        -- [12] = {coord2idx(116, 116), coord2idx(112, 115), coord2idx(120, 115)},
        -- [13] = {coord2idx(120, 125), coord2idx(114, 128)},
        -- [14] = {coord2idx(116, 137)},
        -- [15] = {coord2idx(130, 115)},
        -- [16] = {coord2idx(121, 137), coord2idx(126, 137), coord2idx (129, 136)},
        -- [17] = {coord2idx(131, 115)},
        -- [18] = {coord2idx(138, 123), coord2idx(132, 123)},
        -- [19] = {coord2idx(133, 135)},
        -- [20] = {coord2idx(141, 115), coord2idx(146, 115)},
        -- [21] = {coord2idx(142, 122)},
    }

    im.create(groups2, WIDTH, HEIGHT, OFFSET, UNIT)
end

function M:has_mountain(x, y)
    local idx = coord2idx(x, y)
    return (assert(MOUNTAIN_MASKS[idx], ("Invalid x:%d, y:%d, idx"):format(x, y, idx)) == 1)
end

return M