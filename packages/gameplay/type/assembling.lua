local type = require "register.type"
local prototype = require "prototype"

local c = type "assembling"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function getFluidList(s, max)
    local r = {}
    for i = 1, #s, 4 do
        local id = string.unpack("<I2", s, i)
        if isFluidId(id) then
            r[#r+1] = (i-1)//4+1
        end
    end
    if #r > max then
        error "The assembling does not support this recipe."
    end
    for i = #r+1, max do
        r[i] = 0
    end
    return r
end

local function getFluidBox(s, max)
    assert(#s <= 15)
    local fluids = getFluidList(s, max)
    local fb = 0
    for i = max, 1, -1 do
        fb = (fb << 4) | fluids[i]
    end
    return fb
end

function c:ctor(init, pt)
    --TODO fluid limit
    local recipe_name = pt.recipe and pt.recipe or init.recipe
    local recipe = assert(prototype.query("recipe", recipe_name), "unknown recipe: "..recipe_name)
    return {
        assembling = {
            recipe = recipe.id,
            container = self:container_create("assembling", recipe.ingredients, recipe.results),
            fluidbox_in = getFluidBox(recipe.ingredients, 4),
            fluidbox_out = getFluidBox(recipe.results, 3),
            process = STATUS_IDLE,
        }
    }
end
