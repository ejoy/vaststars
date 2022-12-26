local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local mu = import_package "ant.math".util
local math3d = require "math3d"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local idetail = ecs.interface "idetail"
local EDITOR_CACHE_NAMES <const> = {"SELECTED", "CONSTRUCTED"}
local iterrain = ecs.require "terrain"

local iobject = ecs.require "object"

function idetail.show(object_id)
    iui.open("detail_panel.rml", object_id)

    -- 显示环型菜单
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName("entity", object.prototype_name)

    idetail.selected(object)

    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    local p = mu.world_to_screen(vp, vr, object.srt.t) -- the position always in the center of the screen after move camera
    local ui_x, ui_y = iui.convert_coord(vr, math3d.index(p, 1), math3d.index(p, 2))

    if typeobject.show_build_function ~= false then
        iui.open("build_function_pop.rml", object_id, ui_x, ui_y, object.srt.t[1], object.srt.t[3])
    elseif iprototype.is_pipe(object.prototype_name) or iprototype.is_pipe_to_ground(object.prototype_name) then
        iui.open("pipe_function_pop.rml", object_id, ui_x, ui_y, object.srt.t[1], object.srt.t[3])
    elseif iprototype.is_road(object.prototype_name) then
        iui.open("road_function_pop.rml", object_id, ui_x, ui_y, object.srt.t[1], object.srt.t[3])
    end

    do
        log.info(object.id, object.prototype_name, object.x, object.y, object.dir, object.fluid_name, object.fluidflow_id)
    end
    return true
end

function idetail.show_road(x, y)
    local pos = iterrain:get_position_by_coord(x, y, 1, 1)

    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    local p = mu.world_to_screen(vp, vr, pos) -- the position always in the center of the screen after move camera
    local ui_x, ui_y = iui.convert_coord(vr, math3d.index(p, 1), math3d.index(p, 2))

    iui.open("build_road_function_pop.rml", ui_x, ui_y, x, y)
    return true
end

function idetail.unselected()
    for _, object in objects:all("SELECTED") do
        object.state = "constructed"
    end
    objects:clear({"SELECTED"})
end

function idetail.selected(object)
    idetail.unselected()

    object = objects:modify(object.x, object.y, EDITOR_CACHE_NAMES, iobject.clone)
    local typeobject = iprototype.queryByName("entity", object.prototype_name) -- TODO: special case for powerpole
    if typeobject.supply_area then
        object.state = ("power_pole_selected_%s"):format(typeobject.supply_area)
    else
        object.state = "selected"
    end
end