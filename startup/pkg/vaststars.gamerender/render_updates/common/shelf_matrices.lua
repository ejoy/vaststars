local iprototype = require "gameplay.interface.prototype"
local prefab_slots = require("engine.prefab_parser").slots
local building_io_slots = import_package "vaststars.prototype"("building_io_slots")
local math3d = require "math3d"

local PREFABS <const> = {
    ["in"]  = "/pkg/vaststars.resources/glbs/belt.glb|input.prefab",
    ["out"] = "/pkg/vaststars.resources/glbs/belt.glb|output.prefab",
}

local function __get_slot_srts(building_model, ingredients_n, results_n)
    local slot_srts = {}
    local building_slots = prefab_slots(building_model)
    assert(next(building_slots), ("the model(%s) is not configured with any attachment points"):format(building_model))
    local key = ("%s%s"):format(ingredients_n, results_n)
    local cfg = assert(building_io_slots[key], "building_io_slots[" .. key .. "] not found")

    for i = 1, #cfg.in_slots do
        local slot_name = "shelf" .. cfg.in_slots[i]
        slot_srts[#slot_srts + 1] = building_slots[slot_name].scene
    end
    for i = 1, #cfg.out_slots do
        local slot_name = "shelf" .. cfg.out_slots[i]
        slot_srts[#slot_srts + 1] = building_slots[slot_name].scene
    end
    return slot_srts
end

local function get_shelf_matrices(building, recipe, building_mat)
    local typeobject_building = iprototype.queryById(building)
    local typeobject_recipe = iprototype.queryById(recipe)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1
    local results_n <const> = #typeobject_recipe.results//4 - 1

    local matrices = {}
    local slot_srts = __get_slot_srts("/pkg/vaststars.resources/" .. typeobject_building.model, ingredients_n, results_n)

    for i = 1, ingredients_n do
        local idx = i
        local id = string.unpack("<I2I2", typeobject_recipe.ingredients, 4*i+1)
        local typeobject_item = iprototype.queryById(id)
        if iprototype.has_type(typeobject_item.type, "item") then
            assert(slot_srts[idx])
            matrices[idx] = math3d.ref(math3d.mul(building_mat, math3d.matrix(slot_srts[idx])))
        end
    end
    for i = 1, results_n do
        local idx = i + ingredients_n
        local id = string.unpack("<I2I2", typeobject_recipe.results, 4*i+1)
        local typeobject_item = iprototype.queryById(id)
        if iprototype.has_type(typeobject_item.type, "item") then
            assert(slot_srts[idx])
            matrices[idx] = math3d.ref(math3d.mul(building_mat, math3d.matrix(slot_srts[idx])))
        end
    end
    return matrices
end

local function get_item_matrices(recipe, shelf_matrices)
    local typeobject_recipe = iprototype.queryById(recipe)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1
    local results_n <const> = #typeobject_recipe.results//4 - 1

    local matrices = {}
    local slots, slot_mat

    slots = prefab_slots(PREFABS["in"])
    assert(slots["item_slot"])
    slot_mat = math3d.matrix(slots["item_slot"].scene)
    for i = 1, ingredients_n do
        local idx = i
        if shelf_matrices[idx] then
            matrices[idx] = math3d.ref(math3d.mul(shelf_matrices[idx], slot_mat))
        end
    end

    slots = prefab_slots(PREFABS["out"])
    assert(slots["item_slot"])
    slot_mat = math3d.matrix(slots["item_slot"].scene)
    for i = 1, results_n do
        local idx = i + ingredients_n
        if shelf_matrices[idx] then
            matrices[idx] = math3d.ref(math3d.mul(shelf_matrices[idx], slot_mat))
        end
    end

    return matrices
end

return {
    get_shelf_matrices = get_shelf_matrices,
    get_item_matrices = get_item_matrices,
}