local ecs = ...
local world = ecs.world
local w = world.w

local transfer_effect
local iefk = ecs.import.interface "ant.efk|iefk"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local objects = require "objects"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local global = require "global"

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
            ready_effect = ientity_object.create(iefk.create("/pkg/vaststars.resources/effect/efk/teleport-ready.efk", {
                auto_play = false,
                loop = false,
                speed = 1.0,
                scene = {s = 6, t = {0, 10, 0}}
            }), efk_events),
        }
    end
end

local function subscribe(object_id)
    init()
    local obj = assert(objects:get(object_id))
    transfer_effect.ready_effect:send("play", obj.srt.t)

    local building = global.buildings[object_id]
    assert(building.item_transfer_effect == nil)
    building.item_transfer_effect = {
        on_position_change = function(self, building_srt)
            transfer_effect.ready_effect:send("play", building_srt.t)
        end,
        remove = function()
            transfer_effect.ready_effect:send("stop")
        end,
    }
end

local function unsubscribe(object_id)
    init()
    local obj = assert(objects:get(object_id))
    transfer_effect.ready_effect:send("stop")
end

local function place_from(object_id)
    init()
    local obj = assert(objects:get(object_id))
    transfer_effect.out_effect:send("play", obj.srt.t)

    local building = global.buildings[object_id]
    building.item_transfer_effect = nil
end

local function place_to(object_id)
    init()
    local obj = assert(objects:get(object_id))
    transfer_effect.in_effect:send("play", obj.srt.t)

end

return {
    subscribe = subscribe,
    unsubscribe = unsubscribe,
    place_from = place_from,
    place_to = place_to,
}