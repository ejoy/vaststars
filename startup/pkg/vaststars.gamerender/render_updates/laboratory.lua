local ecs = ...
local world = ecs.world
local w = world.w

local SLOTS <const> = {
    "slot1",
    "slot2",
    "slot3",
    "slot4",
    "slot5",
    "slot6",
}

local laboratory_sys = ecs.system "laboratory_system"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local igame_object = ecs.require "engine.game_object"
local igroup = ecs.require "group"

local cache = {}

local function _get_game_object(object_id)
    local vsobject = assert(vsobject_manager:get(object_id))
    return vsobject.game_object
end

local function _create_shelf(e, game_object, idx, item, amount)
    local shelf; shelf = igame_object.create {
        prefab = "/pkg/vaststars.resources/glbs/lab-shelf.glb|mesh.prefab",
        group_id = igroup.id(e.building.x, e.building.y),
        on_ready = function(self)
            if amount > 0 then
                local typeobject = iprototype.queryById(item)
                local item_object = igame_object.create {
                    prefab = typeobject.item_model,
                    group_id = igroup.id(e.building.x, e.building.y),
                }
                shelf:send("hitch_instance|attach", "slot", item_object.hitch_instance)
            end
        end
    }
    game_object:send("hitch_instance|attach", assert(SLOTS[idx]), shelf.hitch_instance)
    return shelf
end

function laboratory_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "laboratory:in building:in chest:in eid:in" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local game_object = _get_game_object(object.id)
        local c = 0

        local t = cache[e.eid]
        if not t then
            t = {}
            cache[e.eid] = t
        end

        for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
            local slot = ichest.get(gameplay_world, e.chest, idx)
            if not slot then
                break
            end
            assert(slot.item ~= 0)
            if not t[idx] then
                t[idx] = {item = slot.item, show_item = slot.amount > 0, shelf = _create_shelf(e, game_object, idx, slot.item, slot.amount)}
            else
                if t[idx].item ~= slot.item or t[idx].show_item ~= (slot.amount > 0) then
                    t[idx].item = slot.item
                    t[idx].show_item = slot.amount > 0

                    t[idx].shelf:remove()
                    t[idx].shelf = _create_shelf(e, game_object, idx, slot.item, slot.amount)
                end
            end

            c = c + 1
        end
        if c ~= #t then
            for i = c + 1, #t do
                t[i].shelf:remove()
                t[i] = nil
            end
        end
    end
end

function laboratory_sys:gameworld_prebuild()
    local world = gameplay_core.get_world()
    for e in world.ecs:select "REMOVED eid:in" do
        cache[e.eid] = nil
    end
end

function laboratory_sys:exit()
    cache = {}
end
