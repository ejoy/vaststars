local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local vsobject_manager = ecs.require "vsobject_manager"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local math3d    = require "math3d"
local mu = import_package "ant.math".util

local set_recipe_mb = mailbox:sub {"set_recipe"}
local set_item_mb = mailbox:sub {"set_item"}
local close_mb = mailbox:sub {"close"}
local road_builder_mb = mailbox:sub {"road_builder"}
local pipe_builder_mb = mailbox:sub {"pipe_builder"}
local construction_center_build_mb = mailbox:sub {"construction_center_build"}
local construction_center_stop_build_mb = mailbox:sub {"construction_center_stop_build"}
local lorry_factory_inc_lorry_mb = mailbox:sub {"lorry_factory_inc_lorry"}
local lorry_factory_stop_build_mb = mailbox:sub {"lorry_factory_stop_build"}
local item_transfer_subscribe_mb = mailbox:sub {"item_transfer_subscribe"}
local item_transfer_unsubscribe_mb = mailbox:sub {"item_transfer_unsubscribe"}
local item_transfer_place_mb = mailbox:sub {"item_transfer_place"}

local ichest = require "gameplay.interface.chest"
local assembling_common = require "ui_datamodel.common.assembling"
local gameplay = import_package "vaststars.gameplay"
local iassembling = gameplay.interface "assembling"
local gameplay = import_package "vaststars.gameplay"
local ihub = gameplay.interface "hub"
local global = require "global"
local interval_call = ecs.require "engine.interval_call"
local item_transfer = require "item_transfer"

local function __show_set_item(typeobject)
    return iprototype.has_type(typeobject.type, "hub") or iprototype.has_type(typeobject.type, "station")
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

local function __construction_center_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName(object.prototype_name)
    if typeobject.construction_center ~= true then
        return
    end

    if e.assembling.recipe == 0 then
        datamodel.construction_center_icon = ""
        datamodel.construction_center_count = 0
        datamodel.construction_center_build, datamodel.construction_center_stop_build = false, false
    else
        local ingredients, results = assembling_common.get(gameplay_core.get_world(), e)
        assert(results and results[1])
        datamodel.construction_center_icon = results[1].icon
        datamodel.construction_center_count = results[1].count
        datamodel.construction_center_build, datamodel.construction_center_stop_build = true, true
        datamodel.construction_center_ingredients = ingredients
    end
end

local function __lorry_factory_update(datamodel, object_id)
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

local function __station_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName(object.prototype_name)
    if not iprototype.has_type(typeobject.type, "station") then
        return
    end
    local c = ichest.chest_get(gameplay_core.get_world(), e.station, 1)
    if not c then
        return
    end
    local item_typeobject = iprototype.queryById(c.item)
    datamodel.station_item_icon = item_typeobject.icon
    datamodel.station_item_count = c.amount
    datamodel.station_weight_increase = true
    datamodel.station_weight_decrease = true
end

local function __item_transfer_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName(object.prototype_name)

    if iprototype.has_type(typeobject.type, "assembling") or
       iprototype.has_type(typeobject.type, "chest") or
       iprototype.has_type(typeobject.type, "hub") then
        if not global.item_transfer_src then
            if typeobject.name == "指挥中心" or typeobject.name == "建造中心" then -- TODO: remove hardcode
                datamodel.item_transfer_subscribe = false
            else
                datamodel.item_transfer_subscribe = true
            end
        else
            datamodel.item_transfer_subscribe = false
        end
    else
        datamodel.item_transfer_subscribe = false
    end

    datamodel.item_transfer_unsubscribe = (global.item_transfer_src ~= nil) and (global.item_transfer_src == object_id)

    if iprototype.has_type(typeobject.type, "assembling") or
       iprototype.has_type(typeobject.type, "hub") then
        if global.item_transfer_src and global.item_transfer_src ~= object_id then
            datamodel.item_transfer_place = true
        else
            datamodel.item_transfer_place = false
        end
    else
        datamodel.item_transfer_place = false
    end

    local movable_items, movable_items_hash, placeable_items
    do
        if global.item_transfer_src then
            local object = assert(objects:get(global.item_transfer_src))
            local e = gameplay_core.get_entity(assert(object.gameplay_eid))
            movable_items, movable_items_hash = item_transfer.get_movable_items(e)
            assert(movable_items and movable_items_hash)
        else
            local object = assert(objects:get(object_id))
            local e = gameplay_core.get_entity(assert(object.gameplay_eid))
            movable_items, movable_items_hash = item_transfer.get_movable_items(e)
            assert(movable_items and movable_items_hash)
        end
    end

    do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        placeable_items = assert(item_transfer.get_placeable_items(e))
    end

    if datamodel.item_transfer_place == true then
        datamodel.item_transfer_place = false
        for _, slot in ipairs(placeable_items or {}) do
            if movable_items_hash[slot.item] then
                datamodel.item_transfer_place = true
                break
            end
        end
    end
