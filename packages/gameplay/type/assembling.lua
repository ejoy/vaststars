local type = require "register.type"
local prototype = require "prototype"
local query = require "prototype".queryById

local c = type "assembling"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function findFluidbox(init, id)
    local name = query(id).name
    for i, v in ipairs(init) do
        if name == v[1] then
            return i
        end
    end
    return 0
end

local function createContainerAndFluidBox(init, fluidboxes, s, max)
    assert(#s <= 4 * 15)
    local container = {}
    local fluids = {}
    for idx = 1, #s//4 do
        local id, n = string.unpack("<I2I2", s, 4*idx-3)
        local limit = 0
        if isFluidId(id) then
            fluids[#fluids+1] = findFluidbox(init, id)
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

local function what_status(e)
    --TODO
    --  no_power
    --  disabled
    --  no_minable_resources
    local a = e.assembling
    if a.recipe == 0 then
        return "idle"
    end
    if a.process <= 0 then
        if a.status == STATUS_IDLE then
            return "insufficient_input"
        elseif a.status == STATUS_DONE then
            return "full_output"
        end
    end
    if a.low_power ~= 0 then
        return "low_power"
    end
    return "working"
end

function c:ctor(init, pt)
    local recipe_name = pt.recipe and pt.recipe or init.recipe
    if recipe_name == nil then
        return {
            assembling = {
                recipe = 0,
                container = 0,
                fluidbox_in = 0,
                fluidbox_out = 0,
                process = 0,
                low_power = 0,
                status = STATUS_IDLE,
                speed = math.floor(pt.speed * 100),
            }
        }
    end
    local recipe = assert(prototype.query("recipe", recipe_name), "unknown recipe: "..recipe_name)
    if not init.fluids or not pt.fluidboxes then
        local container_in = createContainer(recipe.ingredients)
        local container_out = createContainer(recipe.results)
        return {
            assembling = {
                recipe = recipe.id,
                container = self:container_create("assembling", container_in, container_out),
                fluidbox_in = 0,
                fluidbox_out = 0,
                process = 0,
                low_power = 0,
                status = STATUS_IDLE,
                speed = math.floor(pt.speed * 100),
            }
        }
    end
    local container_in, fluidbox_in = createContainerAndFluidBox(init.fluids.input, pt.fluidboxes.input, recipe.ingredients, 4)
    local container_out, fluidbox_out = createContainerAndFluidBox(init.fluids.output, pt.fluidboxes.output, recipe.results, 3)
    return {
        assembling = {
            recipe = recipe.id,
            container = self:container_create("assembling", container_in, container_out),
            fluidbox_in = fluidbox_in,
            fluidbox_out = fluidbox_out,
            process = 0,
            low_power = 0,
            status = STATUS_IDLE,
            speed = math.floor(pt.speed * 100),
        }
    }
end
