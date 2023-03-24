local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local vsobject_manager = ecs.require "vsobject_manager"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iworld = require "gameplay.interface.world"
local icanvas = ecs.require "engine.canvas"
local get_assembling_canvas_items = ecs.require "ui_datamodel.common.assembling_canvas".get_assembling_canvas_items

local set_recipe_mb = mailbox:sub {"set_recipe"}
local set_item_mb = mailbox:sub {"set_item"}
local detail_mb = mailbox:sub {"detail"}
local close_mb = mailbox:sub {"close"}
local teardown_mb = mailbox:sub {"teardown"}
local move_mb = mailbox:sub {"move"}
local road_builder_mb = mailbox:sub {"road_builder"}
local pipe_builder_mb = mailbox:sub {"pipe_builder"}
local construction_center_build_mb = mailbox:sub {"construction_center_build"}
local construction_center_stop_build_mb = mailbox:sub {"construction_center_stop_build"}
local construction_center_place_mb = mailbox:sub {"construction_center_place"}

local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local iobject = ecs.require "object"
local ichest = require "gameplay.interface.chest"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local idetail = ecs.import.interface "vaststars.gamerender|idetail"
local assembling_common = require "ui_datamodel.common.assembling"
local gameplay = import_package "vaststars.gameplay"
local iassembling = gameplay.interface "assembling"

-- An object may contain multiple types at the same time
-- The types are listed in order, with the earlier ones taking precedence over the later ones
local detail_rml = {
    {
        type = "station",
        rml = "logistic_center.rml",
    },
    {
        type = "lorry_factory",
        rml = "assemble.rml",
    },
    {
        type = "assembling",
        rml = "assemble.rml",
    },
    {
        type = "chest",
        rml = "chest.rml",
    },
    {
        type = "base",
        rml = "chest.rml",
    },
    {
        type = "laboratory",
        rml = "lab.rml",
    },
}

local function __get_detail_rml(typeobject)
    if typeobject.construction_center == true then
        return
    end

    for _, v in ipairs(detail_rml) do
        if iprototype.has_type(typeobject.type, v.type) then
            return v.rml
        end
    end
    return nil
end

local function __show_detail(typeobject)
    if typeobject.show_detail == false then
        return false
    end
    return __get_detail_rml(typeobject) ~= nil
end

local function __show_set_item(typeobject)
    return iprototype.has_type(typeobject.type, "hub")
end

