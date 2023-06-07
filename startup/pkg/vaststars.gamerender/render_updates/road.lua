local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local road_sys = ecs.system "road_system"
local iroadnet_converter = require "roadnet_converter"
local iroadnet = ecs.require "roadnet"

local ROAD_TILE_WIDTH_SCALE <const> = 2
local ROAD_TILE_HEIGHT_SCALE <const> = 2

function road_sys:gameworld_build()
    iroadnet:clear("road")

    local world = gameplay_core.get_world()
    for e in world.ecs:select "road:in road_invalid?in endpoint_road:absent" do
        local mask = e.road.mask
        local x, y = e.road.x * ROAD_TILE_WIDTH_SCALE, e.road.y * ROAD_TILE_HEIGHT_SCALE
        local shape, dir = iroadnet_converter.mask_to_shape_dir(mask)
        iroadnet:editor_set("road", e.road_invalid and "remove" or "normal", x, y, shape, dir)
    end

    iroadnet:update()
end
