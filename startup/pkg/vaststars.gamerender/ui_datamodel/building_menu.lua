local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local itask = ecs.require "task"
local icamera_controller = ecs.interface "icamera_controller"
local math3d = require "math3d"

local set_recipe_mb = mailbox:sub {"set_recipe"}
local set_item_mb = mailbox:sub {"set_item"}
local lorry_factory_inc_lorry_mb = mailbox:sub {"lorry_factory_inc_lorry"}
local station_weight_increase_mb = mailbox:sub {"station_weight_increase"}
local station_weight_decrease_mb = mailbox:sub {"station_weight_decrease"}
local station_lorry_increase_mb = mailbox:sub {"station_lorry_increase"}
local station_lorry_decrease_mb = mailbox:sub {"station_lorry_decrease"}

local ui_click_mb = mailbox:sub {"ui_click"}
local pickup_item_mb = mailbox:sub {"pickup_item"}
local place_item_mb = mailbox:sub {"place_item"}

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
local PICKUP_TYPES <const> = {
    "assembling",
    "station_producer",
    "station_consumer",
    "hub",
    "chest",
}

local PLACE_TYPES <const> = {
    "assembling",
    "station_producer",
    "station_consumer",
    "hub",
    "laboratory",
}

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

        return ibackpack.get_moveable_count(gameplay_core.get_world(), results[1].id, results[1].count)
    elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub") then
        local chest_component = ichest.get_chest_component(e)
        local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
        if not slot then
            return 0
        end
        return ibackpack.get_moveable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
    elseif iprototype.has_type(typeobject.type, "chest") then
        local count = 0
        local items = ichest.collect_item(gameplay_core.get_world(), e.chest)
        for _, slot in pairs(items) do
            count = count + ibackpack.get_moveable_count(gameplay_core.get_world(), slot.item, ichest.get_amount(slot))
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
        return ibackpack.get_placeable_count(gameplay_core.get_world(), ingredients[1].id, ingredients[1].demand_count - ingredients[1].count)
    elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub") then
        local chest_component = ichest.get_chest_component(e)
        local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
        if not slot then
            return 0
        end
        return ibackpack.get_placeable_count(gameplay_core.get_world(), slot.item, ichest.get_space(slot))
    elseif iprototype.has_types(typeobject.type, "chest", "laboratory") then
        local count = 0
        local items = ichest.collect_item(gameplay_core.get_world(), e.chest)
        for _, slot in pairs(items) do
            count = count + ibackpack.get_placeable_count(gameplay_core.get_world(), slot.item, ichest.get_space(slot))
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

