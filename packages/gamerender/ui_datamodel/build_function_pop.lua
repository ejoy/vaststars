local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local vsobject_manager = ecs.require "vsobject_manager"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local set_recipe_mb = mailbox:sub {"set_recipe"}
local detail_mb = mailbox:sub {"detail"}
local close_mb = mailbox:sub {"close"}
local teardown_mb = mailbox:sub {"teardown"}
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local iobject = ecs.require "object"
local iworld = require "gameplay.interface.world"

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
    local show_set_recipe = false
    local show_detail = _show_detail(typeobject)
    local recipe_name = ""

    if iprototype.has_type(typeobject.type, "assembling") then
        show_set_recipe = typeobject.recipe == nil and not iprototype.has_type(typeobject.type, "mining") -- TODO: special case for mining
        if e.assembling.recipe ~= 0 then
            local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
            recipe_name = recipe_typeobject.name
        end
    end

    return {
        show_teardown = (typeobject.teardown ~= false),
        show_set_recipe = show_set_recipe,
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
    end

    for _, _, _, object_id in set_recipe_mb:unpack() do
        iui.open("recipe_pop.rml", object_id)
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

    for _, _, _, object_id in teardown_mb:unpack() do
        local object = assert(objects:get(object_id))
        igameplay.remove_entity(object.gameplay_eid)
        gameplay_core.build()

        iobject.remove(object)
        objects:remove(object_id, "CONSTRUCTED")
        objects:remove(object_id, "SELECTED")
        iui.close("build_function_pop.rml")
        iui.close("detail_panel.rml")

        local typeobject = iprototype.queryByName("item", object.prototype_name)
        iworld.base_chest_place(gameplay_core.get_world(), typeobject.id, 1)
    end

    for _, _, _, object_id in close_mb:unpack() do
        local vsobject = vsobject_manager:get(object_id)
        vsobject:modifier("start", {name = "over", forwards = true})
    end
end

return M