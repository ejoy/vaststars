local ecs = ...
local world = ecs.world
local w = world.w

local SLOTS <const> = {"item_slot_1", "item_slot_2", "item_slot_3", "item_slot_4"}

local objects = require "objects"
local ichest = require "gameplay.interface.chest"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"
local depot_sys = ecs.system "depot_system"
local gameplay_core = require "gameplay.core"
local igroup = ecs.require "group"
local ivs = ecs.require "ant.render|visible_state"
local vsobject_manager = ecs.require "vsobject_manager"
local igame_object = ecs.require "engine.game_object"
local imessage = ecs.require "message_sub"

local mt = {}
function mt:remove()
    for idx = 1, #self.items do
        local v = assert(self.items[idx])
        v.item_object:remove()
    end
    self.items = {}
end
function mt:on_position_change()
    -- do nothing
end
function mt:update(gameplay_world, e)
    for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.chest, idx)
        if not slot then
            break
        end

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

    for idx = 1, ichest.get_max_slot(iprototype.queryById(e.building.prototype)) do
        local slot = ichest.get(gameplay_world, e.chest, idx)
        if not slot then
            break
        end

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
                        imessage:pub("show", self, show)
                    end
                end
            }

            game_object:send("hitch_instance|attach", assert(SLOTS[idx]), item_object.hitch_instance)
            o.items[idx] = {item_object = item_object, show = show}
        end
    end

    return setmetatable(o, {__index = mt})
end

local function get_game_object(object_id)
    local vsobject = assert(vsobject_manager:get(object_id))
    return vsobject.game_object
end

function depot_sys:gameworld_build()
    log.info("depot_sys:gameworld_build")
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "depot chest:in building:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local depot_items = assert(global.buildings[object.id]).depot_items
        if depot_items then
            depot_items:remove()
        end

        local o = create(gameplay_world, e, get_game_object(object.id))
        assert(o.remove)
        global.buildings[object.id].depot_items = o
        ::continue::
    end
end

function depot_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()
    for e in gameplay_world.ecs:select "depot chest:in building:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local depot_items = assert(global.buildings[object.id]).depot_items
        depot_items:update(gameplay_world, e)
        ::continue::
    end
end