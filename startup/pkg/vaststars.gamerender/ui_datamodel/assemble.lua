local ecs, mailbox = ...
local iUiRt     = ecs.import.interface "ant.rmlui|iuirt"
local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local gameplay_core = require "gameplay.core"
local itypes = require "gameplay.interface.types"
local assembling_common = require "ui_datamodel.common.assembling"
local close_assembleui_mb = mailbox:sub {"close_assembleui"}
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
local rt_model_path
local rt_exist = false
local rt_name = "chest_model"
function M:create(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    local filename = typeobject.model:match("^.+/(.+).prefab$")
    rt_model_path = "/pkg/vaststars.resources/glb/"..filename..".glb|mesh.prefab"
    return get(object_id)
end

function M:stage_ui_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end

    local gid = iUiRt.get_group_id(rt_name)
    if gid and not rt_exist then
        rt_exist = true
        local focus_entity_scale = {0.1, 0.1, 0.1}
        iUiRt.create_new_rt(rt_name, rt_model_path, "vaststars", focus_entity_scale)
    end

    local ingredients_count, results_count, progress, total_progress = assembling_common.get(gameplay_core.get_world(), e)
    datamodel.recipe_ingredients_count = ingredients_count
    datamodel.recipe_results_count = results_count

    if e.assembling.status == STATUS_IDLE then
        datamodel.progress = "0%"
    else
        datamodel.progress = itypes.progress_str(progress, total_progress)
    end

    for _, _, _ in close_assembleui_mb:unpack() do
        if rt_exist then
            iUiRt.close_ui_rt(rt_name)
            rt_exist = false
        end
    end
end

function M:update(datamodel, object_id)
    for k, v in pairs(get(object_id) or {}) do
        datamodel[k] = v
    end
    self:flush()
end

return M