local ecs   = ...
local world = ecs.world
local w     = world.w

local ism = ecs.require "ant.landform|stone_mountain_system"
local terrain = ecs.require "terrain"

--local WIDTH, HEIGHT = terrain:grid_size()
--TODO: WIDTH and HEIGHT should get from terrain, and idx2coord/coord2idx should provide from terrain
local WIDTH<const>, HEIGHT<const> = 256, 256

local MOUNTAIN_MASKS
local M = {}
function M:create()
    --if true then return end
    MOUNTAIN_MASKS = im.create_random_sm(WIDTH, HEIGHT)

    local function set_masks(r, v)
        -- x, y base 0
        local x0, y0, ww, hh = r[1], r[2], r[3], r[4]
        --base 1
        local x1, y1 = x0+1, y0+1

        --range:[x1, x1+ww), [y1, y+hh)
        for x=x1, x1+ww-1 do
            for y=y1, y1+hh-1 do
                MOUNTAIN_MASKS[im.coord2idx(x, y, WIDTH)] = v
            end
        end
    end

    for _, v in ipairs(MOUNTAIN.excluded_rects) do
        set_masks(v, 0)
    end

    for _, v in ipairs(MOUNTAIN.mountain_coords) do
        set_masks(v, 1)
    end

    local groups = setmetatable({}, {__index=function (t, gid) local tt={}; t[gid]=tt; return tt end})
    for i = 1, WIDTH * HEIGHT do
        if 0 ~= MOUNTAIN_MASKS[i] then
            local x, y = im.idx2coord(i, WIDTH)
            assert(1<=x and x<=WIDTH and 1<=y and y<=HEIGHT)
            local x0, y0 = x-1, y-1
            local indices = groups[terrain:get_group_id(x0, y0)]
            indices[#indices+1] = {coord = {x, y}, pos = terrain:get_begin_position_by_coord(x0, y0)}
        end
    end

    im.create(groups, WIDTH, HEIGHT)
end

function M:has_mountain(x, y)
    local idx = im.coord2idx(x, y, WIDTH)
    return (0 ~= assert(MOUNTAIN_MASKS[idx], ("Invalid x:%d, y:%d, idx"):format(x, y, idx)))
end

return M