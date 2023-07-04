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
local station_weight_decrease_mb = mailbox:sub {"station_weight_decrease"}
local station_lorry_increase_mb = mailbox:sub {"station_lorry_increase"}
local station_lorry_decrease_mb = mailbox:sub {"station_lorry_decrease"}

local close_mb = mailbox:sub {"close"}
local ui_click_mb = mailbox:sub {"ui_click"}
local pickup_item_mb = mailbox:sub {"pickup_item"}
local place_item_mb = mailbox:sub {"place_item"}
local lost_focus_mb = mailbox:sub {"lost_focus"}
local unselected_mb = mailbox:sub {"unselected"}

local ichest = require "gameplay.interface.chest"
local ibackpack = require "gameplay.interface.backpack"
local assembling_common = require "ui_datamodel.common.assembling"
local gameplay = import_package "vaststars.gameplay"
local ihub = gameplay.interface "hub"
local global = require "global"
local iobject = ecs.require "object"
local igameplay = ecs.interface "igameplay"
local interval_call = ecs.require "engine.interval_call"
local gameplay = import_package "vaststars.gameplay"
local istation = gameplay.interface "station"

local MIN_STATION_WEIGHTS <const> = require("gameplay.interface.constant").MIN_STATION_WEIGHTS
local MAX_STATION_WEIGHTS <const> = require("gameplay.interface.constant").MAX_STATION_WEIGHTS

local function __show_set_item(typeobject)
    return iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub")
end

