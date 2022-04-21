local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = ecs.require "gameplay.core"
local global = require "global"
local objects = global.objects
local cache_names = global.cache_names
local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local mu = import_package "ant.math".util
local vsobject_manager = ecs.require "vsobject_manager"
local math3d = require "math3d"

local function get_vmin(w, h, ratio)
    local w = w / ratio
    local h = h / ratio
    return math.min(w, h)
end

local function show_detail(vsobject_id)
    local object = assert(objects:get(cache_names, vsobject_id))

    local e = gameplay_core.get_entity("entity:in fluidbox?in", object.x, object.y)
    if not e then
        return
    end

    local t = {}
    t.name = object.prototype_name

    if e.fluidbox and e.fluidbox.fluid ~= 0 then
        local pt = gameplay.query(e.fluidbox.fluid)
        t.fluid_name = pt.name

        local r = gameplay_core.fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
        if r then
            t.fluid_volume = r.volume / r.multiple
        end
    end

    local vsobject = assert(vsobject_manager:get(vsobject_id))

    local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
    local ce = world:entity(mq.camera_ref)
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect

    local p = math3d.tovalue(mu.world_to_screen(vp, vr, vsobject:get_position()))
    iui.open("detail_panel.rml", t)

    local vmin = get_vmin(vr.w, vr.h, vr.ratio)
    iui.open("build_function_pop.rml", vsobject_id, p[1] / vmin * 100, p[2] / vmin * 100)
    return true
end
return show_detail