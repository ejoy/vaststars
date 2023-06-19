local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local vsobject_manager = ecs.require "vsobject_manager"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local itask = ecs.require "task"
local icamera_controller = ecs.interface "icamera_controller"
local math3d = require "math3d"

local set_recipe_mb = mailbox:sub {"set_recipe"}
local set_item_mb = mailbox:sub {"set_item"}
local lorry_factory_inc_lorry_mb = mailbox:sub {"lorry_factory_inc_lorry"}
local lorry_factory_stop_build_mb = mailbox:sub {"lorry_factory_stop_build"}
local station_weight_increase_mb = mailbox:sub {"station_weight_increase"}
local close_mb = mailbox:sub {"close"}
local ui_click_mb = mailbox:sub {"ui_click"}
local pickup_item_mb = mailbox:sub {"pickup_item"}
local place_item_mb = mailbox:sub {"place_item"}
local lost_focus_mb = mailbox:sub {"lost_focus"}

local ichest = require "gameplay.interface.chest"
local assembling_common = require "ui_datamodel.common.assembling"
local gameplay = import_package "vaststars.gameplay"
local iassembling = gameplay.interface "assembling"
local gameplay = import_package "vaststars.gameplay"
local ihub = gameplay.interface "hub"
local global = require "global"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local iobject = ecs.require "object"
local igameplay = ecs.interface "igameplay"
local interval_call = ecs.require "engine.interval_call"

local DIRTY_STATION <const> = require("gameplay.interface.constant").DIRTY_STATION
local DIRTY_CHEST <const> = require("gameplay.interface.constant").DIRTY_CHEST
local MAX_STATION_WEIGHTS <const> = require("gameplay.interface.constant").MAX_STATION_WEIGHTS

local function __show_set_item(typeobject)
    return iprototype.has_type(typeobject.type, "hub") or iprototype.has_types(typeobject.type, "station_producer", "station_consumer")
end

local function __show_set_recipe(typeobject)
    if not iprototype.has_type(typeobject.type, "assembling") and
       not iprototype.has_type(typeobject.type, "lorry_factory") then
        return false
    end

    return typeobject.recipe == nil and not iprototype.has_type(typeobject.type, "mining")
end

