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
local set_item2_mb = mailbox:sub {"set_item2"}
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
    local gameplay_world = gameplay_core.get_world()

    if iprototype.has_type(typeobject.type, "assembling") then
        if e.assembling.recipe == 0 then
            return 0
        end

        local recipe = iprototype.queryById(e.assembling.recipe)
        local ingredients_n <const> = #recipe.ingredients//4 - 1
        local results_n <const> = #recipe.results//4 - 1
        local chest_component = ichest.get_chest_component(e)

        local c
        for i = 1, results_n do
            local idx = ingredients_n + i
            local slot = assert(ichest.get(gameplay_world, e[chest_component], idx))
            if iprototype.is_fluid_id(slot.item) then
                goto continue
            end
            assert(slot.item ~= 0)
            if c then -- the number of non-fluid outputs is greater than 1
                return "+"
            end
            c = ibackpack.get_moveable_count(gameplay_world, slot.item, ichest.get_amount(slot))
            ::continue::
        end
        return c or 0

    elseif iprototype.check_types(typeobject.name, PICKUP_TYPES) then
        local chest_component = ichest.get_chest_component(e)
        local c
        for i = 1, ichest.MAX_SLOT do
            local slot = ichest.get(gameplay_world, e[chest_component], i)
            if not slot then
                break
            end
            if slot.item == 0 then
                goto continue
            end
            assert(not iprototype.is_fluid_id(slot.item))
            if c then -- the number of non-fluid outputs is greater than 1
                return "+"
            end
            c = ibackpack.get_moveable_count(gameplay_world, slot.item, ichest.get_amount(slot))
            ::continue::
        end

        return c or 0
    else
        assert(false)
    end
end

local function __get_placeable_count(object_id)
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    local gameplay_world = gameplay_core.get_world()

    if iprototype.has_type(typeobject.type, "assembling") then
        if e.assembling.recipe == 0 then
            return 0
        end

        local recipe = iprototype.queryById(e.assembling.recipe)
        local ingredients_n <const> = #recipe.ingredients//4 - 1
        local ingredient, ingredient_c, ingredient_idx
        for idx = 1, ingredients_n do
            local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
            if not iprototype.is_fluid_id(id) then
                if ingredient then -- the number of non-fluid inputs is greater than 1
                    return "+"
                end
                ingredient, ingredient_c, ingredient_idx = id, n, idx
            end
        end

        if not ingredient then
            return 0
        end

        local chest_component = ichest.get_chest_component(e)
        local slot = assert(ichest.get(gameplay_world, e[chest_component], ingredient_idx))
        local available = ingredient_c - ichest.get_amount(slot)
        if available <= 0 then
            return 0
        end
        return ibackpack.get_placeable_count(gameplay_world, ingredient, available)

    elseif iprototype.check_types(typeobject.name, PLACE_TYPES) then
        local chest_component = ichest.get_chest_component(e)
        local c
        for i = 1, ichest.MAX_SLOT do
            local slot = ichest.get(gameplay_world, e[chest_component], i)
            if not slot then
                break
            end
            if slot.item == 0 then
                goto continue
            end
            assert(not iprototype.is_fluid_id(slot.item))

            local space = ichest.get_space(slot)
            local available = ibackpack.get_placeable_count(gameplay_world, slot.item, space)
            if available < 0 then
                goto continue
            end

            if c then
                return "+"
            end
            c = available
            ::continue::
        end

        return c or 0
    else
        assert(false)
    end
end

local __moveable_count_update = interval_call(300, function(datamodel, object_id)
    datamodel.pickup_item_count = __get_moveable_count(object_id)
    datamodel.place_item_count = __get_placeable_count(object_id)
    return false
end, false)

local function getChestSlotItems(e)
    local chest_component = ichest.get_chest_component(e)
    if not chest_component then
        return {}
    end

    local gameplay_world = gameplay_core.get_world()
    local t = {}
    for i = 1, ichest.MAX_SLOT do
        local slot = gameplay_world:container_get(e[chest_component], i)
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
        local items = getChestSlotItems(e)
        set_item_icon1 = (items[1] and items[1] ~= 0) and iprototype.queryById(items[1]).item_icon or ""
    end
    if e.station_consumer then
        station_lorry_increase = true
        station_lorry_decrease = true
        set_item1 = true
        local items = getChestSlotItems(e)
        set_item_icon1 = (items[1] and items[1] ~= 0) and iprototype.queryById(items[1]).item_icon or ""
    end
    if e.hub then
        local items = getChestSlotItems(e)
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

local function station_set_item(gameplay_world, e, item)
    istation.set_item(gameplay_world, e, item)
end

