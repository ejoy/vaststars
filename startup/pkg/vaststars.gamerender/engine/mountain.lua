local ecs   = ...
local world = ecs.world
local w     = world.w

-- local MOUNTAIN <const> = ecs.require "vaststars.prototype|mountain"
local CONST <const> = require "gameplay.interface.constant"
local WIDTH <const>, HEIGHT<const> = CONST.MAP_WIDTH_COUNT, CONST.MAP_HEIGHT_COUNT

local im = ecs.require "ant.landform|stone_mountain_system"
local icoord = require "coord"
local igroup = ecs.require "group"
local MOUNTAIN_MASKS
local MOUNTAIN_MATERIAL <const> = "/pkg/vaststars.resources/materials/mountain/mountain.material"
local CS_MATERIAL <const> = "/pkg/vaststars.resources/materials/mountain/mountain_compute.material"
local MOUNTAIN_MESHBINS = {
    "/pkg/vaststars.resources/glbs/mountain/mountain1.glb|meshes/Cylinder.002_P1.meshbin",
    "/pkg/vaststars.resources/glbs/mountain/mountain2.glb|meshes/Cylinder.004_P1.meshbin",
    "/pkg/vaststars.resources/glbs/mountain/mountain3.glb|meshes/Cylinder_P1.meshbin",
    "/pkg/vaststars.resources/glbs/mountain/mountain4.glb|meshes/Cylinder.021_P1.meshbin",
} 
local function set_masks(masks, r, v)
    -- x, y base 0
    local x0, y0, ww, hh = r[1], r[2], r[3], r[4]

    --range:[x1, x1+ww), [y1, y+hh)
    for x=x0, x0+ww-1 do
        for y=y0, y0+hh-1 do
            masks[icoord.coord2idx(x, y)] = v
        end
    end
end

local function build_mountain_masks(mountain_cfg)
    local masks = im.create_random_sm(WIDTH, HEIGHT)

    for _, v in ipairs(mountain_cfg.excluded_rects) do
        set_masks(masks, v, 0)
    end

    for _, v in ipairs(mountain_cfg.mountain_coords) do
        set_masks(masks, v, 1)
    end
    return masks
end

local function merge_indices(indices, width, height, range)
    local m = {}
    for iz=0, height-1 do
        for ix=0, width-1 do
            local idx = iz*width+ix

            local function is_sub_range(baseidx, range)
                for izz=0, range-1 do
                    for ixx=0, range-1 do
                        local sidx = baseidx + izz * width + ixx
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

local function build_sub_indices(MASKS)
    local masks = {}
    for k, v in pairs(MASKS) do masks[k]=v end

    local subindices = {}
    for range=4, 2, -1 do
        local m = merge_indices(masks, WIDTH, HEIGHT, range)
        for _, info in ipairs(m) do
            subindices[info.baseidx] = info
            local x, y = icoord.idx2coord(info.baseidx)
            set_masks(masks, {x, y, info.sidx, info.sidx}, 0)
        end
    end

    for idx, mask in pairs(masks) do
        if 0 ~= mask then
            subindices[idx] = {sidx=1, baseidx=idx}
        end
    end
    return subindices
end

local function idxoffset(baseidx, sidx)
    local subidx = sidx // 2
    return baseidx + subidx*WIDTH+subidx
end

local M = {}
function M:init(mountain_cfg)
    MOUNTAIN_MASKS = build_mountain_masks(mountain_cfg)
    local subindices = build_sub_indices(MOUNTAIN_MASKS)

    local groups = setmetatable({}, {__index=function (t, gid) local tt={}; t[gid]=tt; return tt end})

    for baseidx, info in pairs(subindices) do
        local sidx = info.sidx
        local idx = idxoffset(baseidx, sidx)

        local x0, y0 = icoord.idx2coord(idx)
        assert(0<=x0 and x0<WIDTH and 0<=y0 and y0<HEIGHT)
        local indices = groups[igroup.id(x0, y0)]
        indices[#indices+1] = {coord = {x0, y0}, pos = icoord.lefttop_position(x0, y0), sidx=sidx}
    end

    im.create(groups, MOUNTAIN_MATERIAL, CS_MATERIAL, MOUNTAIN_MESHBINS)
end

function M:has_mountain(x, y)
    local idx = icoord.coord2idx(x, y)
    return (0 ~= assert(MOUNTAIN_MASKS[idx], ("Invalid x:%d, y:%d, idx"):format(x, y, idx)))
end

return M