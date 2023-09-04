local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local ichest = require "gameplay.interface.chest"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local prefab_slots = require("engine.prefab_parser").slots
local iom = ecs.require "ant.objcontroller|obj_motion"
local math3d = require "math3d"
local station_sys = ecs.system "station_system"
local gameplay_core = require "gameplay.core"

local function calcItemSRT(building_srt, slot_srt)
    local building_mat = math3d.matrix {s = building_srt.s, r = building_srt.r, t = building_srt.t}
    local mat = math3d.matrix {s = slot_srt.s, r = slot_srt.r, t = slot_srt.t}
    local mat = math3d.mul(building_mat, mat)
    return math3d.srt(mat)
end

local function createItemModel(prefab, s, r, t)
    return world:create_instance {
        prefab = prefab,
        on_message = function (self, event, ...)
            assert(event == "set_srt", "invalid message")
            local root <close> = world:entity(self.tag["*"][1])
            iom.set_srt(root, calcItemSRT(...))
        end,
        on_ready = function (self)
            local root <close> = world:entity(self.tag['*'][1])
            iom.set_srt(root, s, r, t)
        end
    }
end

local function createShelf(building_srt, e, item_id)
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

    local slot = assert(prefab_slots("/pkg/vaststars.resources/" .. typeobject_building.model).shelf)
    local typeobject_item = iprototype.queryById(item_id)
    local prefab = "/pkg/vaststars.resources/" .. typeobject_item.item_model
    local item_model = createItemModel(prefab, calcItemSRT(building_srt, slot.scene))
    local function remove()
        world:remove_instance(item_model)
    end
    local function on_position_change(self, building_srt)
        world:instance_message(item_model, "set_srt", building_srt, slot.scene)
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
            station_shelf = createShelf(object.srt, e, item_id)
            global.buildings[object.id].station_shelf = station_shelf
        end
        ::continue::
    end
end