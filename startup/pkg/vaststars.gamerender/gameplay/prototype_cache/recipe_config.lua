local iprototype = require "gameplay.interface.prototype"

local mt = {}
mt.__index = function (t, k)
    t[k] = setmetatable({}, mt)
    return t[k]
end

return function ()
    local assembling_recipe = {}; do
        local cache = setmetatable({}, mt)

        for _, v in pairs(iprototype.each_type "recipe") do
            if v.recipe_category then
                local r = {
                    name = v.name,
                    order = v.recipe_order,
                    icon = v.recipe_icon,
                    recipe_category = v.recipe_category,
                }
                table.insert(cache[v.recipe_craft_category], r)
            end
        end

        for _, v in pairs(iprototype.each_type "building") do
            if not (iprototype.has_type(v.type, "assembling") and v.craft_category )then
                goto continue
            end

            assembling_recipe[v.name] = {}
            for _, c in ipairs(v.craft_category) do
                table.move(cache[c], 1, #cache[c], #assembling_recipe[v.name] + 1, assembling_recipe[v.name])
            end
            for _, v in pairs(assembling_recipe[v.name]) do
                table.sort(v, function(a, b)
                    return a.order < b.order
                end)
            end
            ::continue::
        end
    end

    return assembling_recipe
end