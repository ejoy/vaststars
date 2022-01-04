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
        local id = string.unpack("<I2I2", s, i)
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

local function getFluidBox(recipe)
    assert(#recipe.ingredients <= 15)
    assert(#recipe.results <= 15)
    local inFluid = getFluidList(recipe.ingredients, 4)
    local outFluid = getFluidList(recipe.results, 3)
    local fb = 0
    for i = 3, 1, -1 do
        fb = (fb << 4) | outFluid[i]
    end
    for i = 4, 1, -1 do
        fb = (fb << 4) | inFluid[i]
    end
    return fb
end

function c:ctor(init, pt)
    local recipe = assert(prototype.query("recipe", init.recipe), "unknown recipe: "..init.recipe)
    getFluidBox(recipe)
    return {
        assembling = {
            recipe = recipe.id,
            container = self:container_create("assembling", recipe.ingredients, recipe.results),
            fluidbox = getFluidBox(recipe),
            process = STATUS_IDLE,
        }
    }
end
