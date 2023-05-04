local ecs = ...
local world = ecs.world
local w = world.w

local transfer_effect
local iefk = ecs.import.interface "ant.efk|iefk"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local objects = require "objects"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local global = require "global"
local math3d = require "math3d"
local COLOR_NULL = math3d.constant "null"
local selected_boxes = ecs.require "selected_boxes"
local iprototype = require "gameplay.interface.prototype"

local efk_events = {}
efk_events["play"] = function(o, e, pos)
    local e <close> = w:entity(o.id)
    iom.set_position(e, {pos[1], pos[2] + 15, pos[3]})
    iefk.play(o.id)
end
efk_events["stop"] = function(o, e)
    iefk.stop(o.id)
end

local function init()
    if not transfer_effect then
        transfer_effect = {
            out_effect = ientity_object.create(iefk.create("/pkg/vaststars.resources/effect/efk/teleport-in.efk", {
                auto_play = false,
                loop = false,
                speed = 1.0,
                scene = {s = 5, t = {0, 10, 0}}
            }), efk_events),
            in_effect = ientity_object.create(iefk.create("/pkg/vaststars.resources/effect/efk/teleport-out.efk", {
                auto_play = false,
                loop = false,
                speed = 1.0,
                scene = {s = 5, t = {0, 10, 0}}
            }), efk_events),
        }
    end
end

local subscribe_id, unsubscribe
local function subscribe(object_id)
    init()

    if subscribe_id then
        unsubscribe(subscribe_id)
    end

    local building = global.buildings[object_id]
    assert(building.item_transfer_effect == nil)

    local obj = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(obj.prototype_name)
    local w, h = iprototype.unpackarea(typeobject.area)
    local item_transfer_effect = selected_boxes({"/pkg/vaststars.resources/prefabs/item-transfer-source.prefab"}, obj.srt.t, COLOR_NULL, w, h)

    building.item_transfer_effect = {
        on_position_change = function(self, building_srt)
            item_transfer_effect:set_position(building_srt.t)
        end,
        remove = function()
            item_transfer_effect:remove()
        end,
    }

    subscribe_id = object_id
end

function unsubscribe(object_id)
    local building = global.buildings[object_id]
    building.item_transfer_effect:remove()
    building.item_transfer_effect = nil
    subscribe_id = nil
end

local function place_from(object_id)
    local obj = assert(objects:get(object_id))
    transfer_effect.out_effect:send("play", obj.srt.t)
end

local function place_to(object_id)
    local obj = assert(objects:get(object_id))
    transfer_effect.in_effect:send("play", obj.srt.t)
end

return {
    subscribe = subscribe,
    unsubscribe = unsubscribe,
    place_from = place_from,
    place_to = place_to,
}