local function getChestSlotItem(e)
    local chest_component = ichest.get_chest_component(e)
    if not chest_component then
        return {}
    end

    local t = {}
    for i = 1, ichest.MAX_SLOT do
        local slot = gameplay_core.get_world():container_get(e[chest_component], i)
        if not slot then
            break
        end
        t[#t+1] = slot.item
    end
    return t
end

---------------
local M = {}
function M:create(object_id)
    iui.register_leave("ui/building_menu.rml")

    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryById(e.building.prototype)

    local show_set_recipe = false
    local set_item1, set_item2 = false, false
    local set_item_icon1, set_item_icon2 = "", ""
    local lorry_factory_inc_lorry = false
    local station_weight_increase = false
    local station_weight_decrease = false
    local station_lorry_increase = false
    local station_lorry_decrease = false
    local pickup_item, place_item = false, false

    if iprototype.check_types(typeobject.name, PICKUP_TYPES) then
        pickup_item = true
    end
    if iprototype.check_types(typeobject.name, PLACE_TYPES) then
        place_item = true
    end

    if e.assembling then
        show_set_recipe = typeobject.allow_set_recipt and true or false
    end
    if e.lorry_factory then
        lorry_factory_inc_lorry = true
    end
    if e.station_producer then
        station_weight_increase = true
        station_weight_decrease = true
        set_item1 = true
        local items = getChestSlotItem(e)
        set_item_icon1 = (items[1] and items[1] ~= 0) and iprototype.queryById(items[1]).item_icon or ""
    end
    if e.station_consumer then
        station_lorry_increase = true
        station_lorry_decrease = true
        set_item1 = true
        local items = getChestSlotItem(e)
        set_item_icon1 = (items[1] and items[1] ~= 0) and iprototype.queryById(items[1]).item_icon or ""
    end
    if e.hub then
        local items = getChestSlotItem(e)
        set_item1, set_item2 = items[1] ~= nil, items[2] ~= nil
        set_item_icon1 = (items[1] and items[1] ~= 0) and iprototype.queryById(items[1]).item_icon or ""
        set_item_icon2 = (items[2] and items[2] ~= 0) and iprototype.queryById(items[2]).item_icon or ""
    end

    local datamodel = {
        object_id = object_id,
        prototype_name = typeobject.name,
        show_set_recipe = show_set_recipe,
        set_item1 = set_item1,
        set_item2 = set_item2,
        set_item_icon1 = set_item_icon1,
        set_item_icon2 = set_item_icon2,
        lorry_factory_inc_lorry = lorry_factory_inc_lorry,
        lorry_factory_dec_lorry = false,
        station_weight_increase = station_weight_increase,
        station_weight_decrease = station_weight_decrease,
        station_lorry_increase = station_lorry_increase,
        station_lorry_decrease = station_lorry_decrease,
        pickup_item = pickup_item,
        place_item = place_item,
        pickup_item_count = __get_moveable_count(object_id),
        place_item_count = __get_placeable_count(object_id),
    }

    return datamodel
end

local function __set_hub_first_item(gameplay_world, e, item)
    ihub.set_item(gameplay_world, e, {item})
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
    return true
end

function M:stage_ui_update(datamodel, object_id)
    -- show pickup material button when object has result
    local object = objects:get(object_id)
    if not object then
        assert(false)
    end

    __moveable_count_update(datamodel, object_id)

    for _, _, _, object_id in set_recipe_mb:unpack() do
        iui.open({"ui/recipe_config.rml"}, object_id)
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
        iui.open({"ui/item_config.rml"}, object_id, interface)
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
        local succ = ichest.set_amount(gameplay_core.get_world(), e[component], 1, slot.amount + 1)
        if not succ then
            print("failed to place")
            goto continue
        end

        ::continue::
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
        local sp_x, sp_y = math3d.index(icamera_controller.world_to_screen(object.srt.t), 1, 2)
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if iprototype.has_type(typeobject.type, "assembling") then
            local ingredients, results = assembling_common.get(gameplay_core.get_world(), e)
            if #results <= 0 then
                print("recipe not set yet")
                goto continue
            end

            local msgs = {}
            local inventory_bar = {}
            for i = 1, #results do
                local available = ibackpack.move_to_backpack(gameplay_core.get_world(), e.chest, #ingredients + i)
                if available > 0 then
                    local typeitem = iprototype.queryById(results[i].id)
                    msgs[#msgs + 1] = {icon = typeitem.item_icon, name = typeitem.name, count = available}
                    if #inventory_bar < 4 then
                        inventory_bar[#inventory_bar+1] = {icon = typeitem.item_icon, count = available}
                    end
                end
            end

            iui.send("ui/message_pop.rml", "item", {action = "up", left = sp_x, top = sp_y, items = msgs})
            iui.call_datamodel_method("ui/construct.rml", "update_inventory_bar", inventory_bar)

        elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub") then
            local chest_component = ichest.get_chest_component(e)
            local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
            if not slot then
                print("item not set yet")
                goto continue
            end
            local available = ibackpack.move_to_backpack(gameplay_core.get_world(), e[chest_component], 1)
            if available > 0 then
                local typeitem = iprototype.queryById(slot.item)
                iui.send("ui/message_pop.rml", "item", {action = "up", left = sp_x, top = sp_y, items = {{icon = assert(typeitem.item_icon), name = typeitem.name, count = available}}})
                iui.call_datamodel_method("ui/construct.rml", "update_inventory_bar", {{icon = assert(typeitem.item_icon), count = available}})

                if e.station_producer or e.station_consumer then
                    e.station_changed = true
                end
            end
        elseif iprototype.has_type(typeobject.type, "chest") then
            local message = {}
            local inventory_bar = {}
            for i = 1, ichest.MAX_SLOT do
                local slot = gameplay_core.get_world():container_get(e.chest, i)
                if not slot then
                    break
                end

                local available = ibackpack.move_to_backpack(gameplay_core.get_world(), e.chest, i)
                if available > 0 then
                    local typeobject = iprototype.queryById(slot.item)
                    message[#message + 1] = {icon = assert(typeobject.item_icon), name = typeobject.name, count = available}
                    if #inventory_bar < 4 then
                        inventory_bar[#inventory_bar + 1] = {icon = assert(typeobject.item_icon), count = available}
                    end
                end
            end
            iui.send("ui/message_pop.rml", "item", {action = "up", left = sp_x, top = sp_y, items = message})
            iui.call_datamodel_method("ui/construct.rml", "update_inventory_bar", inventory_bar)

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
                iui.leave()
                iui.redirect("ui/construct.rml", "unselected")
            end
        else
            assert(false)
        end

        ::continue::
    end

    for _, _, _, object_id in place_item_mb:unpack() do
        local object = assert(objects:get(object_id))
        local sp = icamera_controller.world_to_screen(object.srt.t)
        local sp_x, sp_y = math3d.index(sp, 1, 2)
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        if iprototype.has_type(typeobject.type, "assembling") then
            local ingredients = assembling_common.get(gameplay_core.get_world(), e)
            local msgs = {}
            local inventory_bar = {}
            for idx, ingredient in ipairs(ingredients) do
                if ingredient.demand_count > ingredient.count then
                    local exist = ibackpack.count(gameplay_core.get_world(), ingredient.id)
                    local c = math.min(ingredient.demand_count - ingredient.count, exist)
                    if ibackpack.pickup(gameplay_core.get_world(), ingredient.id, c) then
                        gameplay_core.get_world():container_set(e.chest, idx, {amount = ingredient.demand_count})
                        local typeitem = iprototype.queryById(ingredient.id)
                        msgs[#msgs + 1] = {icon = typeitem.item_icon, name = typeitem.name, count = c}
                        if #inventory_bar < 4 then
                            inventory_bar[#inventory_bar + 1] = {icon = typeitem.item_icon, count = c}
                        end
                    end
                end
            end
            if #msgs > 0 then
                iui.send("ui/message_pop.rml", "item", {action = "down", left = sp_x, top = sp_y, items = msgs})
            end
            iui.call_datamodel_method("ui/construct.rml", "update_inventory_bar", inventory_bar)
        elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer", "hub") then
            local chest_component = ichest.get_chest_component(e)
            local slot = ichest.chest_get(gameplay_core.get_world(), e[chest_component], 1)
            if not slot then
                print("item not set yet")
                goto continue
            end

            local c = ibackpack.get_placeable_count(gameplay_core.get_world(), slot.item, ichest.get_space(slot))
            if c <= 0 then
                goto continue
            end
            if not ibackpack.pickup(gameplay_core.get_world(), slot.item, c) then
                print("failed to place")
                goto continue
            end
            local succ = ichest.set_amount(gameplay_core.get_world(), e[chest_component], 1, ichest.get_amount(slot) + c)
            if not succ then
                print("failed to place")
                goto continue
            end
            local typeitem = iprototype.queryById(slot.item)
            iui.send("ui/message_pop.rml", "item", {action = "down", left = sp_x, top = sp_y, items = {{icon = typeitem.item_icon, name = typeitem.name, count = c}}})
            iui.call_datamodel_method("ui/construct.rml", "update_inventory_bar", {{icon = typeitem.item_icon, count = c}})

            if e.station_producer or e.station_consumer then
                e.station_changed = true
            end
        elseif iprototype.has_type(typeobject.type, "laboratory") then
            local component = "chest"
            local msgs = {}
            local inventory_bar = {}
            for i = 1, ichest.MAX_SLOT do
                local slot = ichest.chest_get(gameplay_core.get_world(), e[component], i)
                if not slot then
                    break
                end

                local c = ibackpack.get_placeable_count(gameplay_core.get_world(), slot.item, ichest.get_space(slot))
                if c > 0 and ibackpack.pickup(gameplay_core.get_world(), slot.item, c) then
                    local succ = ichest.set_amount(gameplay_core.get_world(), e[component], i, ichest.get_amount(slot) + c)
                    if not succ then
                        break
                    end
                    local typeitem = iprototype.queryById(slot.item)
                    msgs[#msgs+1] = {icon = typeitem.item_icon, name = typeitem.name, count = c}

                    if #inventory_bar < 4 then
                        inventory_bar[#inventory_bar+1] = {icon = typeitem.item_icon, count = c}
                    end
                end
            end
            iui.send("ui/message_pop.rml", "item", {action = "down", left = sp_x, top = sp_y, items = msgs})
            iui.call_datamodel_method("ui/construct.rml", "update_inventory_bar", inventory_bar)

        else
            assert(false)
        end

        ::continue::
    end
end

return M