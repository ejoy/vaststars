local iprototype_cache = require "gameplay.prototype_cache.init"

local M = {}

function M.get_recipe(craft_category, fluid_name)
    local cache = iprototype_cache.get "chimney"
    local craft_category = assert(assert(craft_category)[1], ("%s %s"):format(craft_category, fluid_name))
    if not cache[craft_category][fluid_name] then
        return
    end
    assert(cache[craft_category][fluid_name], ("%s %s"):format(craft_category, fluid_name))
    assert(#cache[craft_category][fluid_name] == 1, ("%s %s"):format(craft_category, fluid_name))
    return cache[craft_category][fluid_name][1]
end

return M