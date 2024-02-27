local ecs, mailbox = ...
local world = ecs.world

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"
local CONSTANT <const> = require "gameplay.interface.constant"
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING

local math3d = require "math3d"
local XZ_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})

local icoord = require "coord"
local COORD_BOUNDARY <const> = icoord.boundary()

local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS

local select_mb = mailbox:sub {"select"}
local teardown_mb = mailbox:sub {"teardown"}
local move_mb = mailbox:sub {"move"}
local close_mb = mailbox:sub {"close"}
local move_confirm_mb = mailbox:sub {"move_confirm"}
local icamera_controller = ecs.require "engine.system.camera_controller"
local icoord = require "coord"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local ibuilding = ecs.require "render_updates.building"
local iprototype = require "gameplay.interface.prototype"
local iroadnet_converter = require "roadnet_converter"
local iroadnet = ecs.require "engine.roadnet"
local teardown = ecs.require "editor.teardown"
local gameplay_core = require "gameplay.core"
local iinventory = require "gameplay.interface.inventory"
local show_message = ecs.require "show_message".show_message
local iui = ecs.require "engine.system.ui_system"
local isrt = require "utility.srt"
local igame_object = ecs.require "engine.game_object"
local igameplay = ecs.require "gameplay.gameplay_system"
local iobject = ecs.require "object"

local selected = {}
local moving_objs = {}
local moving = false
local exclude_coords = {}

local M = {}
function M.create()
    return {
        teardown = true,
        move = true,
        move_confirm = false,
    }
end

local function _update_object_state(gameplay_eid, state, color, emissive_color, render_layer)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local object = objects:coord(e.building.x, e.building.y)
    if object then
        local vsobject = assert(vsobject_manager:get(object.id))
        vsobject:update {state = state, color = color, emissive_color = emissive_color, render_layer = render_layer}
    end
end

local function _update_road_state(gameplay_eid, color)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local v = ibuilding.get(e.building.x, e.building.y)
    if v then
        local typeobject = iprototype.queryByName(v.prototype)
        local shape = iroadnet_converter.to_shape(typeobject.name)
        iroadnet:set("road", v.x, v.y, color, shape, v.direction)
    end
end

local function _to_road_color(color)
    if color == "null" then
        return 0xffffffff
    end
    local r, g, b, a = math3d.index(color, 1, 2, 3, 4)
    r, g, b, a = math.floor(r*255), math.floor(g*255), math.floor(b*255), math.floor(a*255)
    return r | g<<8 | b<<16 | a<<24
end

local function _update_selected_coords(gameplay_eids, state, color, render_layer)
    for _, gameplay_eid in ipairs(gameplay_eids) do
        _update_object_state(gameplay_eid, state, color, color, render_layer)
        _update_road_state(gameplay_eid, _to_road_color(color))
    end
end

local function _get_info(eid)
    local e = assert(gameplay_core.get_entity(eid))
    local typeobject = iprototype.queryById(e.building.prototype)
    return typeobject.area, e.building.direction
end

local function _clear_selected()
    local t = {}
    for gameplay_eid in pairs(selected) do
        t[#t+1] = gameplay_eid
    end
    _update_selected_coords(t, "opaque", "null", RENDER_LAYER.BUILDING)
    iroadnet:flush()

    selected = {}
    iui.redirect("/pkg/vaststars.resources/ui/construct.html", "bulk_opt_exit")
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

local function _clear_moving_objs()
    for _, v in pairs(moving_objs) do
        v.obj:remove()
    end
    moving_objs = {}
    moving = false
end

local function _move_building(object, x, y)
    object.x, object.y = x, y

    local e = gameplay_core.get_entity(object.gameplay_eid)
    e.building_changed = true
    igameplay.move(object.gameplay_eid, x, y)
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)
end

local function _update_building_cache(object, x, y)
    iobject.coord(object, x, y)
    objects:coord_update(object)
end

