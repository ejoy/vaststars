local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iassembling = require "gameplay.interface.assembling"
local ilaboratory = require "gameplay.interface.laboratory"
local ientity = require "gameplay.interface.entity"
local vsobject_manager = ecs.require "vsobject_manager"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local irecipe = require "gameplay.interface.recipe"

local rotate_mb = mailbox:sub {"rotate"}
local recipe_mb = mailbox:sub {"recipe"}
local detail_mb = mailbox:sub {"detail"}
local manual_mb = mailbox:sub {"manual"}
local pickup_material_mb = mailbox:sub {"pickup_material"}
local place_material_mb = mailbox:sub {"place_material"}
local close_mb = mailbox:sub {"close_build_function_pop"}
local place_material_func = {}
place_material_func["assembling"] = function(gameplay_world, e)
    iassembling.place_material(gameplay_world, e)
end

place_material_func["laboratory"] = function(gameplay_world, e)
    ilaboratory:place_material(gameplay_world, e)
end

---------------
local M = {}
local current_object_id
function M:create(object_id, left, top)
    if current_object_id and current_object_id ~= object_id then
        local vsobject = vsobject_manager:get(current_object_id)
        vsobject:modifier("start", {name = "over", forwards = true})
    end
    if current_object_id ~= object_id then
        local vsobject = vsobject_manager:get(object_id)
        vsobject:modifier("start", {name = "talk", forwards = true})
    end
    current_object_id = object_id
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName("entity", object.prototype_name)

    -- 组装机才显示设置配方菜单
    local show_rotate = true
    local show_pickup_material = false
    local show_set_recipe = false
    local show_manual_manufacture = false
    local show_place_material = false
    local recipe_name = ""

    if iprototype.has_type(typeobject.type, "assembling") then
        show_set_recipe = typeobject.recipe == nil and not iprototype.has_type(typeobject.type, "mining") -- TODO: special case for mining
        if e.assembling.recipe ~= 0 then
            local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
            recipe_name = recipe_typeobject.name

            if #irecipe.get_elements(recipe_typeobject.ingredients) > 0 then
                show_place_material = true
            end
            if #irecipe.get_elements(recipe_typeobject.results) > 0 then
                show_pickup_material = true
            end
        end
    end

    if iprototype.has_type(typeobject.type, "laboratory") then
        show_place_material = true
    end

    if iprototype.has_type(typeobject.type, "base") then -- TODO: special case for headquarters
        show_manual_manufacture = true
    end

    return {
        show_rotate = show_rotate,
        show_pickup_material = show_pickup_material,
        show_set_recipe = show_set_recipe,
        show_manual_manufacture = show_manual_manufacture,
        show_place_material = show_place_material,
        recipe_name = recipe_name,
        object_id = object_id,
        left = left,
        top = top
    }
end

function M:update(datamodel, object_id, recipe_name)
    if datamodel.object_id ~= object_id then
        return
    end
    datamodel.recipe_name = recipe_name
    return true
end

function M:stage_ui_update(datamodel, object_id)
    -- show pickup material button when object has result
    local object = objects:get(object_id)
    if not object then
        assert(false)
    else
        local e = gameplay_core.get_entity(object.gameplay_eid)
        if e.assembling then
            datamodel.has_result = iassembling.has_result(gameplay_core.get_world(), e)
            datamodel.need_ingredients = iassembling.need_ingredients(gameplay_core.get_world(), e)
        end
    end

    --
    for _, _, _, object_id in rotate_mb:unpack() do
        local object = assert(objects:get(object_id))
        local dir = iprototype.rotate_dir_times(object.dir, -1)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if e then
            object.dir = dir
            ientity:set_direction(gameplay_core.get_world(), e, dir)
            gameplay_core.build()
        else
            log.error(("can not found entity (%s, %s)"):format(object.x, object.y))
        end
    end

    for _, _, _, object_id in recipe_mb:unpack() do
        iui.open("recipe_pop.rml", object_id)
    end

    for _ in manual_mb:unpack() do
        iui.open("detail_pop.rml")
    end

    for _, _, _, object_id in detail_mb:unpack() do
        local object = assert(objects:get(object_id))
        local typeobject = iprototype.queryByName("entity", object.prototype_name)
        if iprototype.has_type(typeobject.type, "assembling") then
            iui.open("assemble_2.rml", object_id)
        elseif iprototype.has_type(typeobject.type, "chest") then
            iui.open("cmdcenter.rml", object_id)
        elseif iprototype.has_type(typeobject.type, "laboratory") then
            iui.open("lab.rml", object_id)
        else
            log.error("no detail")
        end
    end

    for _, _, _, object_id in pickup_material_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(object.gameplay_eid)
        local items = iassembling.pickup_material(gameplay_core.get_world(), e)
        iui.open("message_pop.rml", {id = 1, items = items, left = datamodel.left, top = datamodel.top})
    end

    for _, _, _, object_id in place_material_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(object.gameplay_eid)
        local typeobject = iprototype.queryByName("entity", object.prototype_name)
        for _, type in ipairs(typeobject.type) do
            local func = place_material_func[type]
            if func then
                func(gameplay_core.get_world(), e)
                break
            end
        end
    end

    for _, _, _, object_id in close_mb:unpack() do
        local vsobject = vsobject_manager:get(object_id)
        vsobject:modifier("start", {name = "over", forwards = true})
    end
end

return M