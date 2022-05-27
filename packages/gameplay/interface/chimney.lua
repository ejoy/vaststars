local prototype = require "prototype"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function set_recipe(e, recipe_name)
    local chimney = e.chimney
    chimney.progress = 0
    chimney.status = STATUS_IDLE
    if recipe_name == nil then
        chimney.recipe = 0
        return
    end
    local recipe = assert(prototype.query("recipe", recipe_name), "unknown recipe: "..recipe_name)
    chimney.recipe = recipe.id
end

return {
    set_recipe = set_recipe
}
