local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local game_settings = ecs.require "game_settings"
local iprototype_cache = ecs.require "prototype_cache"

local function recipe_unlocked(recipe)
    if game_settings.recipe_unlocked then
        return true
    end
    local tech = next(iprototype_cache.get("recipe_unlocked")[recipe])
    if not tech then
        return false
    end
    return gameplay_core.is_researched(tech)
end

return {
    recipe_unlocked = recipe_unlocked,
}