local type = require "register.type"
local assembling = require "interface.assembling"
local fluidbox = require "interface.fluidbox"
local iendpoint = require "interface.endpoint"

local c = type "assembling"
    .speed "percentage"
    .maxslot "count"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

function c:ctor(init, pt)
    local world = self
    local recipe_name = pt.recipe and pt.recipe or init.recipe
    local endpoint = iendpoint.create(world, init, pt, "assembling")
    local e = {
        fluidboxes = {},
        chest = {
            index = world:container_create(pt.maxslot),
            asize = pt.maxslot,
            fluidbox_in = 0,
            fluidbox_out = 0,
            endpoint = endpoint,
        },
        assembling = {
            progress = 0,
            recipe = 0,
            speed = math.floor(pt.speed * 100),
            status = STATUS_IDLE,
        },
    }
    if recipe_name == nil then
        fluidbox.update_fluidboxes(e, pt, init.fluids)
    else
        assembling.set_recipe(self, e, pt, recipe_name, init.fluids)
    end
    return e
end
