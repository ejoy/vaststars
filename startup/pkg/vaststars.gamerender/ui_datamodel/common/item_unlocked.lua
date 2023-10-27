local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local debugger <const> = ecs.require "debugger"
local iprototype_cache = ecs.require "prototype_cache"

local function is_unlocked(prototype_name)
    if debugger.item_unlocked then
        return true
    end

    local tech = next(iprototype_cache.get("item_unlocked")[prototype_name])
    if not tech then
        return false
    end
    return gameplay_core.is_researched(tech)
end

return {
    is_unlocked = is_unlocked,
}