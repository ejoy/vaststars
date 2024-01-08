local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local CHEST_TYPE_CONVERT <const> = {
    [0] = "none",
    [1] = "supply",
    [2] = "demand",
    [3] = "transit",
}

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

local set_recipe_mb = mailbox:sub {"set_recipe"}
local lorry_factory_inc_lorry_mb = mailbox:sub {"lorry_factory_inc_lorry"}
local transfer_source_mb = mailbox:sub {"transfer_source"}
local set_transfer_source_mb = mailbox:sub {"set_transfer_source"}
local transfer_mb = mailbox:sub {"transfer"}
local set_item_mb = mailbox:sub {"set_item"}
local remove_lorry_mb = mailbox:sub {"remove_lorry"}
local move_mb = mailbox:sub {"move"}
local copy_md = mailbox:sub {"copy"}
local inventory_mb = mailbox:sub {"inventory"}
local teardown_mb = mailbox:sub {"teardown"}
local ui_click_mb = mailbox:sub {"ui_click"}

local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local iinventory = require "gameplay.interface.inventory"
local igameplay = ecs.require "gameplay.gameplay_system"
local itransfer = require "gameplay.interface.transfer"
local iobject = ecs.require "object"
local global = require "global"
local icoord = require "coord"
local itask = ecs.require "task"
local objects = require "objects"
local handler = ecs.require "ui_datamodel.common.building_menu_handler"
local transfer_source_box = ecs.require "transfer_source_box"
local show_message = ecs.require "show_message".show_message
local show_items_mesage = ecs.require "show_message".show_items_mesage

local function _get_transfer_count()
    local count = 0
    local info = itransfer.get_transfer_info(gameplay_core.get_world())
    local length = 0
    for _, _ in pairs(info) do
        length = length + 1
    end

    if length > 1 then
        count = "+"
    elseif length == 1 then
        local _, amount = next(info)
        count = amount
    else
        count = 0
    end
    return count
end

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
    local transfer_source = false
    local set_transfer_source = false
    local transfer = false
    local set_item = false
    local remove_lorry = false
    local move = false
    local copy = false
    local inventory = false
    local teardown = false

    if longpress then
        teardown = true
    else
        set_recipe = (e.assembling ~= nil)
        lorry_factory_inc_lorry = (e.factory == true)
        transfer_source = itransfer.get_source_eid() == e.eid
        set_transfer_source = not transfer_source and e.chest ~= nil
        if itransfer.get_source_eid() then
            transfer = e.chest ~= nil
        end
        set_item = e.station or (e.chest and CHEST_TYPE_CONVERT[typeobject.chest_type] == "transit" or false)
        remove_lorry = (e.lorry ~= nil)
        move = true
        copy = true
        inventory = iprototype.has_type(typeobject.type, "base")
    end

    local status = {
        set_recipe = set_recipe,
        lorry_factory_inc_lorry = lorry_factory_inc_lorry,
        transfer_source = transfer_source,
        set_transfer_source = set_transfer_source,
        transfer = transfer,
        set_item = set_item,
        remove_lorry = remove_lorry,
        move = move,
        copy = copy,
        inventory = inventory,
        teardown = teardown,

        transfer_count = transfer and _get_transfer_count() or 0,
    }

    local buttons = handler(typeobject.name, status)
    return {
        status = status,
        buttons = buttons,
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

local update = interval_call(300, function(datamodel, typeobject)
    local count = datamodel.status.transfer and _get_transfer_count() or 0
    if datamodel.status.transfer_count ~= count then
        datamodel.status.transfer_count = count
        datamodel.buttons = handler(typeobject.name, datamodel.status)
    end
end)

function M.update(datamodel, gameplay_eid)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local typeobject
    if e.lorry then
        typeobject = iprototype.queryById(e.lorry.prototype)
    else
        typeobject = iprototype.queryById(e.building.prototype)
    end
    update(datamodel, typeobject)

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
        if not iinventory.pickup(gameplay_core.get_world(), slot.item, 1) then
            print("failed to pickup") --TODO: show error message
            goto continue
        end
        ichest.place_at(gameplay_core.get_world(), e, 1, 1)
        ::continue::
    end

    for _, _, _, message in ui_click_mb:unpack() do
        itask.update_progress("click_ui", message, typeobject.name)
    end

    for _ in set_transfer_source_mb:unpack() do
        itransfer.set_source_eid(e.eid)
        datamodel.status.transfer_source = true
        datamodel.status.set_transfer_source = not datamodel.status.transfer_source and e.chest ~= nil
        datamodel.buttons = handler(typeobject.name, datamodel.status)

        local object = assert(objects:coord(e.building.x, e.building.y))
        transfer_source_box.create(object.id)
    end

    for _ in transfer_source_mb:unpack() do
        itransfer.set_source_eid(nil)
        datamodel.status.transfer_source = false
        datamodel.status.set_transfer_source = not datamodel.status.transfer_source and e.chest ~= nil
        datamodel.buttons = handler(typeobject.name, datamodel.status)

        transfer_source_box.remove()
    end

    for _ in transfer_mb:unpack() do
        if not itransfer.get_source_eid() then
            goto continue
        end
        local object = assert(objects:coord(e.building.x, e.building.y))
        local gameplay_world = gameplay_core.get_world()

        local t = {}
        itransfer.transfer(gameplay_world, function(idx, item, n)
            if e.station then
                e.station_changed = true
            end

            if not t[item] then
                t[item] = {idx = idx, n = 0}
            end
            t[item].n = t[item].n + n

            itask.update_progress("transfer", object.prototype_name, iprototype.queryById(item).name, n)
        end)

        local tt = {}
        for item, v in pairs(t) do
            tt[#tt+1] = {item = item, n = v.n, idx = v.idx}
        end
        table.sort(tt, function(a, b) return a.idx < b.idx end)

        if #tt == 0 then
            show_message("transfer nothing")
        end

        local msgs = {}
        for _, v in ipairs(tt) do
            local typeobject = iprototype.queryById(v.item)
            msgs[#msgs+1] = {icon = typeobject.item_icon, name = typeobject.name, count = v.n}
        end
        if #msgs > 0 then
            local sp_x, sp_y = math3d.index(icamera_controller.world_to_screen(object.srt.t), 1, 2)
            show_items_mesage(sp_x, sp_y, msgs)
        end

        local seid = itransfer.get_source_eid()
        local source = assert(gameplay_core.get_entity(seid))
        if source.chest then
            local typeobject = iprototype.queryById(source.building.prototype)
            if not ichest.has_item(gameplay_world, source.chest) and typeobject.chest_destroy then
                local object = assert(objects:coord(source.building.x, source.building.y))

                iobject.remove(object)
                objects:remove(object.id)
                local building = global.buildings[object.id]
                if building then
                    for _, v in pairs(building) do
                        v:remove()
                    end
                end

                igameplay.destroy_entity(seid)
                itransfer.set_source_eid(nil)
                iui.leave()

                transfer_source_box.remove()
            end
        end
        ::continue::
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
end

return M