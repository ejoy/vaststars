local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local vsobject_manager = ecs.require "vsobject_manager"

local function get_object(x, y)
    local object = objects:coord(x, y)
    if object then
        return vsobject_manager:get(object.id)
    end
end

local function update_world(world)
    local t = {}
    for e in world.ecs:select "drone:in" do
        --TODO implement the animation of the drone here
    end
    return t
end
return update_world