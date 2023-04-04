local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local VASTSTARS_DEBUG_RECIPE_UNLOCKED <const> = require "debugger".recipe_unlocked

local recipe_unlocked; do
    local function length(t)
        local n = 0
        for _ in pairs(t) do
            n = n + 1
        end
        return n
    end
    local mt = {}
    function mt:__index(k)
        local v = {}
        rawset(self, k, v)
        return v
    end
    local recipe_tech = setmetatable({}, mt)
    for _, typeobject in pairs(iprototype.each_type "tech") do
        if typeobject.effects and typeobject.effects.unlock_recipe then
            for _, recipe in ipairs(typeobject.effects.unlock_recipe) do
                recipe_tech[recipe][typeobject.name] = true
            end
        end
    end
    for _, typeobject in pairs(iprototype.each_type "task") do
        if typeobject.effects and typeobject.effects.unlock_recipe then
            for _, recipe in ipairs(typeobject.effects.unlock_recipe) do
                recipe_tech[recipe][typeobject.name] = true
            end
        end
    end
    for recipe, v in pairs(recipe_tech) do
        if length(v) > 1 then
            error(("recipe `%s` is unlocked by multiple techs: %s"):format(recipe, table.concat(v, ", ")))
        end
    end

if VASTSTARS_DEBUG_RECIPE_UNLOCKED then
    function recipe_unlocked(recipe)
        return true
    end
else
    function recipe_unlocked(recipe)
        local tech = next(recipe_tech[recipe])
        if not tech then
            return false
        end
        return gameplay_core.is_researched(tech)
    end
end

end

return {
    recipe_unlocked = recipe_unlocked,
}