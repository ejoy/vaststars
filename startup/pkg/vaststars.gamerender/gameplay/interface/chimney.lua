local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"

local cache = {}
for _, v in pairs(iprototype.each_type "recipe") do
    cache[v.category] = cache[v.category] or {}
    local ingredients = itypes.items(v.ingredients)
    if #ingredients ~= 1 then
        goto continue
    end

    local typeobject = iprototype.queryById(ingredients[1].id)
    cache[v.category][typeobject.name] = cache[v.category][typeobject.name] or {}
    table.insert(cache[v.category][typeobject.name], v.name)
    ::continue::
end

local M = {}

function M.get_recipe(craft_category, fluid_name)
    local craft_category = assert(assert(craft_category)[1], ("%s %s"):format(craft_category, fluid_name))
    if not cache[craft_category][fluid_name] then
        return
    end
    assert(cache[craft_category][fluid_name], ("%s %s"):format(craft_category, fluid_name))
    assert(#cache[craft_category][fluid_name] == 1, ("%s %s"):format(craft_category, fluid_name))
    return cache[craft_category][fluid_name][1]
end

return M