local __lorry_factory_update = interval_call(800, function(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName(object.prototype_name)
    local lorry_factory_inc_lorry, lorry_factory_dec_lorry = false, false
    local lorry_factory_icon, lorry_factory_count = "", 0
    if iprototype.has_type(typeobject.type, "lorry_factory") then
        if e.assembling.recipe ~= 0 then
            lorry_factory_inc_lorry = true
            lorry_factory_dec_lorry = true

            local _, results = assembling_common.get(gameplay_core.get_world(), e)
            assert(results and results[1])
            lorry_factory_icon = results[1].icon
            lorry_factory_count = results[1].limit
        end
    end
    datamodel.lorry_factory_icon = lorry_factory_icon
    datamodel.lorry_factory_count = lorry_factory_count
    datamodel.lorry_factory_inc_lorry = lorry_factory_inc_lorry
    datamodel.lorry_factory_dec_lorry = lorry_factory_dec_lorry
end)

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

local __drone_depot_update_interval = interval_call(800, __drone_depot_update)

local __station_update = function(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName(object.prototype_name)
    if not iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
        return
    end
    local chest_component = iprototype.get_chest_component(object.prototype_name)
    local c = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
    if not c then
        return
    end
    local item_typeobject = iprototype.queryById(c.item)
    datamodel.station_item_icon = item_typeobject.icon
    datamodel.station_item_count = c.amount
    datamodel.station_weight_increase = true
    datamodel.station_weight_decrease = true
end
local __station_update_interval = interval_call(800, __station_update)

local function __get_moveable_count(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if iprototype.has_type(typeobject.type, "assembling") then
        local _, results = assembling_common.get(gameplay_core.get_world(), e)
        if not results[1] then
            return 0
        end
        local succ, count = ichest.get_moveable_count(gameplay_core.get_world(), results[1].id, results[1].count)
        if not succ then
            return 0
        end
        return count
    elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
        local chest_component = iprototype.get_chest_component(object.prototype_name)
        local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
        if not slot then
            return 0
        end
        local succ, count = ichest.get_moveable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
        if not succ then
            return 0
        end
        return count
    elseif iprototype.has_type(typeobject.type, "hub") then
        local slot = ichest.chest_get(gameplay_core.get_world(), e.hub, 1)
        if not slot then
            return 0
        end
        local succ, count = ichest.get_moveable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
        if not succ then
            return 0
        end
        return count
    elseif iprototype.has_type(typeobject.type, "chest") then
        local count = 0
        local items = ichest.collect_item(gameplay_core.get_world(), e.chest)
        for _, slot in pairs(items) do
            local succ, available = ichest.get_moveable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
            if succ then
                count = count + available
            end
        end
        return count
    else
        return 0
    end
end

local __moveable_count_update = interval_call(800, function(datamodel, object_id)
    datamodel.pickup_item_count = __get_moveable_count(object_id)
    return false
end, false)

---------------
local M = {}
local current_object_id
function M:create(object_id, object_position, ui_x, ui_y)
    lost_focus_mb:clear()

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
    local recipe_name = ""

    if iprototype.has_type(typeobject.type, "assembling") then
        if e.assembling.recipe ~= 0 then
            local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
            recipe_name = recipe_typeobject.name
        end
    end

    local pickup_item, place_item = false, false
    if iprototype.has_pickup(typeobject.name) then
        pickup_item = true
    end
    if iprototype.has_place(typeobject.name) then
        place_item = true
    end
    if iprototype.has_type(typeobject.type, "base") then -- special case for headquarter
        pickup_item = false
        place_item = false
    end

    local datamodel = {
        show_set_recipe = show_set_recipe,
        show_set_item = show_set_item,
        lorry_factory_icon = "",
        lorry_factory_count = 0,
        lorry_factory_inc_lorry = false,
        lorry_factory_dec_lorry = false,
        drone_depot_icon = "",
        drone_depot_count = 0,
        station_item_icon = "",
        station_item_count = 0,
        station_weight_increase = false,
        station_weight_decrease = false,
        pickup_item = pickup_item,
        place_item = place_item,
        pickup_item_count = __get_moveable_count(object_id),
        recipe_name = recipe_name,
        object_id = object_id,
        prototype_name = object.prototype_name,
        left = ui_x,
        top = ui_y,
        object_position = object_position,
    }

    __station_update(datamodel, object_id)
    __drone_depot_update(datamodel, object_id)
    return datamodel
end

local function __set_hub_first_item(gameplay_world, e, prototype_name)
    ihub.set_item(gameplay_world, e, prototype_name)
end

local function __get_hub_first_item(gameplay_world, e)
    local slot = ichest.chest_get(gameplay_world, e.hub, 1)
    if slot then
        return slot.item
    end
end

local function __set_station_first_item(gameplay_world, e, prototype_name)
    local typeobject = iprototype.queryById(e.building.prototype)
    local chest_component = iprototype.get_chest_component(typeobject.name)
    gameplay_world:container_destroy(e[chest_component])

    local typeobject_item = iprototype.queryByName(prototype_name)
    local c = {}
    c[#c+1] = gameplay_world:chest_slot {
        type = typeobject.chest_type,
        item = typeobject_item.id,
        limit = typeobject_item.stack,
    }
    e[chest_component].chest = gameplay_world:container_create(table.concat(c))
    e.station_changed = true
end

local function __get_station_first_item(gameplay_world, e)
    local typeobject = iprototype.queryById(e.building.prototype)
    local chest_component = iprototype.get_chest_component(typeobject.name)
    local slot = ichest.chest_get(gameplay_world, e[chest_component], 1)
    if slot then
        return slot.item
    end
end

function M:update(datamodel, object_id, recipe_name)
    if datamodel.object_id ~= object_id then
        return
    end
    datamodel.recipe_name = recipe_name
    __lorry_factory_update(datamodel, object_id)
    return true
end

function M:stage_ui_update(datamodel, object_id)
    -- show pickup material button when object has result
    local object = objects:get(object_id)
    if not object then
        assert(false)
    end

    __lorry_factory_update(datamodel, object_id)
    __drone_depot_update_interval(datamodel, object_id)
    __station_update_interval(datamodel, object_id)
    __moveable_count_update(datamodel, object_id)

    for _, _, _, object_id in set_recipe_mb:unpack() do
        iui.open({"recipe_pop.rml"}, object_id)
    end

    for _, _, _, object_id in set_item_mb:unpack() do
        local object = assert(objects:get(object_id))
        local typeobject = iprototype.queryByName(object.prototype_name)
        local interface = {}
        if iprototype.has_type(typeobject.type, "hub") then
            interface.get_first_item = __get_hub_first_item
            interface.set_first_item = __set_hub_first_item
        elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
            interface.get_first_item = __get_station_first_item
            interface.set_first_item = __set_station_first_item
        else
            assert(false)
        end
        iui.open({"drone_depot.rml"}, object_id, interface)
    end

    for _, _, _, object_id in close_mb:unpack() do
        local vsobject = vsobject_manager:get(object_id)
        vsobject:modifier("start", {name = "over", forwards = true})
    end

    for _ in lorry_factory_inc_lorry_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        assert(e.assembling.recipe ~= 0)

        local _, results = assembling_common.get(gameplay_core.get_world(), e)
        assert(results and results[1])
        local multiple = results[1].limit + 1
        iassembling.set_option(gameplay_core.get_world(), e, {ingredientsLimit = multiple, resultsLimit = multiple})
    end

    for _ in lorry_factory_stop_build_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        assert(e.assembling.recipe ~= 0)
        iassembling.set_option(gameplay_core.get_world(), e, {ingredientsLimit = 0, resultsLimit = 0})
    end

    for _ in station_weight_increase_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if e.station_producer then
            e.station_producer.weights = math.min(e.station_producer.weights + 1, MAX_STATION_WEIGHTS)
        else
            e.station_consumer.maxlorry = e.station_producer.maxlorry + 1
        end

        igameplay.dirty(DIRTY_STATION)
    end

    for _, _, _, message in ui_click_mb:unpack() do
        itask.update_progress("click_ui", message, object.prototype_name)
    end

    for _, _, _, object_id in pickup_item_mb:unpack() do
        local object = assert(objects:get(object_id))
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if iprototype.has_type(typeobject.type, "assembling") then
            local _, results = assembling_common.get(gameplay_core.get_world(), e)
            if not results[1] then
                print("recipe not set yet")
                goto continue
            end
            if not ichest.move_to_inventory(gameplay_core.get_world(), e.chest, results[1].id, results[1].count) then
                print("failed to move to the inventory")
                goto continue
            end
            print("success")
        elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
            local chest_component = iprototype.get_chest_component(object.prototype_name)
            local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
            if not slot then
                print("item not set yet")
                goto continue
            end
            if not ichest.move_to_inventory(gameplay_core.get_world(), e[chest_component], slot.item, ichest.get_amount(slot)) then
                print("failed to move to the inventory")
                goto continue
            end
            e.station_changed = true
        elseif iprototype.has_type(typeobject.type, "hub") then
            local slot = ichest.chest_get(gameplay_core.get_world(), e.hub, 1)
            if not slot then
                print("item not set yet")
                goto continue
            end
            if not ichest.move_to_inventory(gameplay_core.get_world(), e.hub, slot.item, ichest.get_amount(slot)) then
                print("failed to pickup")
                goto continue
            end
        elseif iprototype.has_type(typeobject.type, "chest") then
            local items = ichest.collect_item(gameplay_core.get_world(), e.chest)
            local message = {}
            for _, slot in pairs(items) do
                local succ, available = ichest.move_to_inventory(gameplay_core.get_world(), e.chest, slot.item, ichest.get_amount(slot))
                if succ then
                    local typeobject = iprototype.queryById(slot.item)
                    message[#message + 1] = {icon = assert(typeobject.icon), name = typeobject.name, count = available}
                end
            end
            if #message > 0 then
                local p = icamera_controller.world_to_screen(object.srt.t)
                local ui_x, ui_y = iui.convert_coord(math3d.index(p, 1), math3d.index(p, 2))
                iui.send("message_pop.rml", "item", {left = 400, top = 400, items = message})
            end
            iui.close("detail_panel.rml")
            world:pub {"rmlui_message_close", "building_arc_menu.rml"}

            local items = ichest.collect_item(gameplay_core.get_world(), e.chest)
            if not next(items) then
                -- TODO: optimize
                -- no item in chest, remove chest
                local object_id
                for _, object in objects:selectall("gameplay_eid", e.eid, EDITOR_CACHE_NAMES) do
                    object_id = object.id
                    break
                end
                local object = assert(objects:get(object_id))
                iobject.remove(object)
                objects:remove(object_id)
                local building = global.buildings[object_id]
                if building then
                    for _, v in pairs(building) do
                        v:remove()
                    end
                end

                igameplay.remove_entity(object.gameplay_eid)
            end
        else
            assert(false)
        end

        igameplay.dirty(DIRTY_CHEST)
        ::continue::
    end

    for _, _, _, object_id in place_item_mb:unpack() do
        local object = assert(objects:get(object_id))
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if iprototype.has_type(typeobject.type, "assembling") then
            local ingredients = assembling_common.get(gameplay_core.get_world(), e)
            for idx, ingredient in ipairs(ingredients) do
                if ingredient.demand_count > ingredient.count then
                    if not ichest.inventory_pickup(gameplay_core.get_world(), ingredient.id, ingredient.demand_count - ingredient.count) then
                        goto continue
                    end

                    gameplay_core.get_world():container_set(e.chest, idx, {amount = ingredient.demand_count})
                end
            end
            print("success")
        elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
            local chest_component = iprototype.get_chest_component(object.prototype_name)
            local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
            if not slot then
                print("item not set yet")
                goto continue
            end

            local c = ichest.get_amount(slot)
            if slot.limit <= c then
                print("item already full")
                goto continue
            end
            if not ichest.inventory_pickup(gameplay_core.get_world(), slot.item, slot.limit - c) then
                print("failed to place")
                goto continue
            end
            if not ichest.chest_place(gameplay_core.get_world(), e[chest_component], slot.item, slot.limit - c) then
                print("failed to place")
                goto continue
            end
            e.station_changed = true
        elseif iprototype.has_type(typeobject.type, "hub") then
            local component = "hub"
            local slot = ichest.chest_get(gameplay_core.get_world(), e[component], 1)
            if not slot then
                print("item not set yet")
                goto continue
            end

            local c = ichest.get_amount(slot)
            if slot.limit <= c then
                print("item already full")
                goto continue
            end
            if not ichest.inventory_pickup(gameplay_core.get_world(), slot.item, slot.limit - c) then
                print("failed to place")
                goto continue
            end
            if not ichest.chest_place(gameplay_core.get_world(), e[component], slot.item, slot.limit - c) then
                print("failed to place")
                goto continue
            end
        else
            assert(false)
        end

        igameplay.dirty(DIRTY_CHEST)
        ::continue::
    end

    for _ in lost_focus_mb:unpack() do
        world:pub {"rmlui_message_close", "building_arc_menu.rml"}
    end
end

return M