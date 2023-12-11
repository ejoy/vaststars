local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local RENDER_LAYER <const> = ecs.require "engine.render_layer".RENDER_LAYER
local MAP_WIDTH <const> = CONSTANT.MAP_WIDTH
local MAP_HEIGHT <const> = CONSTANT.MAP_HEIGHT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local MAP_BORDER_CHUNK_WIDTH <const> = 8
local MAP_BORDER_CHUNK_HEIGHT <const> = 8
assert(MAP_WIDTH % MAP_BORDER_CHUNK_WIDTH == 0 and MAP_HEIGHT % MAP_BORDER_CHUNK_HEIGHT == 0)
local MAP_BORDER_CHUNK_WIDTH_SIZE <const> = MAP_BORDER_CHUNK_WIDTH * TILE_SIZE
local MAP_BORDER_CHUNK_HEIGHT_SIZE <const> = MAP_BORDER_CHUNK_HEIGHT * TILE_SIZE
assert(MAP_BORDER_CHUNK_WIDTH_SIZE == MAP_BORDER_CHUNK_HEIGHT_SIZE)
local MAP_BORDER_CHUNK_SIZE <const> = MAP_BORDER_CHUNK_WIDTH_SIZE
local ORIGIN <const> = require "coord".origin_position()
local TERRAIN_MATERIAL <const> = "/pkg/vaststars.resources/materials/terrain/plane_terrain.material"
local BORDER_MATERIAL <const> = "/pkg/vaststars.resources/materials/terrain/border.material"

local igroup = ecs.require "group"
local MAP_CHUNK_WIDTH, MAP_CHUNK_HEIGHT = igroup.map_chunk_wh()
assert(MAP_CHUNK_WIDTH == MAP_CHUNK_HEIGHT)
local MAP_CHUNK_SIZE <const> = MAP_CHUNK_WIDTH * TILE_SIZE

local icoord = ecs.require "coord"
local ipt = ecs.require "ant.landform|plane_terrain"

local M = {}
function M.create()
    local t = {}
    for x = 0, MAP_WIDTH - 1, MAP_CHUNK_WIDTH do
        for y = 0, MAP_HEIGHT - 1, MAP_CHUNK_HEIGHT do
            local position = assert(icoord.lefttop_position(x, y))
            local v = {x = position[1], y = position[3] - MAP_CHUNK_SIZE, type = "terrain"}
            local gid = igroup.id(x, y)

            t[gid] = t[gid] or {}
            t[gid][#t[gid] + 1] = v
        end
    end

    local function add_border(t, x, y)
        local v = {x = x, y = y, type = "border"}
        local gid = 0

        t[gid] = t[gid] or {}
        t[gid][#t[gid] + 1] = v
        return t
    end

    -- top and bottom borders
    for x = ORIGIN[1] - MAP_BORDER_CHUNK_WIDTH_SIZE, ORIGIN[1] + (MAP_BORDER_CHUNK_WIDTH_SIZE * (MAP_WIDTH // MAP_BORDER_CHUNK_WIDTH)), MAP_BORDER_CHUNK_WIDTH_SIZE do
        t = add_border(t, x, ORIGIN[2])  -- top
        t = add_border(t, x, ORIGIN[2] - (MAP_HEIGHT * TILE_SIZE + MAP_BORDER_CHUNK_HEIGHT_SIZE)) -- bottom
    end

    -- left and right borders
    for y = ORIGIN[2] - (MAP_HEIGHT * TILE_SIZE), ORIGIN[2] - MAP_BORDER_CHUNK_HEIGHT_SIZE, MAP_BORDER_CHUNK_HEIGHT_SIZE do
        t = add_border(t, ORIGIN[1] - MAP_BORDER_CHUNK_WIDTH_SIZE, y) -- left
        t = add_border(t, ORIGIN[1] + MAP_WIDTH * TILE_SIZE, y) -- right
    end

    ipt.create_plane_terrain(t, RENDER_LAYER.TERRAIN, MAP_CHUNK_SIZE, MAP_BORDER_CHUNK_SIZE, TERRAIN_MATERIAL, BORDER_MATERIAL)
end

return M