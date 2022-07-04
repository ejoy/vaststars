local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"

local function _get_name(prototype)
    return iprototype.queryById(prototype).name
end

local mining_recipe = {}
for _, typeobject in pairs(iprototype.each_maintype "recipe") do
    if typeobject.allow_mining then
        local ingredients = itypes.items(typeobject.ingredients)
        local result = itypes.items(typeobject.results)
        assert(#ingredients == 0, "recipe of mining should not have ingredients")
        assert(#result == 1, "recipe of mining should only have one result")

        mining_recipe[_get_name(result[1].id)] = typeobject.name
    end
end

local mining_mineral = {}
for _, typeobject in pairs(iprototype.each_maintype "entity") do
    if iprototype.has_type(typeobject.type, "mining") then
        for _, mineral in ipairs(typeobject.minerals) do
            mining_mineral[typeobject.name] = mining_mineral[typeobject.name] or {}
            mining_mineral[typeobject.name][mineral] = true
        end
    end
end

local M = {}
function M.get_mineral_recipe(prototype_name, mineral)
    if not mining_mineral[prototype_name] then
        return
    end
    if not mining_mineral[prototype_name][mineral] then
        return
    end
    return mining_recipe[mineral]
end

return M