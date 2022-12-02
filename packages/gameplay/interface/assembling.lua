local prototype = require "prototype"
local query = require "prototype".queryById
local fluidbox = require "interface.fluidbox"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

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

local function createFluidBox(init, recipe)
    local input_fluids = {}
    local output_fluids = {}
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    assert(ingredients_n <= 16 and results_n <= 16)
    for idx = 1, ingredients_n do
        local MAX <const> = 4
        local id = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        if isFluidId(id) then
            local fluid_idx = findFluidbox(init.input, id)
            if fluid_idx > MAX then
                error "The assembling does not support this recipe."
            end
            input_fluids[fluid_idx] = idx
        end
    end
    for idx = 1, results_n do
        local MAX <const> = 3
        local id = string.unpack("<I2I2", recipe.results, 4*idx+1)
        if isFluidId(id) then
            local fluid_idx = findFluidbox(init.output, id)
            if fluid_idx > MAX then
                error "The assembling does not support this recipe."
            end
            output_fluids[fluid_idx] = idx + ingredients_n
        end
    end
    local fluidbox_in = 0
    local fluidbox_out = 0
    for i = 4, 1, -1 do
        fluidbox_in = (fluidbox_in << 4) | (input_fluids[i] or 0)
    end
    for i = 3, 1, -1 do
        fluidbox_out = (fluidbox_out << 4) | (output_fluids[i] or 0)
    end
    return fluidbox_in, fluidbox_out
end

local function collectItem(world, chest)
    if chest.index == 0 or chest.index == nil then
        return {}
    end
    local items = {}
    local i = 1
    while true do
        local item, n = world:container_get(chest, i)
        if not item then
            break
        end
        if not isFluidId(item) then
            items[item] = (items[item] or 0) + n
        end
        i = i + 1
    end
    return items
end

local function createChest(world, recipe, items)
    local chest = {}
    local asize = 0
    local function create_slot(type, id, limit)
        chest[#chest+1] = world:chest_slot {
            type = type,
            item = id,
            limit = limit,
            amount = items[id],
        }
    end
    if recipe then
        local ingredients_n <const> = #recipe.ingredients//4 - 1
        local results_n <const> = #recipe.results//4 - 1
        asize = ingredients_n + results_n
        for idx = 1, ingredients_n do
            local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
            create_slot("blue", id, n * 2)
            items[id] = nil
        end
        for idx = 1, results_n do
            local id, n = string.unpack("<I2I2", recipe.results, 4*idx+1)
            create_slot("red", id, n * 2)
            items[id] = nil
        end
    end
    for id, n in pairs(items) do
        create_slot("red", id, n)
    end
    return table.concat(chest), asize
end

local function set_recipe(world, e, pt, recipe_name, fluids)
    local assembling = e.assembling
    local chest = e.chest
    local items = collectItem(world, chest)
    world:container_rollback(chest)
    assembling.progress = 0
    assembling.status = STATUS_IDLE
    fluidbox.update_fluidboxes(e, pt, fluids)
    local recipe
    if recipe_name == nil then
        assembling.recipe = 0
    else
        recipe = assert(prototype.queryByName("recipe", recipe_name), "unknown recipe: "..recipe_name)
        assembling.recipe = recipe.id
    end
    local info, asize = createChest(world, recipe, items)
    local index = world:container_create(asize, info)
    chest.index = index
    chest.asize = asize
    if recipe and fluids and pt.fluidboxes then
        local fluidbox_in, fluidbox_out = createFluidBox(fluids, recipe)
        chest.fluidbox_in = fluidbox_in
        chest.fluidbox_out = fluidbox_out
    else
        chest.fluidbox_in = 0
        chest.fluidbox_out = 0
    end
    world:container_flush(chest)
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