function M.update(datamodel)
    for _, _, _, left, top, width, height in select_mb:unpack() do
        local lefttop = icamera_controller.screen_to_world(left, top, XZ_PLANE)
        local rightbottom = icamera_controller.screen_to_world(left + width, top + height, XZ_PLANE)

        local ltcoord = icoord.position2coord(lefttop) or {0, 0}
        local rbcoord = icoord.position2coord(rightbottom) or {COORD_BOUNDARY[2][1], COORD_BOUNDARY[2][2]}
        local aabb_select = math3d.aabb(math3d.vector(ltcoord[1], 0, ltcoord[2]), math3d.vector(rbcoord[1], 0, rbcoord[2]))

        local new = {}
        for x = ltcoord[1], rbcoord[1] do
            for y = ltcoord[2], rbcoord[2] do
                local object = objects:coord(x, y)
                if object then
                    local e = assert(gameplay_core.get_entity(object.gameplay_eid))
                    local typeobject = iprototype.queryById(e.building.prototype)
                    local w, h = iprototype.rotate_area(typeobject.area, object.dir)
                    local inside = math3d.aabb_test_point(aabb_select, math3d.vector(e.building.x, 0, e.building.y)) >= 0 and
                            math3d.aabb_test_point(aabb_select, math3d.vector(e.building.x + w, 0, e.building.y + h)) >= 0
                    if inside and not e.debris and typeobject.teardown ~= false and typeobject.bulk_opt ~= false then
                        new[e.eid] = true
                    end
                end
                local road_x, road_y = icoord.road_coord(x, y)
                local v = ibuilding.get(road_x, road_y)
                if v then
                    local typeobject = iprototype.queryByName(v.prototype)
                    local w, h = iprototype.rotate_area(typeobject.area, v.direction)
                    local inside = math3d.aabb_test_point(aabb_select, math3d.vector(road_x, 0, road_y)) >= 0 and
                            math3d.aabb_test_point(aabb_select, math3d.vector(road_x + w, 0, road_y + h)) >= 0
                    if inside then
                        new[v.eid] = true
                    end
                end
            end
        end

        local old = selected
        local add, del = {}, {}

        for gameplay_eid in pairs(old) do
            if new[gameplay_eid] == nil then
                del[#del+1] = gameplay_eid
            end
        end

        for gameplay_eid in pairs(new) do
            if old[gameplay_eid] == nil then
                add[#add+1] = gameplay_eid
            end
        end

        _update_selected_coords(add, "translucent", SPRITE_COLOR.SELECTED, RENDER_LAYER.TRANSLUCENT_BUILDING)
        _update_selected_coords(del, "opaque", "null", RENDER_LAYER.BUILDING)

        selected = new
        iroadnet:flush()
    end

    for _ in teardown_mb:unpack() do
        local full = false
        for gameplay_eid in pairs(selected) do
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

        selected = {}
    end

    for _ in move_mb:unpack() do
        datamodel.teardown = false
        datamodel.move = false
        datamodel.move_confirm = true

        local t = {}
        for gameplay_eid in pairs(selected) do
            t[#t+1] = gameplay_eid
        end
        _update_selected_coords(t, "translucent", SPRITE_COLOR.MOVE_SELF, RENDER_LAYER.TRANSLUCENT_BUILDING)
        iroadnet:flush()

        moving = true

        for gameplay_eid in pairs(selected) do
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

        _clear_selected()

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
                icoord.assert_road_coord(v.x, v.y)
                ibuilding.remove(x, y)
                ibuilding.set {
                    x = v.x,
                    y = v.y,
                    prototype_name = r.prototype,
                    direction = r.direction,
                    road = true,
                }
            end
        end

        for _, object in pairs(objs) do
            _update_building_cache(object, object.x, object.y)
        end

        _clear_moving_objs()

        exclude_coords = {}
        datamodel.teardown = true
        datamodel.move = true
        datamodel.move_confirm = false
    end

    for _ in close_mb:unpack() do
        _clear_selected()
        _clear_moving_objs()
    end
end

function M.gesture_pinch()
    if not moving then
        iui.send("/pkg/vaststars.resources/ui/bulk_opt.html", "select")
    end
end

function M.gesture_pan_changed(datamodel, delta_vec)
    if moving then
        for _, v in pairs(moving_objs) do
            v.srt.t = math3d.add(v.srt.t, delta_vec)
            v.obj:send("obj_motion", "set_position", math3d.live(v.srt.t))
        end
    else
        iui.send("/pkg/vaststars.resources/ui/bulk_opt.html", "select")
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

function M.gesture_pan_ended(datamodel)
    if not moving then
        return
    end

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