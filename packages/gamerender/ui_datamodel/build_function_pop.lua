local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iassembling = require "gameplay.interface.assembling"
local ientity = require "gameplay.interface.entity"
local vsobject_manager = ecs.require "vsobject_manager"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local rotate_mb = mailbox:sub {"rotate"}
local recipe_mb = mailbox:sub {"recipe"}
local detail_mb = mailbox:sub {"detail"}
local manual_mb = mailbox:sub {"manual"}
local close_mb = mailbox:sub {"close_build_function_pop"}

local detail_event = { -- entity_type -> function
    ["assembling"] = function(object_id)
        iui.open("assemble_2.rml", object_id)
    end,
    ["chest"] = function(object_id)
        iui.open("chest.rml", object_id)
    end,
    ["base"] = function(object_id)
        iui.open("chest.rml", object_id)
    end,
    ["laboratory"] = function(object_id)
        iui.open("lab.rml", object_id)
    end,
}

local function _show_detail(typeobject)
    for t in pairs(detail_event) do
        if iprototype.has_type(typeobject.type, t) then
            return true
        end
    end
    return false
end

local function _get_elements(s)
    local r = {}
    for idx = 2, #s // 4 do
        local id, n = string.unpack("<I2I2", s, 4 * idx - 3)
        if not iprototype.is_fluid_id(id) then -- skip fluid, fluid can not pick up
            local typeobject = assert(iprototype.queryById(id), ("can not found id `%s`"):format(id))
            r[#r+1] = {id = id, name = typeobject.name, count = n, icon = typeobject.icon, tech_icon = typeobject.tech_icon}
        end
    end
    return r
end

---------------
local M = {}
local current_object_id
function M:create(object_id, object_position, ui_x, ui_y)
    if current_object_id and current_object_id ~= object_id then
        local vsobject = vsobject_manager:get(current_object_id)
        if vsobject then -- current_object_id may be destroyed
            vsobject:modifier("start", {name = "over", forwards = true})
        end
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
    local show_detail = _show_detail(typeobject)
    local recipe_name = ""

    if iprototype.has_type(typeobject.type, "assembling") then
        show_set_recipe = typeobject.recipe == nil and not iprototype.has_type(typeobject.type, "mining") -- TODO: special case for mining
        if e.assembling.recipe ~= 0 then
            local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
            recipe_name = recipe_typeobject.name

            if #_get_elements(recipe_typeobject.ingredients) > 0 then
                show_place_material = true
            end
            if #_get_elements(recipe_typeobject.results) > 0 then
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
        show_detail = show_detail,
        recipe_name = recipe_name,
        object_id = object_id,
        left = ui_x,
        top = ui_y,
        object_position = object_position,
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
        for _, t in ipairs(typeobject.type) do
            if detail_event[t] then
                detail_event[t](object_id)
            end
        end
    end

    for _, _, _, object_id in close_mb:unpack() do
        local vsobject = vsobject_manager:get(object_id)
        vsobject:modifier("start", {name = "over", forwards = true})
    end
end

return M