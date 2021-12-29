local type = require "register.type"
local prototype = require "prototype"

local c = type "assembling"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

function c:ctor(init, pt)
    local recipe = assert(prototype.query("recipe", init.recipe), "unknown recipe: "..init.recipe)
    return {
        assembling = {
            recipe = recipe.id,
            container = self:container_create("assembling", recipe.ingredients, recipe.results),
            process = STATUS_IDLE,
        }
    }
end
