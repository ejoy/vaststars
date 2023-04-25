local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local EDITOR_CACHE_NAMES = {"TEMPORARY", "CONFIRM", "CONSTRUCTED"}
local ieditor = ecs.require "editor.editor"
local ifluid = require "gameplay.interface.fluid"
local gameplay_core = require "gameplay.core"
local ientity = require "gameplay.interface.entity"
local imining = require "gameplay.interface.mining"
local iobject = ecs.require "object"
local terrain = ecs.require "terrain"
local ipower = ecs.require "power"
local ipower_line = ecs.require "power_line"
local DEFAULT_DIR <const> = require("gameplay.interface.constant").DEFAULT_DIR
local igameplay = ecs.import.interface "vaststars.gamerender|igameplay"
local global = require "global"

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

                if global.roadnet[iprototype.packcoord(x + i, y + j)] then
                    return false
                end
            end
        end
        local mineral = terrain:get_mineral(x, y) -- TODO: maybe have multiple minerals in the area
        if mineral then
            found_mineral = mineral
        end

        if iprototype.has_type(typeobject.type, "mining") then -- TODO: special case for mining
            if not found_mineral then
                return false
            end

            if not imining.get_mineral_recipe(prototype_name, found_mineral) then
                return false
            end
        else
            if found_mineral then -- can not construct in the area with mineral
                return false
            end
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

    -- TODO: special case for assembling machine
    -- The default recipe for the assembler is empty.
    local recipe
    local typeobject = iprototype.queryByName(object.prototype_name)
    if iprototype.has_type(typeobject.type, "assembling") then
        recipe = ""
    end

    local old = objects:get(object_id, {"CONSTRUCTED"})
    if not old then
        object.gameplay_eid = igameplay.create_entity(object)
        object.recipe = recipe
    else
        if old.prototype_name ~= object.prototype_name then
            igameplay.remove_entity(object.gameplay_eid)
            object.gameplay_eid = igameplay.create_entity(object)
        elseif old.dir ~= object.dir then
            ientity:set_direction(gameplay_core.get_world(), gameplay_core.get_entity(object.gameplay_eid), object.dir)
        elseif old.fluid_name ~= object.fluid_name then
            if iprototype.has_type(iprototype.queryByName(object.prototype_name).type, "fluidbox") then -- TODO: object may be fluidboxes
                ifluid:update_fluidbox(gameplay_core.get_entity(object.gameplay_eid), object.fluid_name)
                igameplay.update_chimney_recipe(object)
            end
        end
    end

    objects:remove(object_id, "CONFIRM")
    objects:set(object, "CONSTRUCTED")
    gameplay_core.build()

    -- TODO: duplicate code
    local gw = gameplay_core.get_world()
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
            local aw, ah = iprototype.unpackarea(typeobject.area)
            capacitance[#capacitance + 1] = {
                targets = {},
                power_network_link_target = 0,
                eid = v.eid,
                x = e.x,
                y = e.y,
                w = aw,
                h = ah,
            }
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
