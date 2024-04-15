local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local CHEST_TYPE_CONVERT <const> = {
    [0] = "none",
    [1] = "supply",
    [2] = "demand",
    [3] = "transit",
}
local mathpkg = import_package "ant.math"
local mu = mathpkg.util
local CONSTANT <const> = require "gameplay.interface.constant"
local CHANGED_FLAG_STATION <const> = CONSTANT.CHANGED_FLAG_STATION
local CHANGED_FLAG_DEPOT <const> = CONSTANT.CHANGED_FLAG_DEPOT

local math3d = require "math3d"
local gameplay_core = require "gameplay.core"
local iui = ecs.require "engine.system.ui_system"
local icamera_controller = ecs.require "engine.system.camera_controller"
local interval_call = ecs.require "engine.interval_call"
local gameplay = import_package "vaststars.gameplay"
local igameplay_station = gameplay.interface "station"
local iviewport = ecs.require "ant.render|viewport.state"

local ui_click_mb = mailbox:sub {"ui_click"}
-- menu events
local set_recipe_mb = mailbox:sub {"set_recipe"}
local lorry_factory_inc_lorry_mb = mailbox:sub {"lorry_factory_inc_lorry"}
local set_item_mb = mailbox:sub {"set_item"}
local remove_lorry_mb = mailbox:sub {"remove_lorry"}
local move_mb = mailbox:sub {"move"}
local copy_md = mailbox:sub {"copy"}
local inventory_mb = mailbox:sub {"inventory"}
local teardown_mb = mailbox:sub {"teardown"}
local build_mb = mailbox:sub {"build"}
local show_item_list_mb = mailbox:sub {"show_item_list"}
local building_to_backpack_mb = mailbox:sub {"building_to_backpack"}
local backpack_to_building_mb = mailbox:sub {"backpack_to_building"}

local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local ibackpack = require "gameplay.interface.backpack"
local igameplay = ecs.require "gameplay.gameplay_system"
local iobject = ecs.require "object"
local global = require "global"
local icoord = require "coord"
local itask = ecs.require "task"
local objects = require "objects"
local handler = ecs.require "ui_datamodel.common.building_menu_handler"
local show_message = ecs.require "show_message".show_message
local show_items_mesage = ecs.require "show_message".show_items_mesage

---------------
local M = {}
function M.create(gameplay_eid, longpress)
    iui.register_leave("/pkg/vaststars.resources/ui/building_menu.html")

    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local typeobject
    if e.lorry then
        typeobject = iprototype.queryById(e.lorry.prototype)
    else
        typeobject = iprototype.queryById(e.building.prototype)
    end

    local set_recipe = false
    local lorry_factory_inc_lorry = false
    local set_item = false
    local remove_lorry = false
    local move = false
    local copy = false
    local inventory = false
    local teardown = false
    local build = false
    local show_item_list = false
    local building_to_backpack = false
    local backpack_to_building = false

    if longpress then
        teardown = true
    else
        build = e.chest ~= nil
        set_recipe = (e.assembling ~= nil)
        lorry_factory_inc_lorry = (e.factory == true)
        set_item = e.station or (e.chest and CHEST_TYPE_CONVERT[typeobject.chest_type] == "transit" or false)
        remove_lorry = (e.lorry ~= nil)
        move = true
        copy = true
        inventory = iprototype.has_type(typeobject.type, "base")
        show_item_list = e.chest ~= nil
        building_to_backpack = e.chest ~= nil
        backpack_to_building = not building_to_backpack
    end

    local status = {
        build = build,
        set_recipe = set_recipe,
        lorry_factory_inc_lorry = lorry_factory_inc_lorry,
        set_item = set_item,
        remove_lorry = remove_lorry,
        move = move,
        copy = copy,
        inventory = inventory,
        teardown = teardown,
        show_item_list = show_item_list,
        building_to_backpack = building_to_backpack,
        backpack_to_building = backpack_to_building,
    }

    local buttons = handler(typeobject.name, status)
    return {
        status = status,
        buttons = buttons,
        desc = "",
    }
end

