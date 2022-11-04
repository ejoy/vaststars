local prototype = require "prototype"
local query = require "prototype".queryById
local fluidbox = require "interface.fluidbox"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local IN <const> = 0
local OUT <const> = 1
local INOUT <const> = 2

local PipeEdgeType <const> = {
    ["input"] = IN,
    ["output"] = OUT,
    ["input-output"] = INOUT,
}

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function findFluidbox(init, id)
    local name = query(id).name
    for i, v in ipairs(init) do
        if name == v then
            return i
        end
    end
    return 0
end

local function needRecipeLimit(fb)
    for _, conn in ipairs(fb.connections) do
        local type = PipeEdgeType[conn.type]
        if type == INOUT or type == OUT then
            return false
        end
    end
    return true
end

--createChestAndFluidBox(world, "blue", fluids.input, pt.fluidboxes.input, recipe.ingredients, 4, needlimit)
--createChestAndFluidBox(world, "red", fluids.output, pt.fluidboxes.output, recipe.results, 3, needlimit)

local function createChestAndFluidBox(world, init, fluidboxes, recipe, needlimit)
    local chest = {}
    local input_fluids = {}
    local output_fluids = {}
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    assert(ingredients_n <= 16 and results_n <= 16)
    for idx = 1, ingredients_n do
        local MAX <const> = 4
        local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        local limit = 0
        if isFluidId(id) then
            local fluid_idx = findFluidbox(init.input, id)
            if fluid_idx > MAX then
                error "The assembling does not support this recipe."
            end
            input_fluids[fluid_idx] = idx
            local fb = fluidboxes.input[fluid_idx]
            if needlimit and needRecipeLimit(fb) then
                limit = n * 2
            else
                limit = fb.capacity
            end
        else
            limit = n * 2
        end
        chest[#chest+1] = world:chest_slot {
            type = "blue",
            item = id,
            limit = limit,
        }
    end
    for idx = 1, results_n do
        local MAX <const> = 3
        local id, n = string.unpack("<I2I2", recipe.results, 4*idx+1)
        local limit = 0
        if isFluidId(id) then
            local fluid_idx = findFluidbox(init.output, id)
            if fluid_idx > MAX then
                error "The assembling does not support this recipe."
            end
            output_fluids[fluid_idx] = idx + ingredients_n
            local fb = fluidboxes.output[fluid_idx]
            if needlimit and needRecipeLimit(fb) then
                limit = n * 2
            else
                limit = fb.capacity
            end
        else
            limit = n * 2
        end
        chest[#chest+1] = world:chest_slot {
            type = "red",
            item = id,
            limit = limit,
        }
    end
    local fluidbox_in = 0
    local fluidbox_out = 0
    for i = 4, 1, -1 do
        fluidbox_in = (fluidbox_in << 4) | (input_fluids[i] or 0)
    end
    for i = 3, 1, -1 do
        fluidbox_out = (fluidbox_out << 4) | (output_fluids[i] or 0)
    end
    return table.concat(chest), fluidbox_in, fluidbox_out
end

local function createChest(world, recipe)
    local chest = {}
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    for idx = 1, ingredients_n do
        local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        assert(not isFluidId(id))
        chest[#chest+1] = world:chest_slot {
            type = "blue",
            item = id,
            limit = n * 2,
        }
    end
    for idx = 1, results_n do
        local id, n = string.unpack("<I2I2", recipe.results, 4*idx+1)
        assert(not isFluidId(id))
        chest[#chest+1] = world:chest_slot {
            type = "red",
            item = id,
            limit = n * 2,
        }
    end
    return table.concat(chest)
end

local function set_recipe(world, e, pt, recipe_name, fluids)
    local assembling = e.assembling
    local chest = e.chest
    assembling.progress = 0
    assembling.status = STATUS_IDLE
    chest.endpoint = 0xffff
    fluidbox.update_fluidboxes(e, pt, fluids)
    if recipe_name == nil then
        assembling.recipe = 0
        e.endpoint_changed = true
        chest.index = 0
        chest.asize = 0
        chest.fluidbox_in = 0
        chest.fluidbox_out = 0
        return
    end
    local recipe = assert(prototype.queryByName("recipe", recipe_name), "unknown recipe: "..recipe_name)
    if not fluids or not pt.fluidboxes then
        local id = createChest(world, recipe)
        local index, asize = world:container_create(id)
        assembling.recipe = recipe.id
        e.endpoint_changed = true
        chest.index = index
        chest.asize = asize
        chest.fluidbox_in = 0
        chest.fluidbox_out = 0
        return
    end
    local needlimit = #pt.fluidboxes.input > 0
    local id, fluidbox_in, fluidbox_out = createChestAndFluidBox(world, fluids, pt.fluidboxes, recipe, needlimit)
    local index, asize = world:container_create(id)
    assembling.recipe = recipe.id
    e.endpoint_changed = true
    chest.index = index
    chest.asize = asize
    chest.fluidbox_in = fluidbox_in
    chest.fluidbox_out = fluidbox_out
end

local function set_direction(_, e, dir)
    local DIRECTION <const> = {
        N = 0, North = 0,
        E = 1, East  = 1,
        S = 2, South = 2,
        W = 3, West  = 3,
    }
    local d = assert(DIRECTION[dir])
    local entity = e.entity
    if entity.direction ~= d then
        entity.direction = d
        e.fluidbox_changed = true
        e.endpoint_changed = true
    end
end

local function what_status(e)
    --TODO
    --  disabled
    --  no_minable_resources
    if e.capacitance.network == 0 then
        return "no_power"
    end
    local a = e.assembling
    if a.recipe == 0 then
        return "idle"
    end
    if a.progress <= 0 then
        if a.status == STATUS_IDLE then
            return "insufficient_input"
        elseif a.status == STATUS_DONE then
            return "full_output"
        end
    end
    return "working"
end

return {
    set_recipe = set_recipe,
    set_direction = set_direction,
    what_status = what_status,
}
