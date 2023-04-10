local prototype = require "prototype"
local query = require "prototype".queryById
local fluidbox = require "interface.fluidbox"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function isFluidId(id)
    local pt = query(id)
    for _, t in ipairs(pt.type) do
        if t == "fluid" then
            return true
        end
    end
    return false
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

local function resetItems(world, recipe, chest, option, maxslot)
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    local hash = {}
    local olditems = {}
    local newitems = {}
    if chest.chest ~= 0 then
        for i = 1, 256 do
            local slot = world:container_get(chest, i)
            if not slot then
                break
            end
            if slot.type ~= "none" then
                assert(not olditems[slot.item])
                olditems[i] = slot
                hash[slot.item] = i
            end
        end
    end
    local count = #olditems
    local function create_slot(type, id, limit)
        local o = {}
        if hash[id] then
            local i = hash[id]
            o = olditems[i]
            olditems[i] = nil
            hash[id] = nil
        end
        newitems[#newitems+1] = world:chest_slot {
            type = type,
            item = id,
            limit = limit,
            amount = o.amount,
            lock_item = type ~= "blue" and o.lock_item or nil,
            lock_space = o.lock_space,
        }
    end
    for idx = 1, ingredients_n do
        local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        create_slot(isFluidId(id) and "none" or "blue", id, n * option.ingredientsLimit)
    end
    for idx = 1, results_n do
        local id, n = string.unpack("<I2I2", recipe.results, 4*idx+1)
        create_slot(isFluidId(id) and "none" or "red", id, n * option.resultsLimit)
    end
    for i = count, 1, -1 do
        if #newitems > maxslot + ingredients_n then
            break
        end
        local v = olditems[i]
        if v and v.type == "red" then
            create_slot(v.type, v.item, v.amount)
        end
    end
    return table.concat(newitems)
end

local function del_recipe(e)
    local assembling = e.assembling
    local chest = e.chest
    assembling.progress = 0
    assembling.status = STATUS_IDLE
    assembling.recipe = 0
    chest.fluidbox_in = 0
    chest.fluidbox_out = 0
end

local function set_recipe(world, e, pt, recipe_name, fluids, option)
    fluidbox.update_fluidboxes(e, pt, fluids)

    if recipe_name == nil then
        del_recipe(e)
        return
    end
    option = option or {
        ingredientsLimit = 2,
        resultsLimit = 2,
    }

    local assembling = e.assembling
    local recipe = assert(prototype.queryByName(recipe_name), "unknown recipe: "..recipe_name)
    if assembling.recipe == recipe.id then
        return
    end
    assembling.recipe = recipe.id
    assembling.progress = 0
    assembling.status = STATUS_IDLE
    local chest = e.chest
    local items = resetItems(world, recipe, chest, option, pt.maxslot)
    world:container_destroy(chest)
    chest.chest = world:container_create(items)
    if fluids and pt.fluidboxes then
        local fluidbox_in, fluidbox_out = createFluidBox(fluids, recipe)
        chest.fluidbox_in = fluidbox_in
        chest.fluidbox_out = fluidbox_out
    else
        chest.fluidbox_in = 0
        chest.fluidbox_out = 0
    end
end

local function set_option(world, e, option)
    local assembling = e.assembling
    local recipe = assert(prototype.queryById(assembling.recipe), "unknown recipe: ".. assembling.recipe)
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1

    for idx = 1, ingredients_n do
        local _, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        world:container_set(e.chest, idx, {limit = n * option.ingredientsLimit})
    end
    for idx = 1, results_n do
        local _, n = string.unpack("<I2I2", recipe.results, 4*idx+1)
        world:container_set(e.chest, ingredients_n + idx, {limit = n * option.resultsLimit})
    end
end

local function set_direction(_, e, dir)
    local DIRECTION <const> = {
        N = 0, North = 0,
        E = 1, East  = 1,
        S = 2, South = 2,
        W = 3, West  = 3,
    }
    local d = assert(DIRECTION[dir])
    local building = e.building
    if building.direction ~= d then
        building.direction = d
        e.fluidbox_changed = true
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
    set_option = set_option,
    set_direction = set_direction,
    what_status = what_status,
}