local function station_set_item(gameplay_world, e, type, item)
    local items = {}
    local found = false

    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.station, i)
        if not slot then
            break
        end

        local limit = slot.limit
        if slot.item == item then
            limit = limit + 1
            found = true
        end
        items[#items+1] = {slot.type, slot.item, limit}
    end

    if not found then
        local typeobject = iprototype.queryById(item)
        items[#items+1] = {type, item, typeobject.station_capacity or 1}
    end

    igameplay_station.set_item(gameplay_world, e, items)
    gameplay_core.set_changed(CHANGED_FLAG_STATION)
end

local function station_remove_item(gameplay_world, e, slot_index, item)
    local items = {}

    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.station, i)
        if not slot then
            break
        end

        if slot.item == item then
            if slot.limit - 1 > 0 then
                items[#items+1] = {slot.type, slot.item, slot.limit - 1}
            end
        else
            items[#items+1] = {slot.type, slot.item, slot.limit}
        end
    end

    igameplay_station.set_item(gameplay_world, e, items)
    gameplay_core.set_changed(CHANGED_FLAG_STATION)
end

local function chest_set_item(gameplay_world, e, type, item)
    local items = {}
    local typeobject = iprototype.queryById(e.building.prototype)
    for i = 1, ichest.get_max_slot(typeobject) do
        local slot = ichest.get(gameplay_world, e.chest, i)
        if not slot then
            break
        end
        items[#items+1] = {slot.type, slot.item}
    end

    items[#items+1] = {CHEST_TYPE_CONVERT[typeobject.chest_type], item}
    ichest.set(gameplay_world, e, items)
    gameplay_core.set_changed(CHANGED_FLAG_DEPOT)
end

local function chest_remove_item(gameplay_world, e, slot_index)
    local items = {}

    for i = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.chest, i)
        if not slot then
            break
        end

        if i ~= slot_index then
            items[#items+1] = {slot.type, slot.item}
        end
    end

    ichest.set(gameplay_world, e, items)
    gameplay_core.set_changed(CHANGED_FLAG_DEPOT)
end

function M.update(datamodel, gameplay_eid)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local typeobject
    if e.lorry then
        typeobject = iprototype.queryById(e.lorry.prototype)
    else
        typeobject = iprototype.queryById(e.building.prototype)
    end

    for _ in move_mb:unpack() do
        iui.leave()
        local object = assert(objects:coord(e.building.x, e.building.y))
        iui.redirect("/pkg/vaststars.resources/ui/construct.html", "move", object.id)
    end

    for _ in copy_md:unpack() do
        assert(e.building)
        local typeobject = iprototype.queryById(e.building.prototype)
        local pos = math3d.vector(icoord.position(e.building.x, e.building.y, iprototype.rotate_area(typeobject.area, e.building.direction)))
        iui.redirect("/pkg/vaststars.resources/ui/construct.html", "copy", iprototype.item(typeobject).name, math3d.mark(pos))
    end

    for _ in set_recipe_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/recipe_config.html"}, gameplay_eid)
    end

    for _ in set_item_mb:unpack() do
        local interface = {}
        if e.station then
            interface.set_item = station_set_item
            interface.remove_item = station_remove_item
            interface.supply_button = true
            interface.demand_button = true
            interface.show_add = false
        else
            interface.set_item = chest_set_item
            interface.remove_item = chest_remove_item
            interface.show_add = true
        end
        iui.open({rml = "/pkg/vaststars.resources/ui/item_config.html"}, gameplay_eid, interface)
    end

    for _ in lorry_factory_inc_lorry_mb:unpack() do
        local gameplay_world = gameplay_core.get_world()
        local slot = assert(ichest.get(gameplay_world, e.chest, 1))
        if slot.limit <= ichest.get_amount(slot) then
            show_message("the lorries are full at the factory")
            goto continue
        end

        local base = ibackpack.get_base_entity(gameplay_world)
        if not ibackpack.pickup(gameplay_world, base, slot.item, 1) then
            show_message("the number of lorries is insufficient")
            goto continue
        end
        ichest.place_at(gameplay_world, e, 1, 1)
        ::continue::
    end

    for _, _, _, message in ui_click_mb:unpack() do
        itask.update_progress("click_ui", message, typeobject.name)
    end

    for _ in show_item_list_mb:unpack() do
        iui.call_datamodel_method("/pkg/vaststars.resources/ui/detail_panel.html", "update_area_id", "expanded-chest-info")
    end

    for _ in remove_lorry_mb:unpack() do
        e.lorry_willremove = true
        iui.leave()
        iui.redirect("/pkg/vaststars.resources/ui/construct.html", "unselected")
    end

    for _ in inventory_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/inventory.html"})
    end

    for _ in teardown_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/construct.html", "teardown", gameplay_eid)
    end

    for _ in build_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/construct.html", "build_mode", gameplay_eid)
    end

    for _ in building_to_backpack_mb:unpack() do
        if iui.call_datamodel_method("/pkg/vaststars.resources/ui/detail_panel.html", "update_area_id", "expanded-depot-info") then
            iui.call_datamodel_method("/pkg/vaststars.resources/ui/detail_panel.html", "building_to_backpack", false)
            datamodel.status.building_to_backpack = false
            datamodel.status.backpack_to_building = true
            datamodel.buttons = handler(typeobject.name, datamodel.status)
        end
    end

    for _ in backpack_to_building_mb:unpack() do
        if iui.call_datamodel_method("/pkg/vaststars.resources/ui/detail_panel.html", "update_area_id", "expanded-depot-info") then
            iui.call_datamodel_method("/pkg/vaststars.resources/ui/detail_panel.html", "building_to_backpack", true)
            datamodel.status.building_to_backpack = true
            datamodel.status.backpack_to_building = false
            datamodel.buttons = handler(typeobject.name, datamodel.status)
        end
    end
end

return M