local ecs = ...
local world = ecs.world
local w = world.w

local STATION_SLOTS <const> = {"slot1", "slot2", "slot3", "slot4", "slot5", "slot6", "slot7", "slot8"}

local objects = require "objects"
local ichest = require "gameplay.interface.chest"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local station_sys = ecs.system "station_system"
local gameplay_core = require "gameplay.core"
local igroup = ecs.require "group"
local vsobject_manager = ecs.require "vsobject_manager"
local igame_object = ecs.require "engine.game_object"
local imessage = ecs.require "message_sub"

local function _rebuild(gameplay_world, e, game_object)
    local items = {}
    for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.chest, idx)
        if not slot then
            break
        end
        assert(slot.item ~= 0)

        local item = slot.item
        local show = slot.amount <= 0

        if item ~= 0 then
            local typeobject_item = iprototype.queryById(item)
            local prefab = typeobject_item.item_model
            local item_object = igame_object.create {
                prefab = prefab,
                group_id = igroup.id(e.building.x, e.building.y),
                on_ready = function (self)
                    if not show then
                        imessage:pub("show", self, false)
                    end
                end
            }

            game_object:send("hitch_instance|attach", assert(STATION_SLOTS[idx]), item_object.hitch_instance)
            items[idx] = {item_object = item_object, show = show}
        end
    end
    return items
end

local mt = {}
function mt:remove()
    for idx = 1, #self.items do
        local v = assert(self.items[idx])
        v.item_object:remove()
    end
    self.items = {}
end
function mt:on_position_change(building_srt, dir, gameplay_world, e, game_object)
    self:remove()
    self.items = _rebuild(gameplay_world, e, game_object)
end
function mt:update(gameplay_world, e)
    for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.chest, idx)
        if not slot then
            break
        end
        assert(slot.item ~= 0)

        local v = assert(self.items[idx])
        local show = slot.amount <= 0
        if v.show ~= show then
            imessage:pub("show", v.item_object.hitch_instance, show)
            v.show = show
        end
    end
end

local function create(gameplay_world, e, game_object)
    local o = {items = {}}
    o.items = _rebuild(gameplay_world, e, game_object)

    return setmetatable(o, {__index = mt})
end

local function get_game_object(object_id)
    local vsobject = assert(vsobject_manager:get(object_id))
    return vsobject.game_object
end

function station_sys:gameworld_build()
    log.info("station_sys:gameworld_build")
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "station:in chest:in building:in eid:in" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local station_shelf = assert(global.buildings[object.id]).station_shelf
        if station_shelf then
            station_shelf:remove()
        end

        local o = create(gameplay_world, e, get_game_object(object.id))
        assert(o.remove)
        global.buildings[object.id].station_shelf = o
    end
end

function station_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "station:in chest:in building:in eid:in" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local station_shelf = assert(global.buildings[object.id]).station_shelf
        station_shelf:update(gameplay_world, e)
    end
end