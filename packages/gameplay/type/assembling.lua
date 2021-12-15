local type = require "register.type"
local container = require "vaststars.container.core"
local prototype = require "prototype"
local component = require "register.component"

component "assembling" {
    "recipe:word",
    "container:word",
    "process:word",
}

local c = type "assembling"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

function c:ctor(init, pt)
    local recipe = assert(prototype.query("recipe", init.recipe))
    return {
        assembling = {
            recipe = recipe.id,
            container = container.create(self.cworld, "assembling", recipe.ingredients, recipe.results),
            process = STATUS_IDLE,
        }
    }
end