local function __show_set_recipe(typeobject)
    if typeobject.construction_center == true then
        return true
    end

    if not iprototype.has_type(typeobject.type, "assembling") and
       not iprototype.has_type(typeobject.type, "lorry_factory") then
        return false
    end

    return typeobject.recipe == nil and not iprototype.has_type(typeobject.type, "mining")
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
    local typeobject = iprototype.queryByName(object.prototype_name)

    -- 组装机才显示设置配方菜单
    local show_set_recipe = __show_set_recipe(typeobject)
    local show_set_item = __show_set_item(typeobject)
    local show_detail = false--__show_detail(typeobject)
    local recipe_name = ""

    if iprototype.has_type(typeobject.type, "assembling") or iprototype.has_type(typeobject.type, "lorry_factory") then
        if e.assembling.recipe ~= 0 then
            local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
            recipe_name = recipe_typeobject.name
        end
    end

    local construction_center_place, construction_center_build, construction_center_stop_build = false, false, false
    local construction_center_icon, construction_center_count, construction_center_ingredients
    local construction_center_multiple = 2
    if typeobject.construction_center == true then
        if e.assembling.recipe == 0 then
            construction_center_icon = ""
            construction_center_count = 0
        else
            construction_center_build, construction_center_stop_build = true, true
            local results
            construction_center_ingredients, results = assembling_common.get(gameplay_core.get_world(), e)
            assert(results and results[1])
            construction_center_icon = results[1].icon
            construction_center_count = results[1].count

            if construction_center_count > 0 then
                construction_center_place = true
            end
        end

        local ingredients, _ = assembling_common.get(gameplay_core.get_world(), e)
        if ingredients[1] then -- Not yet set recipe
            construction_center_multiple = (ingredients[1].limit // ingredients[1].need_count)
        end
    end

    return {
        show_teardown = false,
        show_move = false,
        show_set_recipe = show_set_recipe,
        show_set_item = show_set_item,
        show_road_builder = typeobject.road_builder,
        show_pipe_builder = typeobject.pipe_builder,
        construction_center_icon = construction_center_icon,
        construction_center_count = construction_center_count,
        construction_center_ingredients = construction_center_ingredients,
        construction_center_multiple = construction_center_multiple,
        construction_center_place = construction_center_place,
        construction_center_build = construction_center_build,
        construction_center_stop_build = construction_center_stop_build,
        drone_depot_icon = "",
        drone_depot_count = 0,
        show_detail = show_detail,
        recipe_name = recipe_name,
        object_id = object_id,
        left = ui_x,
        top = ui_y,
        object_position = object_position,
    }
end

local function __construction_center_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName(object.prototype_name)
    local construction_center_icon, construction_center_count, construction_center_ingredients
    if typeobject.construction_center == true then
        if e.assembling.recipe == 0 then
            construction_center_icon = ""
            construction_center_count = 0
        else
            datamodel.construction_center_build, datamodel.construction_center_stop_build = true, true
            local results
            construction_center_ingredients, results = assembling_common.get(gameplay_core.get_world(), e)
            assert(results and results[1])
            construction_center_icon = results[1].icon
            construction_center_count = results[1].count

            if construction_center_count > 0 then
                datamodel.construction_center_place = true
            end
        end
    end
    datamodel.construction_center_icon = construction_center_icon
    datamodel.construction_center_count = construction_center_count
    datamodel.construction_center_ingredients = construction_center_ingredients
end

local function __drone_depot_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName(object.prototype_name)
    if not iprototype.has_type(typeobject.type, "hub") then
        return
    end
    local c = ichest.chest_get(gameplay_core.get_world(), e.hub, 1)
    if not c then
        return
    end
    local item_typeobject = iprototype.queryById(c.item)
    datamodel.drone_depot_icon = item_typeobject.icon
    datamodel.drone_depot_count = c.amount
end

function M:update(datamodel, object_id, recipe_name)
    if datamodel.object_id ~= object_id then
        return
    end
    datamodel.recipe_name = recipe_name
    __construction_center_update(datamodel, object_id)
    __drone_depot_update(datamodel, object_id)
    return true
end

function M:stage_ui_update(datamodel, object_id)
    -- show pickup material button when object has result
    local object = objects:get(object_id)
    if not object then
        assert(false)
    end

    __construction_center_update(datamodel, object_id)
    __drone_depot_update(datamodel, object_id)

    for _, _, _, object_id in set_recipe_mb:unpack() do
        iui.open({"recipe_pop.rml"}, object_id)
    end

    for _, _, _, object_id in set_item_mb:unpack() do
        iui.open({"drone_depot.rml"}, object_id)
    end

    for _, _, _, object_id in detail_mb:unpack() do
        local object = assert(objects:get(object_id))
        local typeobject = iprototype.queryByName(object.prototype_name)
        local rml = __get_detail_rml(typeobject)
        if rml then
            iui.open({rml}, object_id)
        end
    end

    for _, _, _, object_id in teardown_mb:unpack() do
        local object = assert(objects:get(object_id))
        igameplay.remove_entity(object.gameplay_eid)
        gameplay_core.build()

        iobject.remove(object)
        objects:remove(object_id, "CONSTRUCTED")
        iui.close("build_function_pop.rml")
        iui.close("detail_panel.rml")

        local typeobject_item = iprototype.queryByName(object.prototype_name)
        if typeobject_item then
            ichest.base_chest_place(gameplay_core.get_world(), typeobject_item.id, 1)
        end

        local typeobject_entity = iprototype.queryByName(object.prototype_name)
        if typeobject_entity.power_supply_area then
            ipower:build_power_network(gameplay_core.get_world())
            ipower_line.update_line(ipower:get_pole_lines())
        end
    end

    for _, _, _, object_id in move_mb:unpack() do
        iui.close("build_function_pop.rml")
        iui.close("detail_panel.rml")

        local vsobject = vsobject_manager:get(object_id)
        vsobject:modifier("start", {name = "over", forwards = true})

        iui.redirect("construct.rml", "move", object_id)
    end

    for _, _, _, object_id in close_mb:unpack() do
        local vsobject = vsobject_manager:get(object_id)
        vsobject:modifier("start", {name = "over", forwards = true})
    end

    for _, _, _, object_id in road_builder_mb:unpack() do
        iui.redirect("construct.rml", "road_builder", object_id)
    end

    for _, _, _, object_id in pipe_builder_mb:unpack() do
        iui.redirect("construct.rml", "pipe_builder", object_id)
    end

    for _, _, _, object_id in construction_center_build_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        local typeobject = iprototype.queryById(e.building.prototype)
        local ingredients, _ = assembling_common.get(gameplay_core.get_world(), e)
        if not ingredients[1] then -- Not yet set recipe
            goto continue
        end
        local multiple = (ingredients[1].limit // ingredients[1].need_count) + 1
        if typeobject.recipe_chest_limit and typeobject.recipe_chest_limit >= multiple then
            datamodel.construction_center_multiple = multiple
            iassembling.set_option(gameplay_core.get_world(), e, {ingredientsLimit = multiple, resultsLimit = multiple})
        end
        ::continue::
    end

    for _, _, _, object_id in construction_center_stop_build_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        iworld.set_recipe(gameplay_core.get_world(), e, nil)
        local vsobject = assert(vsobject_manager:get(object_id))
        local typeobject = assert(iprototype.queryByName(object.prototype_name))
        local w, h = iprototype.unpackarea(typeobject.area)
        object.recipe = ""
        vsobject:add_canvas(icanvas.types().ICON, get_assembling_canvas_items(object, object.x, object.y, w, h))
        object.fluid_name = {}

        iui.update("build_function_pop.rml", "update", object_id)
        gameplay_core.build()
    end

    for _ in construction_center_place_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if e.assembling.recipe == 0 then
            goto continue
        end

        local _, results = assembling_common.get(gameplay_core.get_world(), e)
        assert(results and results[1])
        if results[1].count <= 0 then
            goto continue
        end

        idetail.unselected()
        iui.close("build_function_pop.rml")
        iui.close("detail_panel.rml")
        iui.redirect("construct.rml", "construction_center_place", results[1].name, object.gameplay_eid, results[1].id)
        ::continue::
    end
end

return M