local function gen_set_item(idx)
    return function (gameplay_world, e, item)
        local chest = e[ichest.get_chest_component(e)]
        local items = {}

        for i = 1, ichest.MAX_SLOT do
            local slot = gameplay_world:container_get(chest, i)
            if not slot then
                break
            end
            if slot.item == 0 then
                goto continue
            end
            items[#items+1] = slot.item
            ::continue::
        end

        if #items < 1 or (#items == 1 and idx == 1) then
            for i = 1, 2 do
                items[i] = item
            end
        else
            items[idx] = item
        end
        ihub.set_item(gameplay_world, e, items)
    end
end

local function gen_get_item(idx)
    return function(gameplay_world, e)
        local chest_component = ichest.get_chest_component(e)
        local slot = ichest.get(gameplay_world, e[chest_component], idx)
        if not slot then
            return
        end
        return slot.item
    end
end

function M:update_item_icon(datamodel)
    local object = assert(objects:get(datamodel.object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    local items = getChestSlotItems(e)
    datamodel.set_item1, datamodel.set_item2 = items[1] ~= nil, items[2] ~= nil
    datamodel.set_item_icon1 = (items[1] and items[1] ~= 0) and iprototype.queryById(items[1]).item_icon or ""
    datamodel.set_item_icon2 = (items[2] and items[2] ~= 0) and iprototype.queryById(items[2]).item_icon or ""
end

function M:stage_ui_update(datamodel, object_id)
    local object = assert(objects:get(object_id))

    __moveable_count_update(datamodel, object_id)

    for _, _, _, object_id in set_recipe_mb:unpack() do
        iui.open({"ui/recipe_config.rml"}, object_id)
    end

    for _, _, _, object_id in set_item_mb:unpack() do
        local typeobject = iprototype.queryByName(object.prototype_name)
        local interface = {}
        if iprototype.has_type(typeobject.type, "hub") then
            interface.get_item = gen_get_item(1)
            interface.set_item = gen_set_item(1)
        elseif iprototype.has_types(typeobject.type, "station_producer", "station_consumer") then
            interface.get_item = gen_get_item(1)
            interface.set_item = station_set_item
        else
            assert(false)
        end
        iui.open({"ui/item_config.rml"}, object_id, interface)
    end

    for _, _, _, object_id in set_item2_mb:unpack() do
        local typeobject = iprototype.queryByName(object.prototype_name)
        local interface = {}
        if iprototype.has_type(typeobject.type, "hub") then
            interface.get_item = gen_get_item(2)
            interface.set_item = gen_set_item(2)
        else
            assert(false)
        end
        iui.open({"ui/item_config.rml"}, object_id, interface)
    end

    for _ in lorry_factory_inc_lorry_mb:unpack() do
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))

        local component = "chest"
        local slot = ichest.get(gameplay_core.get_world(), e[component], 1)
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
        ichest.set(gameplay_core.get_world(), e[component], 1, {amount = slot.amount + 1})
        ::continue::
    end

    for _ in station_weight_increase_mb:unpack() do
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        istation.set_weights(gameplay_core.get_world(), e, math.min(e.station_producer.weights + 1, MAX_STATION_WEIGHTS))
    end

    for _ in station_weight_decrease_mb:unpack() do
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        istation.set_weights(gameplay_core.get_world(), e, math.max(e.station_producer.weights - 1, MIN_STATION_WEIGHTS))
    end

    for _ in station_lorry_increase_mb:unpack() do
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        istation.set_maxlorry(gameplay_core.get_world(), e, e.station_consumer.maxlorry + 1)
    end

    for _ in station_lorry_decrease_mb:unpack() do
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        istation.set_maxlorry(gameplay_core.get_world(), e, math.max(e.station_consumer.maxlorry - 1, 0))
    end

    for _, _, _, message in ui_click_mb:unpack() do
        itask.update_progress("click_ui", message, object.prototype_name)
    end

    for _, _, _, object_id in pickup_item_mb:unpack() do
        local gameplay_world = gameplay_core.get_world()
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))

        local msgs = {}
        if iprototype.has_type(typeobject.type, "assembling") then
            ibackpack.assembling_to_backpack(gameplay_world, e, function(id, n)
                local item = iprototype.queryById(id)
                msgs[#msgs + 1] = {icon = item.item_icon, name = item.name, count = n}
            end)

        elseif iprototype.check_types(typeobject.name, PICKUP_TYPES) then
            ibackpack.chest_to_backpack(gameplay_world, e, function(id, n)
                local item = iprototype.queryById(id)
                msgs[#msgs + 1] = {icon = assert(item.item_icon), name = item.name, count = n}
            end)

            if (e.station_producer or e.station_consumer) and #msgs > 0 then
                e.station_changed = true
            end

            if iprototype.has_type(typeobject.type, "chest") then
                local chest_component = ichest.get_chest_component(e)
                if not ichest.has_item(gameplay_world, e[chest_component]) then
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
            end
        else
            assert(false)
        end

        local sp_x, sp_y = math3d.index(icamera_controller.world_to_screen(object.srt.t), 1, 2)
        iui.send("ui/message_pop.rml", "item", {action = "up", left = sp_x, top = sp_y, items = msgs})
        iui.call_datamodel_method("ui/construct.rml", "update_inventory_bar", msgs)
    end

    for _ in place_item_mb:unpack() do
        local gameplay_world = gameplay_core.get_world()
        local typeobject = iprototype.queryByName(object.prototype_name)
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))

        local msgs = {}
        if iprototype.has_type(typeobject.type, "assembling") then
            ibackpack.backpack_to_assembling(gameplay_world, e, function(id, n)
                local item = iprototype.queryById(id)
                msgs[#msgs+1] = {icon = item.item_icon, name = item.name, count = n}
            end)

        elseif iprototype.check_types(typeobject.name, PLACE_TYPES) then
            ibackpack.backpack_to_chest(gameplay_world, e, function(id, n)
                local item = iprototype.queryById(id)
                msgs[#msgs+1] = {icon = item.item_icon, name = item.name, count = n}
            end)

            if e.station_producer or e.station_consumer then
                e.station_changed = true
            end
        else
            assert(false)
        end

        local sp_x, sp_y = math3d.index(icamera_controller.world_to_screen(object.srt.t), 1, 2)
        iui.send("ui/message_pop.rml", "item", {action = "down", left = sp_x, top = sp_y, items = msgs})
        iui.call_datamodel_method("ui/construct.rml", "update_inventory_bar", msgs)
    end
end

return M