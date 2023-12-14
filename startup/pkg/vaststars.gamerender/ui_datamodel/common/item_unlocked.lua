local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local game_settings <const> = ecs.require "game_settings"
local iprototype_cache = ecs.require "prototype_cache"

local function is_unlocked(prototype_name)
    if game_settings.item_unlocked then
        return true
    end

    local tech = next(iprototype_cache.get("item_unlocked")[prototype_name])
    if not tech then
        return true
    end
    return gameplay_core.is_researched(tech)
end

return {
    is_unlocked = is_unlocked,
}