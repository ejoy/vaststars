local type = require "register.type"
local assembling = require "interface.assembling"
local endpoint = require "interface.endpoint"
local fluidbox = require "interface.fluidbox"

local c = type "lorry_factory"
    .speed "percentage"
    .maxslot "count"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

function c:ctor(init, pt)
    local world = self
    local recipe_name = pt.recipe and pt.recipe or init.recipe
    local e = {
        lorry_factory = true,
        fluidboxes = {},
        chest = {
            chest = world:container_create(pt.maxslot),
            fluidbox_in = 0,
            fluidbox_out = 0,
            endpoint =  endpoint.create(world, init, pt, "assembling"),
        },
        assembling = {
            progress = 0,
            recipe = 0,
            speed = math.floor(pt.speed * 100),
            status = STATUS_IDLE,
        },
        park = {
            endpoint = endpoint.create(world, init, pt, "park"),
            count = 0,
            lorry1 = 0xffff,
            lorry2 = 0xffff,
            lorry3 = 0xffff,
            lorry4 = 0xffff,
            lorry5 = 0xffff,
            lorry6 = 0xffff,
            lorry7 = 0xffff,
            lorry8 = 0xffff,
        }
    }
    if recipe_name ~= nil then
        assembling.set_recipe(self, e, pt, recipe_name, init.fluids, {
            ingredientsLimit = 2,
            resultsLimit = 0,
        })
    end
    fluidbox.update_fluidboxes(e, pt, init.fluids)

    return e
end
