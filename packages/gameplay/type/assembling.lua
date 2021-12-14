local type = require "base.register.type"
local container = require "base.container"
local prototype = require "base.prototype"
local component = require "base.register.component"

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
            container = container.create("assembling", recipe.ingredients, recipe.results),
            process = STATUS_IDLE,
        }
    }
end
