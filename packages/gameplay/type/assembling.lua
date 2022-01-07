local type = require "register.type"
local prototype = require "prototype"

local c = type "assembling"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function createContainerAndFluidBox(fluidboxes, s, max)
    assert(#s <= 4 * 15)
    local container = {}
    local fluids = {}
    for idx = 1, #s//4 do
        local id, n = string.unpack("<I2I2", s, 4*idx-3)
        local limit = 0
        if isFluidId(id) then
            fluids[#fluids+1] = idx
            limit = fluidboxes[#fluids].capacity
        else
            limit = n * 2
        end
        container[#container+1] = string.pack("<I2I2", id, limit)
    end
    container = table.concat(container)
    if #fluids > max then
        error "The assembling does not support this recipe."
    end
    for i = #fluids+1, max do
        fluids[i] = 0
    end
    local fb = 0
    for i = max, 1, -1 do
        fb = (fb << 4) | fluids[i]
    end
    return container, fb
end

local function createContainer(s)
    local container = {}
    for idx = 1, #s//4 do
        local id, n = string.unpack("<I2I2", s, 4*idx-3)
        assert(not isFluidId(id))
        local limit = n * 2
        container[#container+1] = string.pack("<I2I2", id, limit)
    end
    return table.concat(container)
end

function c:ctor(init, pt)
    local recipe_name = pt.recipe and pt.recipe or init.recipe
    local recipe = assert(prototype.query("recipe", recipe_name), "unknown recipe: "..recipe_name)
    if not pt.fluidboxes then
        local container_in = createContainer(recipe.ingredients)
        local container_out = createContainer(recipe.results)
        return {
            assembling = {
                recipe = recipe.id,
                container = self:container_create("assembling", container_in, container_out),
                fluidbox_in = 0,
                fluidbox_out = 0,
                process = STATUS_IDLE,
            }
        }
    end
    local container_in, fluidbox_in = createContainerAndFluidBox(pt.fluidboxes.input, recipe.ingredients, 4)
    local container_out, fluidbox_out = createContainerAndFluidBox(pt.fluidboxes.output, recipe.results, 3)
    return {
        assembling = {
            recipe = recipe.id,
            container = self:container_create("assembling", container_in, container_out),
            fluidbox_in = fluidbox_in,
            fluidbox_out = fluidbox_out,
            process = STATUS_IDLE,
        }
    }
end
