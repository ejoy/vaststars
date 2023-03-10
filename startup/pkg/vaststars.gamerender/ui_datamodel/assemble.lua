local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local gameplay_core = require "gameplay.core"
local itypes = require "gameplay.interface.types"
local assembling_common = require "ui_datamodel.common.assembling"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function get(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    local typeobject = iprototype.queryById(e.building.prototype)
    local show_set_recipe = true 
    if iprototype.has_type(typeobject.type, "mining") then
        show_set_recipe = false -- TODO: special case for miner
    end
    if typeobject.recipe then
        show_set_recipe = false -- TODO: special case for assembling with recipe, such as air-filter, pump ...
    end

    local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
    if not recipe_typeobject then
        return {
            object_id = object_id,
            prototype_name = iprototype.show_prototype_name(typeobject),
            background = typeobject.background,
            recipe_name = "",
            recipe_ingredients_count = {},
            recipe_results_count = {},
            show_set_recipe = show_set_recipe,
        }
    end

    local ingredients_count, results_count = assembling_common.get(gameplay_core.get_world(), e)
    return {
        object_id = object_id,
        prototype_name = iprototype.show_prototype_name(typeobject),
        background = typeobject.background,
        recipe_name = recipe_typeobject.name,
        recipe_ingredients_count = ingredients_count,
        recipe_results_count = results_count,
        show_set_recipe = show_set_recipe,
    }
end

---------------
local M = {}

function M:create(object_id)
    return get(object_id)
end

function M:stage_ui_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    local ingredients_count, results_count, progress, total_progress = assembling_common.get(gameplay_core.get_world(), e)
    datamodel.recipe_ingredients_count = ingredients_count
    datamodel.recipe_results_count = results_count

    if e.assembling.status == STATUS_IDLE then
        datamodel.progress = "0%"
    else
        datamodel.progress = itypes.progress_str(progress, total_progress)
    end
end

function M:update(datamodel, object_id)
    for k, v in pairs(get(object_id) or {}) do
        datamodel[k] = v
    end
    self:flush()
end

return M