local __lorry_factory_update = interval_call(800, function(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local lorry_factory_inc_lorry, lorry_factory_dec_lorry = false, false
    local lorry_factory_icon, lorry_factory_count = "", 0
    if e.lorry_factory then
        assert(e.chest)
        lorry_factory_inc_lorry = true
        lorry_factory_dec_lorry = false
        local slot = assert(ichest.chest_get(gameplay_core.get_world(), e.chest, 1))
        lorry_factory_icon = iprototype.queryById(slot.item).icon
        lorry_factory_count = slot.count
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
    local chest_component = ichest.get_chest_component(e)
    local c = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
    if not c then
        return
    end

    if e.station_producer then
        datamodel.station_weight_increase = true
        datamodel.station_weight_decrease = true
        datamodel.station_lorry_increase = false
        datamodel.station_lorry_decrease = false
    else
        datamodel.station_weight_increase = false
        datamodel.station_weight_decrease = false
        datamodel.station_lorry_increase = true
        datamodel.station_lorry_decrease = true
    end

    local item_typeobject = iprototype.queryById(c.item)
    datamodel.station_item_icon = item_typeobject.icon
    datamodel.station_item_count = c.amount

end
local __station_update_interval = interval_call(800, __station_update)

local function __get_moveable_count(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if iprototype.has_type(typeobject.type, "assembling") then
        local _, results = assembling_common.get(gameplay_core.get_world(), e)
        if #results <= 0 then
            return 0
        end

        if #results > 1 then
            return "+"
        end

        local count = 0
        for i = 1, #results do
            local succ, available = ibackpack.get_moveable_count(gameplay_core.get_world(), results[i].id, results[i].count)
            if succ then
                count = count + available
            end
        end
        return count
    elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub") then
        local chest_component = ichest.get_chest_component(e)
        local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
        if not slot then
            return 0
        end
        local succ, count = ibackpack.get_moveable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
        if not succ then
            return 0
        end
        return count
    elseif iprototype.has_type(typeobject.type, "chest") then
        local count = 0
        local items = ichest.collect_item(gameplay_core.get_world(), e.chest)
        for _, slot in pairs(items) do
            local succ, available = ibackpack.get_moveable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
            if succ then
                count = count + available
            end
        end
        return count
    else
        return 0
    end
end

local function __get_placeable_count(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if iprototype.has_type(typeobject.type, "assembling") then
        local ingredients = assembling_common.get(gameplay_core.get_world(), e)
        if #ingredients <= 0 then
            return 0
        end
        if #ingredients > 1 then
            return "+"
        end
        local succ, count = ibackpack.get_placeable_count(gameplay_core.get_world(), ingredients[1].id, ingredients[1].demand_count - ingredients[1].count)
        if not succ then
            return 0
        end
        return count
    elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub") then
        local chest_component = ichest.get_chest_component(e)
        local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
        if not slot then
            return 0
        end
        local succ, count = ibackpack.get_placeable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
        if not succ then
            return 0
        end
        return count
    elseif iprototype.has_types(typeobject.type, "chest", "laboratory") then
        local count = 0
        local items = ichest.collect_item(gameplay_core.get_world(), e.chest)
        for _, slot in pairs(items) do
            local succ, available = ibackpack.get_placeable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
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
    datamodel.place_item_count = __get_placeable_count(object_id)
    return false
end, false)

---------------
local M = {}
function M:create(object_id)
    lost_focus_mb:clear()

    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName(object.prototype_name)
    local show_set_recipe = typeobject.allow_set_recipt and true or false
    local show_set_item = __show_set_item(typeobject)

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
        station_lorry_increase = false,
        station_lorry_decrease = false,
        pickup_item = pickup_item,
        place_item = place_item,
        pickup_item_count = __get_moveable_count(object_id),
        place_item_count = __get_placeable_count(object_id),
        object_id = object_id,
        prototype_name = object.prototype_name,
    }

    __station_update(datamodel, object_id)
    __drone_depot_update(datamodel, object_id)
    return datamodel
end

local function __set_hub_first_item(gameplay_world, e, item)
    ihub.set_item(gameplay_world, e, item)
end

local function __get_hub_first_item(gameplay_world, e)
    local slot = ichest.chest_get(gameplay_world, e.hub, 1)
    if slot then
        return slot.item
    end
end

local function __set_station_first_item(gameplay_world, e, item)
    istation.set_item(gameplay_world, e, item)
end

local function __get_station_first_item(gameplay_world, e)
    local chest_component = ichest.get_chest_component(e)
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
        iui.open({"recipe_config.rml"}, object_id)
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
        iui.open({"item_config.rml"}, object_id, interface)
    end

    for _, _, _, object_id in close_mb:unpack() do
        local vsobject = vsobject_manager:get(object_id)
        vsobject:modifier("start", {name = "over", forwards = true})
    end

    for _ in lorry_factory_inc_lorry_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))

        local component = "chest"
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
        if not ibackpack.pickup(gameplay_core.get_world(), slot.item, 1) then
            print("failed to place")
            goto continue
        end
        local succ = ichest.chest_place(gameplay_core.get_world(), e[component], 1, slot.amount + 1)
        if not succ then
            print("failed to place")
            goto continue
        end

        ::continue::
    end

    for _ in lorry_factory_stop_build_mb:unpack() do
    end

    for _ in station_weight_increase_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        istation.set_weights(gameplay_core.get_world(), e, math.min(e.station_producer.weights + 1, MAX_STATION_WEIGHTS))
    end

    for _ in station_weight_decrease_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        istation.set_weights(gameplay_core.get_world(), e, math.max(e.station_producer.weights - 1, MIN_STATION_WEIGHTS))
    end

    for _ in station_lorry_increase_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        istation.set_maxlorry(gameplay_core.get_world(), e, e.station_consumer.maxlorry + 1)
    end

    for _ in station_lorry_decrease_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        istation.set_maxlorry(gameplay_core.get_world(), e, math.max(e.station_consumer.maxlorry - 1, 0))
    end

    for _, _, _, message in ui_click_mb:unpack() do
        itask.update_progress("click_ui", message, object.prototype_name)
    end

    for _, _, _, object_id in pickup_item_mb:unpack() do
        local object = assert(objects:get(object_id))
        local sp = icamera_controller.world_to_screen(object.srt.t)
        local sp_x, sp_y = math3d.index(sp, 1), math3d.index(sp, 2)
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if iprototype.has_type(typeobject.type, "assembling") then
            local ingredients, results = assembling_common.get(gameplay_core.get_world(), e)
            if #results <= 0 then
                print("recipe not set yet")
                goto continue
            end

            local ingredient_count = #ingredients

            local msgs = {}
            for idx in ipairs(results) do
                local succ, available = ibackpack.move_to_backpack(gameplay_core.get_world(), e.chest, ingredient_count + idx)
                if not succ then
                    print("failed to move to the inventory")
                    goto continue
                end
                local typeitem = iprototype.queryById(results[1].id)
                msgs[#msgs + 1] = {icon = assert(typeitem.icon), name = typeitem.name, count = available}
            end

            iui.send("message_pop.rml", "item", {action = "up", left = sp_x, top = sp_y, items = {}})
            print("success")
        elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub") then
            local chest_component = ichest.get_chest_component(e)
            local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
            if not slot then
                print("item not set yet")
                goto continue
            end
            local succ, available = ibackpack.move_to_backpack(gameplay_core.get_world(), e[chest_component], 1)
            if not succ then
                print("failed to move to the inventory")
                goto continue
            end
            local typeitem = iprototype.queryById(slot.item)
            iui.send("message_pop.rml", "item", {action = "up", left = sp_x, top = sp_y, items = {{icon = assert(typeitem.icon), name = typeitem.name, count = available}}})

            if e.station_producer or e.station_consumer then
                e.station_changed = true
            end
        elseif iprototype.has_type(typeobject.type, "chest") then
            local message = {}
            for i = 1, ichest.MAX_SLOT do
                local slot = gameplay_core.get_world():container_get(e.chest, i)
                if not slot then
                    break
                end

                local succ, available = ibackpack.move_to_backpack(gameplay_core.get_world(), e.chest, i)
                if succ then
                    local typeobject = iprototype.queryById(slot.item)
                    message[#message + 1] = {icon = assert(typeobject.icon), name = typeobject.name, count = available}
                end
            end
            if #message > 0 then
                iui.send("message_pop.rml", "item", {action = "up", left = sp_x, top = sp_y, items = message})
            end
            iui.close("detail_panel.rml")
            world:pub {"rmlui_message_close", "building_menu.rml"}

            local items = ichest.collect_item(gameplay_core.get_world(), e.chest)
            if not next(items) then
                iobject.remove(object)
                objects:remove(object_id)
                local building = global.buildings[object_id]
                if building then
                    for _, v in pairs(building) do
                        v:remove()
                    end
                end

                igameplay.destroy_entity(object.gameplay_eid)
            end
        else
            assert(false)
        end

        ::continue::
    end

    for _, _, _, object_id in place_item_mb:unpack() do
        local object = assert(objects:get(object_id))
        local sp = icamera_controller.world_to_screen(object.srt.t)
        local sp_x, sp_y = math3d.index(sp, 1), math3d.index(sp, 2)
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if iprototype.has_type(typeobject.type, "assembling") then
            local ingredients = assembling_common.get(gameplay_core.get_world(), e)
            local message = {}
            for idx, ingredient in ipairs(ingredients) do
                if ingredient.demand_count > ingredient.count then
                    if not ibackpack.pickup(gameplay_core.get_world(), ingredient.id, ingredient.demand_count - ingredient.count) then
                        goto continue
                    end

                    gameplay_core.get_world():container_set(e.chest, idx, {amount = ingredient.demand_count})
                    local typeitem = iprototype.queryById(ingredient.id)
                    message[#message + 1] = {icon = assert(typeitem.icon), name = typeitem.name, count = ingredient.demand_count}
                end
            end
            if #message > 0 then
                iui.send("message_pop.rml", "item", {action = "down", left = sp_x, top = sp_y, items = message})
            end
            print("success")
        elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub") then
            local chest_component = ichest.get_chest_component(e)
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
            if not ibackpack.pickup(gameplay_core.get_world(), slot.item, slot.limit - c) then
                print("failed to place")
                goto continue
            end
            local succ, available = ichest.chest_place(gameplay_core.get_world(), e[chest_component], 1, slot.limit)
            if not succ then
                print("failed to place")
                goto continue
            end
            local typeitem = iprototype.queryById(slot.item)
            iui.send("message_pop.rml", "item", {action = "down", left = sp_x, top = sp_y, items = {{icon = assert(typeitem.icon), name = typeitem.name, count = available}}})

            if e.station_producer or e.station_consumer then
                e.station_changed = true
            end
        elseif iprototype.has_type(typeobject.type, "laboratory") then
            local component = "chest"
            local msgs = {}
            for i = 1, 256 do
                local slot = ichest.chest_get(gameplay_core.get_world(), e[component], i)
                if not slot then
                    break
                end

                local c = ichest.get_amount(slot)
                if slot.limit <= c then
                    -- print("item already full")
                    break
                end
                if not ibackpack.pickup(gameplay_core.get_world(), slot.item, slot.limit - c) then
                    -- print("failed to place")
                    break
                end
                local succ, available = ichest.chest_place(gameplay_core.get_world(), e[component], i, slot.limit)
                if not succ then
                    -- print("failed to place")
                    break
                end
                local typeitem = iprototype.queryById(slot.item)
                msgs[#msgs+1] = {icon = assert(typeitem.icon), name = typeitem.name, count = available}
            end
            iui.send("message_pop.rml", "item", {action = "down", left = sp_x, top = sp_y, items = msgs})
        else
            assert(false)
        end

        ::continue::
    end

    for _ in lost_focus_mb:unpack() do
        world:pub {"rmlui_message_close", "building_menu.rml"}
    end

    for _ in unselected_mb:unpack() do
        iui.redirect("construct.rml", "unselected")
    end
end

return M