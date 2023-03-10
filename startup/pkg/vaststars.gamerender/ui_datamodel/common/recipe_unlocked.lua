local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local VASTSTARS_DEBUG_RECIPE_UNLOCKED <const> = require "debugger".recipe_unlocked

local recipe_unlocked; do
    local mt = {}
    function mt:__index(k)
        local v = {}
        rawset(self, k, v)
        return v
    end
    local recipe_tech = setmetatable({}, mt)
    for _, typeobject in pairs(iprototype.each_maintype "tech") do
        if typeobject.effects and typeobject.effects.unlock_recipe then
            for _, recipe in ipairs(typeobject.effects.unlock_recipe) do
                table.insert(recipe_tech[recipe], typeobject.name)
            end
        end
    end
    for _, typeobject in pairs(iprototype.each_maintype "task") do
        if typeobject.effects and typeobject.effects.unlock_recipe then
            for _, recipe in ipairs(typeobject.effects.unlock_recipe) do
                table.insert(recipe_tech[recipe], typeobject.name)
            end
        end
    end
    for recipe, v in pairs(recipe_tech) do
        if #v > 1 then
            error(("recipe `%s` is unlocked by multiple techs: %s"):format(recipe, table.concat(v, ", ")))
        end
    end

if VASTSTARS_DEBUG_RECIPE_UNLOCKED then
    function recipe_unlocked(recipe)
        return true
    end
else
    function recipe_unlocked(recipe)
        local tech = recipe_tech[recipe][1]
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