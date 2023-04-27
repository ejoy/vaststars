local irecipe = require "gameplay.interface.recipe"
local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"

local function get(gameplay_world, e)
    if e.assembling.recipe == 0 then
        return {}, {}, 0, 0
    end

    local recipe_typeobject = assert(iprototype.queryById(e.assembling.recipe))
    local progress, total_progress = 0, 0
    if e.assembling.recipe ~= 0 then
        local recipe_typeobject = assert(iprototype.queryById(e.assembling.recipe))
        total_progress = recipe_typeobject.time * 100
        progress = e.assembling.progress
    end

    local ingredients = {}
    local results = {}
    for index, v in ipairs(irecipe.get_elements(recipe_typeobject.ingredients)) do
        local slot = ichest.chest_get(gameplay_world, e.chest, index)
        if slot then
            ingredients[index] = {icon = v.icon, name = v.name, count = ichest.get_amount(slot), limit = slot.limit, demand_count = v.count, state = "enough"}
        else
            ingredients[index] = {icon = v.icon, name = v.name, count = 0, limit = 0, demand_count = v.count, state = "enough"}
        end
    end

    for index, v in ipairs(irecipe.get_elements(recipe_typeobject.results)) do
        local slot = ichest.chest_get(gameplay_world, e.chest, #ingredients + index)
        if slot then
            results[index] = {icon = v.icon, name = v.name, id = slot.item, limit = slot.limit, count = ichest.get_amount(slot), output_count = v.count, state = "enough"}
        else
            results[index] = {icon = v.icon, name = v.name, id = 0, limit = 0, count = 0, output_count = v.count, state = "enough"}
        end
    end

    return ingredients, results, progress, total_progress
end

return {
    get = get,
}