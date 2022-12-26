local type = require "register.type"
local assembling = require "interface.assembling"
local iendpoint = require "interface.endpoint"

local c = type "assembling"
    .speed "percentage"

function c:ctor(init, pt)
    local world = self
    local recipe_name = pt.recipe and pt.recipe or init.recipe
    local e = {
        endpoint_changed = true,
        fluidboxes = {},
        chest = {
            endpoint = iendpoint.create(world, init, pt)
        },
        assembling = {
            speed = math.floor(pt.speed * 100),
        },
    }
    assembling.set_recipe(self, e, pt, recipe_name, init.fluids)
    return e
end
