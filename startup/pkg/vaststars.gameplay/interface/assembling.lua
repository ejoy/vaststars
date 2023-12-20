local prototype = require "prototype"
local query = require "prototype".queryById
local iFluidbox = require "interface.fluidbox"
local iBuilding = require "interface.building"
local iChest = require "interface.chest"
local cChest = require "vaststars.chest.core"

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

local function createFluidBox(init, recipe, fluidboxes, items)
    local input_fluids = {}
    local output_fluids = {}
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    assert(ingredients_n <= 16 and results_n <= 16)
    for idx = 1, ingredients_n + results_n do
        local s = items[idx]
        if s.type == "none" then
            local fluid_idx = findFluidbox(init.input, s.item)
            if fluid_idx > 4 then
                error "The assembling does not support this recipe."
            end
            input_fluids[fluid_idx] = idx
            fluidboxes["in"..idx.."_limit"] = s.limit
        end
    end
    for idx = 1, results_n do
        local s = items[ingredients_n + idx]
        if s.type == "none" then
            local fluid_idx = findFluidbox(init.output, s.item)
            if fluid_idx > 3 then
                error "The assembling does not support this recipe."
            end
            output_fluids[fluid_idx] = ingredients_n + idx
            fluidboxes["out"..idx.."_limit"] = s.limit
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

local InvalidChest <const> = 0

local function chest_destroy(world, chest, recycle)
    return cChest.destroy(world._cworld, chest.chest, recycle)
end

local function assembling_reset(world, e)
    local chest = e.chest
    local olditems = {}
    if chest.chest ~= InvalidChest then
        for i = 1, 256 do
            local slot = cChest.get(world._cworld, chest.chest, i)
            if not slot then
                break
            end
            if slot.type ~= "none" then
                assert(not olditems[slot.item])
                olditems[i] = slot
            end
        end
        chest_destroy(world, chest, true)
        chest.chest = InvalidChest
        iBuilding.dirty(world, "chest")
    end
end

local function assembling_reset_items(world, recipe, chest, option, maxslot)
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    local olditems = {}
    local newitems = {}
    if chest.chest ~= InvalidChest then
        for i = 1, 256 do
            local slot = cChest.get(world._cworld, chest.chest, i)
            if not slot then
                break
            end
            olditems[slot.item] = (olditems[slot.item] or 0) + slot.amount
        end
    end
    local function create_slot(type, id, limit)
        local amount = 0
        if olditems[id] then
            amount = olditems[id]
            olditems[id] = nil
        end
        newitems[#newitems+1] = {
            type = type,
            item = id,
            limit = limit,
            amount = amount,
        }
    end
    for idx = 1, ingredients_n do
        local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        create_slot(isFluidId(id) and "none" or "demand", id, n * option.ingredientsLimit)
    end
    for idx = 1, results_n do
        local id, n = string.unpack("<I2I2", recipe.results, 4*idx+1)
        create_slot(isFluidId(id) and "none" or "supply", id, n * option.resultsLimit)
    end
    for item, amount in pairs(olditems) do
        if amount > 0 then
            create_slot("supply", item, amount)
        end
        if #newitems >= maxslot then
            break
        end
    end
    return newitems
end

local function assembling_set(world, e, recipe, option, maxslot)
    local chest = e.chest
    option = option or {
        ingredientsLimit = 2,
        resultsLimit = 2,
    }
    local items = assembling_reset_items(world, recipe, chest, option, maxslot)
    if chest.chest ~= InvalidChest then
        chest_destroy(world, chest, false)
    end
    chest.chest = iChest.create(world, items)
    iBuilding.dirty(world, "chest")
    return items
end

local function del_recipe(world, e)
    local assembling = e.assembling
    assembling.progress = 0
    assembling.status = STATUS_IDLE
    assembling.recipe = 0
    assembling.fluidbox_in = 0
    assembling.fluidbox_out = 0
    assembling_reset(world, e)
end

local function set_recipe(world, e, pt, recipe_name, fluids, option)
    iFluidbox.update_fluidboxes(world, e, pt, fluids)

    if recipe_name == nil then
        del_recipe(world, e)
        return
    end
    local assembling = e.assembling
    local recipe = assert(prototype.queryByName(recipe_name), "unknown recipe: "..recipe_name)
    if assembling.recipe == recipe.id then
        return
    end
    assembling.recipe = recipe.id
    assembling.progress = 0
    assembling.status = STATUS_IDLE
    local items = assembling_set(world, e, recipe, option, pt.maxslot)
    if fluids and pt.fluidboxes then
        local fluidbox_in, fluidbox_out = createFluidBox(fluids, recipe, e.fluidboxes, items)
        assembling.fluidbox_in = fluidbox_in
        assembling.fluidbox_out = fluidbox_out
    else
        assembling.fluidbox_in = 0
        assembling.fluidbox_out = 0
    end
end

return {
    set_recipe = set_recipe,
}
