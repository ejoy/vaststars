local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local VASTSTARS_DEBUG_RECIPE_UNLOCKED <const> = require "debugger".recipe_unlocked

local recipe_unlocked; do
    local recipe_tech = {}
    for _, typeobject in pairs(iprototype.each_maintype "tech") do
        if typeobject.effects and typeobject.effects.unlock_recipe then
            for _, recipe in ipairs(typeobject.effects.unlock_recipe) do
                assert(not recipe_tech[recipe])
                recipe_tech[recipe] = typeobject.name
            end
        end
    end

if VASTSTARS_DEBUG_RECIPE_UNLOCKED then
    function recipe_unlocked(recipe)
        return true
    end
else
    function recipe_unlocked(recipe)
        local tech = recipe_tech[recipe]
        if not tech then
            -- log.info(("recipe `%s` is locked defaultly"):format(recipe))
            return false
        end
        return gameplay_core.is_researched(tech)
    end
end

end

return {
    recipe_unlocked = recipe_unlocked,
}