end
local __item_transfer_update_interval = interval_call(300, __item_transfer_update)

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
    local recipe_name = ""

    if iprototype.has_type(typeobject.type, "assembling") then
        if e.assembling.recipe ~= 0 then
            local recipe_typeobject = iprototype.queryById(e.assembling.recipe)
            recipe_name = recipe_typeobject.name
        end
    end

    local datamodel = {
        show_set_recipe = show_set_recipe,
        show_set_item = show_set_item,
        show_road_builder = typeobject.road_builder,
        show_pipe_builder = typeobject.pipe_builder,
        construction_center_icon = "",
        construction_center_count = 0,
        construction_center_ingredients = {},
        construction_center_multiple = 0,
        construction_center_build = false,
        construction_center_stop_build = false,
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
        item_transfer_subscribe = false,
        item_transfer_place = false,
        item_transfer_unsubscribe = false,
        recipe_name = recipe_name,
        object_id = object_id,
        left = ui_x,
        top = ui_y,
        object_position = object_position,
    }
    __construction_center_update(datamodel, object_id)
    __item_transfer_update(datamodel, object_id)

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
    local station = e.station
    gameplay_world:container_destroy(station)

    local typeobject = iprototype.queryById(e.building.prototype)
    local typeobject_item = iprototype.queryByName(prototype_name)
    local c = {}
    c[#c+1] = gameplay_world:chest_slot {
        type = typeobject.chest_type,
        item = typeobject_item.id,
        limit = 1,
    }
    station.chest = gameplay_world:container_create(table.concat(c))

    e.chest.chest = station.chest
end

local function __get_station_first_item(gameplay_world, e)
    local slot = ichest.chest_get(gameplay_world, e.station, 1)
    if slot then
        return slot.item
    end
end

function M:update(datamodel, object_id, recipe_name)
    if datamodel.object_id ~= object_id then
        return
    end
    datamodel.recipe_name = recipe_name
    __construction_center_update(datamodel, object_id)
    __lorry_factory_update(datamodel, object_id)
    __item_transfer_update(datamodel, object_id)
    return true
end

function M:stage_ui_update(datamodel, object_id)
    -- show pickup material button when object has result
    local object = objects:get(object_id)
    if not object then
        assert(false)
    end

    __construction_center_update(datamodel, object_id)
    __lorry_factory_update(datamodel, object_id)
    __drone_depot_update(datamodel, object_id)
    __station_update(datamodel, object_id)
    __item_transfer_update_interval(datamodel, object_id)

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
        elseif iprototype.has_type(typeobject.type, "station") then
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
        local _, results = assembling_common.get(gameplay_core.get_world(), e)
        if not results[1] then -- Not yet set recipe
            goto continue
        end
        local multiple = (results[1].limit // results[1].output_count) + 1
        if typeobject.recipe_max_limit and typeobject.recipe_max_limit.resultsLimit >= multiple then
            datamodel.construction_center_multiple = multiple
            iassembling.set_option(gameplay_core.get_world(), e, {ingredientsLimit = multiple, resultsLimit = multiple})
            gameplay_core.build()
        end
        ::continue::
    end

    for _, _, _, object_id in construction_center_stop_build_mb:unpack() do
        local object = assert(objects:get(object_id))
        local e = gameplay_core.get_entity(assert(object.gameplay_eid))
        local _, results = assembling_common.get(gameplay_core.get_world(), e)
        if not results[1] then -- Not yet set recipe
            goto continue
        end
        local multiple = 0
        datamodel.construction_center_multiple = multiple
        iassembling.set_option(gameplay_core.get_world(), e, {ingredientsLimit = multiple, resultsLimit = multiple})
        gameplay_core.build()
        ::continue::
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

    for _ in item_transfer_subscribe_mb:unpack() do
        global.item_transfer_src = object_id
        __item_transfer_update(datamodel, object_id)
    end

    for _ in item_transfer_unsubscribe_mb:unpack() do
        global.item_transfer_src = nil
        __item_transfer_update(datamodel, object_id)
    end

    for _ in item_transfer_place_mb:unpack() do
        local movable_items, movable_items_hash, placeable_items
        do
            assert(global.item_transfer_src)
            local src_object = assert(objects:get(global.item_transfer_src))
            local e = gameplay_core.get_entity(assert(src_object.gameplay_eid))
            movable_items, movable_items_hash = item_transfer.get_movable_items(e)
            assert(movable_items and movable_items_hash)
        end
        local dst_object = assert(objects:get(object_id))
        do
            local e = gameplay_core.get_entity(assert(dst_object.gameplay_eid))
            placeable_items = assert(item_transfer.get_placeable_items(e))
        end

        local items = {}
        for _, dst in ipairs(placeable_items) do
            local i = movable_items_hash[dst.item]
            if i then
                local src = movable_items[i]
                local count = math.min(dst.count, src.count)
                assert(ichest.chest_pickup(gameplay_core.get_world(), src.chest, src.item, count))
                ichest.chest_place(gameplay_core.get_world(), dst.chest, dst.item, count)
                local typeobject = iprototype.queryById(dst.item)
                items[#items + 1] = {icon = typeobject.icon, name = typeobject.name, count = count}
            end
        end
        local mq = w:first("main_queue camera_ref:in render_target:in")
        local ce <close> = w:entity(mq.camera_ref, "camera:in")
        local vp = ce.camera.viewprojmat
        local vr = mq.render_target.view_rect
        local sp = math3d.totable(mu.world_to_screen(vp, vr, dst_object.srt.t))
        iui.open({"message_pop.rml"}, {left = sp[1]..'px', top = sp[2]..'px', show_id = "item", items = items})
    end
end

return M