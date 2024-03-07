local ecs, mailbox = ...
local world = ecs.world

local BUTTONS <const> = {
    { command = "remove",       icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/remove.texture", },
    { command = "move",         icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/move.texture", },
    { command = "move_confirm", icon = "/pkg/vaststars.resources/ui/textures/bulk-opt/move-confirm.texture", },
}
local CONSTANT <const> = require "gameplay.interface.constant"
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local ROTATORS <const> = CONSTANT.ROTATORS
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"

local set_button_offset = ecs.require "ui_datamodel.common.sector_menu".set_button_offset
local remove_mb = mailbox:sub {"remove"}
local move_mb = mailbox:sub {"move"}
local move_confirm_mb = mailbox:sub {"move_confirm"}
local focus_mb = mailbox:sub {"focus"}
local global = require "global"
local teardown = ecs.require "editor.teardown"
local gameplay_core = require "gameplay.core"
local iinventory = require "gameplay.interface.inventory"
local show_message = ecs.require "show_message".show_message
local iui = ecs.require "engine.system.ui_system"
local update_buildings_state = ecs.require "ui_datamodel.common.bulk_opt".update_buildings_state
local iroadnet = ecs.require "engine.roadnet"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local icoord = require "coord"
local isrt = require "utility.srt"
local igame_object = ecs.require "engine.game_object"
local ibuilding = ecs.require "render_updates.building"
local math3d = require "math3d"
local icamera_controller = ecs.require "engine.system.camera_controller"
local igameplay = ecs.require "gameplay.gameplay_system"
local iobject = ecs.require "object"

local moving_objs = {}
local exclude_coords = {}

local function _handler(datamodel)
    local t = {}
    for _, v in ipairs(BUTTONS) do
        if datamodel[v.command] then
            t[#t+1] = {
                command = v.command,
                background_image = v.icon,
            }
        end
    end
    set_button_offset(t)
    return t
end

local function _clear_moving_objs()
    for _, v in pairs(moving_objs) do
        v.obj:remove()
    end
    moving_objs = {}
end

local function _get_check_coord(typeobject)
    local funcs = {}
    for _, v in ipairs(typeobject.check_coord) do
        funcs[#funcs+1] = ecs.require(("editor.rules.check_coord.%s"):format(v))
    end
    return function(...)
        for _, v in ipairs(funcs) do
            local succ, reason = v(...)
            if not succ then
                return succ, reason
            end
        end
        return true
    end
end

local function _move_building(object, x, y)
    igameplay.move(object.gameplay_eid, x, y)

    object.x, object.y = x, y

    local e = gameplay_core.get_entity(object.gameplay_eid)
    e.building_changed = true
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)
end

local function _update_building_cache(object, x, y)
    iobject.coord(object, x, y)
    objects:coord_update(object)
end

local function _close()
    _clear_moving_objs()

    update_buildings_state(global.selected_buildings, "opaque", "null", RENDER_LAYER.BUILDING)
    iroadnet:flush()

    iui.redirect("/pkg/vaststars.resources/ui/construct.html", "bulk_opt_exit")
    gameplay_core.world_update = true
    igame_object.restart_world()
end

local function _focus(func)
    local aabb = math3d.aabb()
    for gameplay_eid in pairs(global.selected_buildings) do
        local e = assert(gameplay_core.get_entity(gameplay_eid))
        local x, y = e.building.x, e.building.y
        local object = objects:coord(x, y)
        if object then
            local typeobject = iprototype.queryByName(object.prototype_name)
            local w, h = iprototype.rotate_area(typeobject.area, object.dir)
            local aabb_ = math3d.aabb(math3d.vector(x, 0, y), math3d.vector(x+w, 0, y+h))
            aabb = math3d.aabb_merge(aabb, aabb_)
        end
        local v = ibuilding.get(x, y)
        if v then
            local typeobject = iprototype.queryByName(v.prototype)
            local w, h = iprototype.rotate_area(typeobject.area, v.direction)
            local aabb_ = math3d.aabb(math3d.vector(x, 0, y), math3d.vector(x+w, 0, y+h))
            aabb = math3d.aabb_merge(aabb, aabb_)
        end
    end

    local lt = math3d.array_index(aabb, 1)
    local rb = math3d.array_index(aabb, 2)
    local l, t = math3d.index(lt, 1, 3)
    local r, b = math3d.index(rb, 1, 3)
    icamera_controller.focus_on_position("CENTER", math3d.vector(icoord.position(l, t, r - l, b - t)), func)
end

local M = {}
function M.create()
    gameplay_core.world_update = false
    igame_object.stop_world()

    local t = {
        remove = true,
        move = true,
        move_confirm = false,
    }
    t.buttons = _handler(t)
    return t
end

function M.update(datamodel)
    for _ in remove_mb:unpack() do
        local full = false
        for gameplay_eid in pairs(global.selected_buildings) do
            teardown(gameplay_eid)
            local e = assert(gameplay_core.get_entity(gameplay_eid))
            if not iinventory.place(gameplay_core.get_world(), e.building.prototype, 1) then
                full = true
            end
        end

        gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

        -- the building directly go into the backpack
        if full then
            show_message("backpack is full")
        end

        global.selected_buildings = {}
    end

    for _ in move_mb:unpack() do
        datamodel.move = false
        datamodel.move_confirm = true
        datamodel.buttons = _handler(datamodel)

        update_buildings_state(global.selected_buildings, "translucent", SPRITE_COLOR.MOVE_SELF, RENDER_LAYER.TRANSLUCENT_BUILDING)
        iroadnet:flush()

        _focus(function()
            for gameplay_eid in pairs(global.selected_buildings) do
                local e = assert(gameplay_core.get_entity(gameplay_eid))
                local x, y = e.building.x, e.building.y
                local object = objects:coord(x, y)
                if object then
                    local typeobject = iprototype.queryByName(object.prototype_name)
                    local w, h = iprototype.rotate_area(typeobject.area, object.dir)
                    for i = 0, w-1 do
                        for j = 0, h-1 do
                            exclude_coords[icoord.pack(x+i, y+j)] = true
                        end
                    end

                    local srt = isrt.new(object.srt)
                    moving_objs[object.gameplay_eid] = {
                        obj = igame_object.create {
                            prefab = typeobject.model,
                            group_id = 0,
                            srt = srt,
                        },
                        srt = srt,
                        x = x,
                        y = y,
                    }
                end
                local v = ibuilding.get(x, y)
                if v then
                    local typeobject = iprototype.queryByName(v.prototype)
                    local w, h = iprototype.rotate_area(typeobject.area, v.direction)
                    for i = 0, w-1 do
                        for j = 0, h-1 do
                            exclude_coords[icoord.pack(x+i, y+j)] = true
                        end
                    end

                    local srt = isrt.new {r = ROTATORS[v.direction], t = icoord.position(x, y, w, h)}
                    moving_objs[v.eid] = {
                        obj = igame_object.create {
                            prefab = typeobject.model,
                            group_id = 0,
                            srt = srt,
                        },
                        srt = srt,
                        x = x,
                        y = y,
                    }
                end
            end
        end)
    end

    for _ in move_confirm_mb:unpack() do
        for gameplay_eid, v in pairs(moving_objs) do
            local e = assert(gameplay_core.get_entity(gameplay_eid))
            local x, y = e.building.x, e.building.y
            local object = objects:coord(x, y)
            if object then
                local typeobject = iprototype.queryByName(object.prototype_name)
                local succ, msg = _get_check_coord(typeobject)(v.x, v.y, object.dir, typeobject, exclude_coords)
                if not succ then
                    show_message(msg)
                    return
                end
            end
            local r = ibuilding.get(x, y)
            if r then
                local typeobject = iprototype.queryByName(r.prototype)
                local succ, msg = _get_check_coord(typeobject)(v.x, v.y, r.direction, typeobject, exclude_coords)
                if not succ then
                    show_message(msg)
                    return
                end
            end
        end

        local objs = {}
        for gameplay_eid, v in pairs(moving_objs) do
            local e = assert(gameplay_core.get_entity(gameplay_eid))
            local x, y = e.building.x, e.building.y
            local object = objects:coord(x, y)
            if object then
                _move_building(object, v.x, v.y)
                objs[object.id] = object
            end
            local r = ibuilding.get(x, y)
            if r then
                igameplay.move(r.eid, v.x, v.y)
            end
        end

        for _, object in pairs(objs) do
            _update_building_cache(object, object.x, object.y)
        end

        exclude_coords = {}
        datamodel.teardown = true
        datamodel.move = true
        datamodel.move_confirm = false

        _close()
    end

    for _ in focus_mb:unpack() do
        _focus()
    end
end

function M.gesture_tap()
    _close()
end

function M.gesture_pan_changed(datamodel, delta_vec)
    for _, v in pairs(moving_objs) do
        v.srt.t = math3d.add(v.srt.t, delta_vec)
        v.obj:send("obj_motion", "set_position", math3d.live(v.srt.t))
    end
end

local function _get_first_moving_obj(moving_objs)
    for gameplay_eid, v in pairs(moving_objs) do
        local e = assert(gameplay_core.get_entity(gameplay_eid))
        local r = ibuilding.get(e.building.x, e.building.y)
        if r then
            return gameplay_eid, v, true
        end
    end
    return next(moving_objs)
end

local function _get_info(eid)
    local e = assert(gameplay_core.get_entity(eid))
    local typeobject = iprototype.queryById(e.building.prototype)
    return typeobject.area, e.building.direction
end

function M.gesture_pan_ended(datamodel)
    local gameplay_eid, v, road = _get_first_moving_obj(moving_objs)
    if not gameplay_eid then
        return
    end
    assert(v)

    local area, dir = _get_info(gameplay_eid)
    local c, position = icoord.align(v.srt.t, iprototype.rotate_area(area, dir))
    assert(c)
    if road then
        c[1], c[2] = icoord.road_coord(c[1], c[2])
        position = math3d.vector(icoord.position(c[1], c[2], iprototype.rotate_area(area, dir)))
    end
    icamera_controller.move_delta(math3d.sub(position, v.srt.t))
    local dx, dy = c[1] - v.x, c[2] - v.y

    local positions = {}
    for gameplay_eid, v in pairs(moving_objs) do
        v.x = v.x + dx
        v.y = v.y + dy
        local area, dir = _get_info(gameplay_eid)
        local position = icoord.position(v.x, v.y, iprototype.rotate_area(area, dir))
        if not position then
            return
        end
        positions[gameplay_eid] = position
    end

    for gameplay_eid, position in pairs(positions) do
        local v = assert(moving_objs[gameplay_eid])
        v.srt.t = position
        v.obj:send("obj_motion", "set_position", math3d.live(v.srt.t))
    end
end

return M