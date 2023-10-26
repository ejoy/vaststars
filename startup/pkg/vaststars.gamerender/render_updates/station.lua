local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local ichest = require "gameplay.interface.chest"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local station_sys = ecs.system "station_system"
local gameplay_core = require "gameplay.core"
local igroup = ecs.require "group"

local function createShelf(object, e, item_id)
    local typeobject_building = iprototype.queryById(e.building.prototype)
    if typeobject_building.io_shelf == false then
        return {
            on_position_change = function() end,
            remove = function() end,
            item_id = item_id,
        }
    end

    if item_id == 0 then
        return {
            on_position_change = function() end,
            remove = function() end,
            item_id = item_id,
        }
    end

    local vsobject_manager = ecs.require "vsobject_manager"
    local vsobject = assert(vsobject_manager:get(object.id))
    local game_object = vsobject.game_object

    local typeobject_item = iprototype.queryById(item_id)
    local prefab = "/pkg/vaststars.resources/" .. typeobject_item.item_model
    local item_model = world:create_instance {
        group = igroup.id(e.building.x, e.building.y),
        prefab = prefab,
    }

    game_object:send("attach", "shelf", item_model)

    local function remove()
        world:remove_instance(item_model)
    end
    local function on_position_change(self, building_srt)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        item_id = item_id,
    }
end

local function getItem(gameplay_world, chest)
    local slot = ichest.get(gameplay_world, chest, 1)
    return slot and slot.item or 0
end

function station_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "station:in chest:in building:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local station_shelf = assert(global.buildings[object.id]).station_shelf
        local item_id = getItem(gameplay_world, e.chest)
        if not station_shelf or station_shelf.item_id ~= item_id then
            if station_shelf then
                station_shelf:remove()
            end
            station_shelf = createShelf(object, e, item_id)
            global.buildings[object.id].station_shelf = station_shelf
        end
        ::continue::
    end
end