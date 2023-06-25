local type = require "register.type"
local assembling = require "interface.assembling"
local fluidbox = require "interface.fluidbox"

local c = type "assembling"
    .speed "percentage"
    .maxslot "integer"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local InvalidChest <const> = 0

function c:ctor(init, pt)
    local recipe_name = pt.recipe and pt.recipe or init.recipe
    local e = {
        chest = {
            chest = InvalidChest,
        },
        assembling = {
            progress = 0,
            recipe = 0,
            speed = math.floor(pt.speed * 100),
            fluidbox_in = 0,
            fluidbox_out = 0,
            status = STATUS_IDLE,
        },
    }
    if pt.fluidboxes then
        e.fluidboxes = {}
    end
    if recipe_name == nil then
        fluidbox.update_fluidboxes(e, pt, init.fluids)
    else
        assembling.set_recipe(self, e, pt, recipe_name, init.fluids, pt.recipe_init_limit)
    end
    return e
end
