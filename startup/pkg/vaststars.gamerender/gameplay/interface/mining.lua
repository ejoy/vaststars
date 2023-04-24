local iprototype_cache = require "gameplay.prototype_cache.init"

local M = {}
function M.get_mineral_recipe(prototype_name, mineral)
    local mining_recipe = iprototype_cache.get "mining"
    if not mining_recipe[prototype_name] then
        return
    end
    return mining_recipe[prototype_name][mineral]
end

return M