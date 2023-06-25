local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local road_sys = ecs.system "road_system"
local iroadnet_converter = require "roadnet_converter"
local iroadnet = ecs.require "roadnet"
local iprototype = require "gameplay.interface.prototype"

function road_sys:gameworld_build()
    iroadnet:clear("road")

    local world = gameplay_core.get_world()
    for e in world.ecs:select "road building:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        local shape, dir = iroadnet_converter.to_shape(typeobject.name), iprototype.dir_tostring(e.building.direction)
        iroadnet:editor_set("road", "normal", e.building.x, e.building.y, shape, dir)
    end

    iroadnet:update()
end
