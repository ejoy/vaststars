local ecs   = ...
local world = ecs.world
local w     = world.w

local im = ecs.require "ant.landform|stone_mountain_system"
local MOUNTAIN = import_package "vaststars.prototype"("mountain")
local terrain = ecs.require "terrain"

local CONST<const> = require "gameplay.interface.constant"
local WIDTH<const>, HEIGHT<const> = CONST.MAP_WIDTH, CONST.MAP_HEIGHT

local MOUNTAIN_MASKS

local function set_masks(masks, r, v)
    -- x, y base 0
    local x0, y0, ww, hh = r[1], r[2], r[3], r[4]
    --base 1
    local x1, y1 = x0+1, y0+1

    --range:[x1, x1+ww), [y1, y+hh)
    for x=x1, x1+ww-1 do
        for y=y1, y1+hh-1 do
            masks[terrain:coord2idx1(x, y, WIDTH)] = v
        end
    end
end

local function build_mountain_masks()
    local masks = im.create_random_sm(WIDTH, HEIGHT)

    for _, v in ipairs(MOUNTAIN.excluded_rects) do
        set_masks(masks, v, 0)
    end

    for _, v in ipairs(MOUNTAIN.mountain_coords) do
        set_masks(masks, v, 1)
    end
    return masks
end

local function merge_indices(indices, width, height, range)
    local m = {}
    for iz=1, height, range do
        for ix=1, width, range do
            local idx = (iz-1)*width+ix

            local function is_sub_range(baseidx, range)
                for izz=1, range do
                    for ixx=1, range do
                        local sidx = baseidx + (izz-1) * width + ixx
                        if indices[sidx] == 0 then
                            return false
                        end
                    end
                end
                return true
            end

            if is_sub_range(idx, range) then
                m[#m+1] = {sidx=range, baseidx=idx}
            end
        end
    end
    return m
end

local function build_sub_indices(masks)
    local subindices = {}
    for range=4, 2, -1 do
        local m = merge_indices(masks, WIDTH, HEIGHT, range)
        for _, info in ipairs(m) do
            subindices[info.baseidx] = info
            local x, y = terrain:idx2coord(info.baseidx-1, WIDTH)
            set_masks(masks, {x-1, y-1, info.sidx, info.sidx}, 1)
        end
    end

    for idx, mask in ipairs(masks) do
        if 0 ~= mask then
            subindices[idx] = {sidx=1, baseidx=idx}
        end
    end
    return subindices
end

local function idxoffset(baseidx, sidx)
    local subidx = (sidx // 2)+1
    return baseidx + (subidx-1)*WIDTH+subidx
end

local M = {}
function M:create()
    --if true then return end
    local masks = build_mountain_masks()

    local subindices = build_sub_indices(masks);

    local groups = setmetatable({}, {__index=function (t, gid) local tt={}; t[gid]=tt; return tt end})

    for baseidx, info in pairs(subindices) do
        local sidx = info.sidx
        local idx = idxoffset(baseidx, sidx)

        local x, y = terrain:idx2coord1(idx, WIDTH)
        assert(1<=x and x<=WIDTH and 1<=y and y<=HEIGHT)
        local x0, y0 = x-1, y-1
        local indices = groups[terrain:get_group_id(x0, y0)]
        indices[#indices+1] = {coord = {x, y}, pos = terrain:get_begin_position_by_coord(x0, y0), sidx=sidx}
    end

    im.create(groups, WIDTH, HEIGHT)
end

function M:has_mountain(x, y)
    local idx = terrain:coord2idx(x, y, WIDTH)
    return (0 ~= assert(MOUNTAIN_MASKS[idx], ("Invalid x:%d, y:%d, idx"):format(x, y, idx)))
end

return M