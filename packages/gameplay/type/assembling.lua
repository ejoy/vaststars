local type = require "register.type"
local assembling = require "interface.assembling"

local c = type "assembling"
    .speed "percentage"

function c:ctor(init, pt)
    local recipe_name = pt.recipe and pt.recipe or init.recipe
    local e = {
        endpoint_changed = true,
        fluidboxes = {},
        chest_2 = {},
        assembling = {
            speed = math.floor(pt.speed * 100),
        },
    }
    assembling.set_recipe(self, e, pt, recipe_name, init.fluids)
    return e
end
