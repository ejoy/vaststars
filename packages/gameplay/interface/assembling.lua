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

local function createChestAndFluidBox(init, fluidboxes, s, max, needlimit)
    s = s:sub(5)
    assert(#s <= 4 * 15)
    local chest = {}
    local fluids = {}
    for idx = 1, #s//4 do
        local id, n = string.unpack("<I2I2", s, 4*idx-3)
        local limit = 0
        if isFluidId(id) then
            local fluid_idx = findFluidbox(init, id)
            if fluid_idx > max then
                error "The assembling does not support this recipe."
            end
            fluids[fluid_idx] = idx
            local fb = fluidboxes[fluid_idx]
            if needlimit and needRecipeLimit(fb) then
                limit = n * 2
            else
                limit = fb.capacity
            end
        else
            limit = n * 2
        end
        chest[#chest+1] = string.pack("<I2I2I2I2I2", 0, id, 0, limit, 0)
    end
    for i = 1, max do
        fluids[i] = fluids[i] or 0
    end
    local fb = 0
    for i = max, 1, -1 do
        fb = (fb << 4) | fluids[i]
    end
    return table.concat(chest), fb
end

local function createChest(s)
    local chest = {}
    for idx = 2, #s//4 do
        local id, n = string.unpack("<I2I2", s, 4*idx-3)
        assert(not isFluidId(id))
        local limit = n * 2
        chest[#chest+1] = string.pack("<I2I2I2I2I2", 0, id, 0, limit, 0)
    end
    return table.concat(chest)
end

local function set_recipe(world, e, pt, recipe_name, fluids)
    local assembling = e.assembling
    local chest = e.chest_2
    assembling.progress = 0
    assembling.status = STATUS_IDLE
    chest.endpoint = 0xffff
    fluidbox.update_fluidboxes(e, pt, fluids)
    if recipe_name == nil then
        assembling.recipe = 0
        chest.chest_in = 0xffff
        chest.chest_out = 0xffff
        chest.fluidbox_in = 0
        chest.fluidbox_out = 0
        return
    end
    local recipe = assert(prototype.queryByName("recipe", recipe_name), "unknown recipe: "..recipe_name)
    if not fluids or not pt.fluidboxes then
        local chest_in = createChest(recipe.ingredients)
        local chest_out = createChest(recipe.results)
        assembling.recipe = recipe.id
        chest.chest_in = world:container_create(chest.endpoint, "blue", chest_in)
        chest.chest_out = world:container_create(chest.endpoint, "red", chest_out)
        chest.fluidbox_in = 0
        chest.fluidbox_out = 0
        return
    end
    local needlimit = #pt.fluidboxes.input > 0
    local chest_in, fluidbox_in = createChestAndFluidBox(fluids.input, pt.fluidboxes.input, recipe.ingredients, 4, needlimit)
    local chest_out, fluidbox_out = createChestAndFluidBox(fluids.output, pt.fluidboxes.output, recipe.results, 3, needlimit)
    assembling.recipe = recipe.id
    chest.chest_in = world:container_create(chest.endpoint, "blue", chest_in)
    chest.chest_out = world:container_create(chest.endpoint, "red", chest_out)
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
