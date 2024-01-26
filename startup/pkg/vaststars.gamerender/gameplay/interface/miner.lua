local iprototype_cache = require "gameplay.prototype_cache.init"

local M = {}
function M.get_mineral_recipe(prototype_name, mineral)
    local miner_recipe = iprototype_cache.get "miner"
    if not miner_recipe[prototype_name] then
        return
    end
    return miner_recipe[prototype_name][mineral]
end

return M