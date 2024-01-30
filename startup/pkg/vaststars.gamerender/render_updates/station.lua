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
local ivs = ecs.require "ant.render|visible_state"
local vsobject_manager = ecs.require "vsobject_manager"

local item_events = {}
item_events["show"] = function (self, show)
    for _, eid in ipairs(self.tag["*"]) do
        local e <close> = world:entity(eid, "visible_state?in")
        if e.visible_state then
            ivs.set_state(e, "main_view", show)
        end
    end
end

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
            local inst = world:create_instance {
                group = igroup.id(e.building.x, e.building.y),
                prefab = prefab,
                on_message = function (self, event, ...)
                    assert(item_events[event], "invalid message")
                    item_events[event](self, ...)
                end,
                on_ready = function (self)
                    if show then
                        item_events["show"](self, false)
                    end
                end
            }
            game_object:send("attach", assert(STATION_SLOTS[idx]), inst)
            items[idx] = {inst = inst, show = show}
        end
    end
    return items
end

local meta = {}
function meta:remove()
    for idx = 1, #self.items do
        local v = assert(self.items[idx])
        world:remove_instance(v.inst)
    end
    self.items = {}
end
function meta:on_position_change(building_srt, dir, gameplay_world, e, game_object)
    self:remove()
    self.items = _rebuild(gameplay_world, e, game_object)
end
function meta:update(gameplay_world, e)
    for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.chest, idx)
        if not slot then
            break
        end
        assert(slot.item ~= 0)

        local v = assert(self.items[idx])
        local show = slot.amount <= 0
        if v.show ~= show then
            world:instance_message(v.inst, "show", v.show)
            v.show = show
        end
    end
end

local function create(gameplay_world, e, game_object)
    local o = {items = {}}
    o.items = _rebuild(gameplay_world, e, game_object)

    return setmetatable(o, {__index = meta})
end

local function get_game_object(object_id)
    local vsobject = assert(vsobject_manager:get(object_id))
    return vsobject.game_object
end

function station_sys:gameworld_build()
    log.info("station_sys:gameworld_build")
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "station:in chest:in building:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local station_shelf = assert(global.buildings[object.id]).station_shelf
        if station_shelf then
            station_shelf:remove()
        end

        local o = create(gameplay_world, e, get_game_object(object.id))
        assert(o.remove)
        global.buildings[object.id].station_shelf = o
        ::continue::
    end
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
        station_shelf:update(gameplay_world, e)
        ::continue::
    end
end