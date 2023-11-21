local ecs = ...
local world = ecs.world
local w = world.w

local item_unlocked = ecs.require "ui_datamodel.common.item_unlocked".is_unlocked

local function can_build(prototype_name, count)
    return item_unlocked(prototype_name) or count > 0
end

return can_build