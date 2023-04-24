local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local debugger = require "debugger"
local iprototype_cache = require "gameplay.prototype_cache.init"

local function recipe_unlocked(recipe)
    if debugger.recipe_unlocked then
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