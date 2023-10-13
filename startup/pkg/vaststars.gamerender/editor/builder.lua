local ecs = ...
local world = ecs.world

local CONSTANT <const> = require("gameplay.interface.constant")
local DEFAULT_DIR <const> = CONSTANT.DEFAULT_DIR
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local ieditor = ecs.require "editor.editor"
local imining = require "gameplay.interface.mining"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local igameplay = ecs.require "gameplay_system"
local gameplay_core = require "gameplay.core"
local ibuilding = ecs.require "render_updates.building"

local function check_construct_detector(self, prototype_name, x, y, dir, exclude_object_id)
    dir = dir or DEFAULT_DIR
    local typeobject = iprototype.queryByName(prototype_name)
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    if typeobject.construct_detector[1] == "exclusive" then
        local found_mineral
        for i = 0, w - 1 do
            for j = 0, h - 1 do
                local object = objects:coord(x + i, y + j, EDITOR_CACHE_NAMES)
                if object and object.id ~= exclude_object_id then
                    return false
                end

                if ibuilding.get(x + i, y + j) then
                    return false
                end

                if not found_mineral then
                    found_mineral = terrain:get_mineral(x + i, y + j)
                end
            end
        end

        if not iprototype.has_type(typeobject.type, "mining") then
            return (found_mineral == nil)
        end

        if not found_mineral then
            return false
        else
            local succ, mineral = terrain:can_place_on_mineral(x, y, w, h)
            if not succ then
                return false
            end
            return imining.get_mineral_recipe(prototype_name, mineral)
        end
    end

    return true
end

local function clean(self, datamodel)
    if self.pickup_object then
        iobject.remove(self.pickup_object)
    end

    ieditor:revert_changes({"TEMPORARY"})
end

local function complete(self, object_id)
    assert(object_id)
    local object = objects:get(object_id, {"CONFIRM"})
    local old = objects:get(object_id, {"CONSTRUCTED"})
    if not old then
        object.gameplay_eid = igameplay.create_entity(object)
    else
        if old.prototype_name ~= object.prototype_name then
            igameplay.destroy_entity(object.gameplay_eid)
            object.gameplay_eid = igameplay.create_entity(object)
        elseif old.dir ~= object.dir then
            igameplay.rotate(object.gameplay_eid, object.dir)
        end
    end

    objects:remove(object_id, "CONFIRM")
    objects:set(object, "CONSTRUCTED")
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

    -- TODO: duplicate code
    local gw = gameplay_core.get_world()
    local typeobject = iprototype.queryByName(object.prototype_name)
    if typeobject.power_network_link or typeobject.power_supply_distance then
        -- update power network
        ipower:build_power_network(gw)
        ipower_line.update_line(ipower:get_pole_lines())
    else
        local v = gameplay_core.get_entity(object.gameplay_eid)
        if v.capacitance then
            local capacitance = {}
            local e = v.building
            local typeobject = iprototype.queryById(e.prototype)
            local aw, ah = iprototype.rotate_area(typeobject.area, e.direction)
            capacitance[#capacitance + 1] = {
                targets = {},
                power_network_link_target = 0,
                eid = v.eid,
                x = e.x,
                y = e.y,
                w = aw,
                h = ah,
            }
            ipower:set_network_id(gw, capacitance)
        end
    end
end

local function create()
    local M = {}
    M.check_construct_detector = check_construct_detector
    M.revert_changes = ieditor.revert_changes
    M.clean = clean
    M.complete = complete

    return M
end
return create
