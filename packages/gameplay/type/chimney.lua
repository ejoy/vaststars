local type = require "register.type"
local chimney = require "interface.chimney"

local c = type "chimney"
    .speed "percentage"

function c:ctor(init, pt)
    local e = {
        chimney = {
            speed = math.floor(pt.speed * 100),
        }
    }
    chimney.set_recipe(e, init.recipe)
    return e
end
