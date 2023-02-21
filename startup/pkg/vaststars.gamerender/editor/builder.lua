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

local function check_construct_detector(self, prototype_name, x, y, dir)
    dir = dir or DEFAULT_DIR
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    if typeobject.construct_detector[1] == "exclusive" then
        local found_mineral
        for i = 0, w - 1 do
            for j = 0, h - 1 do
                if objects:coord(x + i, y + j, EDITOR_CACHE_NAMES) then
                    return false
                end

                if global.roadnet[iprototype.packcoord(x + i, y + j)] then
                    return false
                end

                local mineral = terrain:get_mineral(x + i, y + j) -- TODO: maybe have multiple minerals in the area
                if mineral then
                    found_mineral = mineral
                end
            end
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

local function check_unconfirmed(self, double_confirm)
    if not objects:empty("CONFIRM") then
        if not double_confirm then
            return true
        end
    end
    return false
end

-- TODO: refactor
-- local function _has_connection(object)
--     for _, fb in ipairs(ifluid:get_fluidbox(object.prototype_name, object.x, object.y, object.dir)) do
--         local succ, dx, dy = terrain:move_coord(fb.x, fb.y, fb.dir, 1)
--         if not succ then
--             goto continue
--         end

--         local o = objects:coord(dx, dy, EDITOR_CACHE_NAMES)
--         if not o then
--             goto continue
--         end

--         local typeobject = iprototype.queryByName("entity", o.prototype_name)
--         if iprototype.has_type(typeobject.type, "assembling") then
--             return true
--         end
--         ::continue::
--     end
-- end

local function complete(self, object_id)
    assert(object_id)
    local object = objects:get(object_id, {"CONFIRM"})
    object.state = "constructed"
    object.object_state = "constructed"

    -- TODO: special case for assembling machine
    -- The default recipe for the assembler is empty.
    local recipe
    local typeobject = iprototype.queryByName("entity", object.prototype_name)
    if iprototype.has_type(typeobject.type, "assembling") then
        recipe = ""
    end

    local fluid_icon -- TODO: duplicate code, see also saveload.lua
    if iprototype.has_type(typeobject.type, "fluidbox") and object.fluid_name ~= "" then
        if iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
            if ((object.x % 2 == 1 and object.y % 2 == 1) or (object.x % 2 == 0 and object.y % 2 == 0)) and not _has_connection(object) then
                fluid_icon = true
            end
        else
            fluid_icon = true
        end
    end

    local old = objects:get(object_id, {"CONSTRUCTED"})
    if not old then
        object.gameplay_eid = igameplay.create_entity(object)
        object.recipe = recipe
        object.fluid_icon = fluid_icon
    else
        if old.prototype_name ~= object.prototype_name then
            igameplay.remove_entity(object.gameplay_eid)
            object.gameplay_eid = igameplay.create_entity(object)
        elseif old.dir ~= object.dir then
            ientity:set_direction(gameplay_core.get_world(), gameplay_core.get_entity(object.gameplay_eid), object.dir)
        elseif old.fluid_name ~= object.fluid_name then
            if iprototype.has_type(iprototype.queryByName("entity", object.prototype_name).type, "fluidbox") then -- TODO: object may be fluidboxes
                object.fluid_icon = fluid_icon
                ifluid:update_fluidbox(gameplay_core.get_entity(object.gameplay_eid), object.fluid_name)
                igameplay.update_chimney_recipe(object)
            end
        end
    end

    objects:remove(object_id, "CONFIRM")
    objects:set(object, "CONSTRUCTED")
    gameplay_core.build()

    local gw = gameplay_core.get_world()
    if typeobject.power_pole then
        -- update power network
        ipower:build_power_network(gw)
        ipower_line.update_line(ipower:get_pole_lines())
    else
        local capacitance = {}
        for v in gameplay_core.select("eid:in entity:in capacitance:in") do
            if v.capacitance then
                local e = v.entity
                local typeobject = iprototype.queryById(e.prototype)
                local aw, ah = iprototype.unpackarea(typeobject.area)
                capacitance[#capacitance + 1] = {
                    targets = {},
                    eid = v.eid,
                    x = e.x,
                    y = e.y,
                    w = aw,
                    h = ah,
                }
            end
        end
        ipower:set_network_id(gw, capacitance)
    end
end

local function create()
    local M = {}
    M.check_construct_detector = check_construct_detector
    M.revert_changes = ieditor.revert_changes
    M.clean = clean
    M.check_unconfirmed = check_unconfirmed
    M.complete = complete

    return M
end
return create
