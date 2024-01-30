local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local RENDER_LAYER <const> = ecs.require "engine.render_layer".RENDER_LAYER
local MAP_WIDTH_COUNT <const> = CONSTANT.MAP_WIDTH_COUNT
local MAP_HEIGHT_COUNT <const> = CONSTANT.MAP_HEIGHT_COUNT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local MAP_BORDER_WIDTH_COUNT <const> = 8
local MAP_BORDER_HEIGHT_COUNT <const> = 8
assert(MAP_WIDTH_COUNT % MAP_BORDER_WIDTH_COUNT == 0 and MAP_HEIGHT_COUNT % MAP_BORDER_HEIGHT_COUNT == 0)
local MAP_BORDER_CHUNK_WIDTH_SIZE <const> = MAP_BORDER_WIDTH_COUNT * TILE_SIZE
local MAP_BORDER_CHUNK_HEIGHT_SIZE <const> = MAP_BORDER_HEIGHT_COUNT * TILE_SIZE
assert(MAP_BORDER_CHUNK_WIDTH_SIZE == MAP_BORDER_CHUNK_HEIGHT_SIZE)
local MAP_BORDER_SIZE <const> = MAP_BORDER_CHUNK_WIDTH_SIZE

local TERRAIN_MATERIAL <const> = "/pkg/vaststars.resources/materials/terrain/plane_terrain.material"
local BORDER_MATERIAL <const> = "/pkg/vaststars.resources/materials/terrain/border.material"

local igroup = ecs.require "group"
local MAP_CHUNK_WIDTH_COUNT, MAP_CHUNK_HEIGHT_COUNT = igroup.map_chunk_wh()
assert(MAP_CHUNK_WIDTH_COUNT == MAP_CHUNK_HEIGHT_COUNT)
local MAP_CHUNK_SIZE <const> = MAP_CHUNK_WIDTH_COUNT * TILE_SIZE

local mathpkg = import_package "ant.math"
local mu = mathpkg.util

local icoord = ecs.require "coord"

local ORIGIN <const> = icoord.origin_position()
local ipt = ecs.require "ant.landform|plane_terrain"

local M = {}

local function GID_CACHE() return setmetatable({}, {__index=function(t, gid) local gg = {} t[gid] = gg return gg end}) end

local function create_plane_in_groups()
    local t = GID_CACHE()
    for x = 0, MAP_WIDTH_COUNT - 1, MAP_CHUNK_WIDTH_COUNT do
        for y = 0, MAP_HEIGHT_COUNT - 1, MAP_CHUNK_HEIGHT_COUNT do
            local position = assert(icoord.lefttop_position(x, y))
            local gid = igroup.id(x, y)

            local tt = t[gid]
            tt[#tt+1] = {x = position[1], y = position[3] - MAP_CHUNK_SIZE}
        end
    end

    ipt.create_plane_terrain(t, RENDER_LAYER.TERRAIN, MAP_CHUNK_SIZE, TERRAIN_MATERIAL)
end

local function create_border_in_groups()
    local b = GID_CACHE()

    local BORDER_MINX, BORDER_MAXX = ORIGIN[1] - MAP_BORDER_CHUNK_WIDTH_SIZE, ORIGIN[1] + (MAP_BORDER_CHUNK_WIDTH_SIZE * (MAP_WIDTH_COUNT // MAP_BORDER_WIDTH_COUNT))
    local BORDER_MINY, BORDER_MAXY = ORIGIN[2] - (MAP_HEIGHT_COUNT * TILE_SIZE), ORIGIN[2] - MAP_BORDER_CHUNK_HEIGHT_SIZE

    local function which_border_group(x, y)
        local coordxy = icoord.posxy2coord_nocheck(x, y)
        local tx = mu.clamp(coordxy[1], 0, MAP_WIDTH_COUNT-1)
        local ty = mu.clamp(coordxy[2], 0, MAP_HEIGHT_COUNT-1)

        return igroup.id(tx, ty)
    end

    local function add_border(x, y)
        local gid = which_border_group(x, y)
        local bb = b[gid]
        bb[#bb+1] = {x = x, y = y}
    end

    -- top and bottom borders
    for x = BORDER_MINX, BORDER_MAXX, MAP_BORDER_CHUNK_WIDTH_SIZE do
        add_border(x, ORIGIN[2])  -- top
        add_border(x, ORIGIN[2] - (MAP_HEIGHT_COUNT * TILE_SIZE + MAP_BORDER_CHUNK_HEIGHT_SIZE)) -- bottom
    end

    -- left and right borders
    for y = BORDER_MINY, BORDER_MAXY, MAP_BORDER_CHUNK_HEIGHT_SIZE do
        add_border(ORIGIN[1] - MAP_BORDER_CHUNK_WIDTH_SIZE, y) -- left
        add_border(ORIGIN[1] + MAP_WIDTH_COUNT * TILE_SIZE, y) -- right
    end

    ipt.create_borders(b, RENDER_LAYER.TERRAIN, MAP_BORDER_SIZE, BORDER_MATERIAL)
end

function M.create()
    create_plane_in_groups()
    create_border_in_groups()
end

return M