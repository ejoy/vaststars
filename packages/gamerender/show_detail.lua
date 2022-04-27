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
local general = require "gameplay.utility.general"
local has_type = general.has_type

local function get_vmin(w, h, ratio)
    local w = w / ratio
    local h = h / ratio
    return math.min(w, h)
end

local function show_detail(vsobject_id)
    local object = assert(objects:get(cache_names, vsobject_id))

    local e = gameplay_core.get_entity("entity:in fluidbox?in fluidboxes?in assembling?in", object.x, object.y)
    if not e then
        return
    end

    local typeobject = gameplay.queryByName("entity", object.prototype_name)

    -- 显示建筑详细信息
    local t = {}
    t.name = object.prototype_name
    t.icon = typeobject.icon

    if e.fluidbox and e.fluidbox.fluid ~= 0 then
        local pt = gameplay.query(e.fluidbox.fluid)
        t.fluid_name = pt.name

        local r = gameplay_core.fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
        if r then
            t.fluid_volume = r.volume / r.multiple
            t.fluid_capacity = r.capacity / r.multiple
            t.fluid_flow = r.flow / r.multiple
        end
    end

    if e.fluidboxes then
        local fluidboxes_type_str = {
            ["out"] = "output",
            ["in"] = "input",
        }

        local function set_property(t, key, value)
            if value == 0 then
                return t
            end
            t[key] = value
            return t
        end

        for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
            local fluid = e.fluidboxes[classify.."_fluid"]
            local id = e.fluidboxes[classify.."_id"]
            if fluid ~= 0 and id ~= 0 then
                local f = gameplay_core.fluidflow_query(fluid, id)
                if f then
                    set_property(t, "fluidboxes_" .. classify .. "_volume", f.volume / f.multiple)
                    set_property(t, "fluidboxes_" .. classify .. "_capacity", f.capacity / f.multiple)
                    set_property(t, "fluidboxes_" .. classify .. "_flow", f.flow / f.multiple)

                    local fluidboxes_type, fluidboxes_index = classify:match("(%l*)(%d*)")
                    local cfg = typeobject.fluidboxes[fluidboxes_type_str[fluidboxes_type]][tonumber(fluidboxes_index)]

                    set_property(t, "fluidboxes_" .. classify .. "_base_level", cfg.base_level)
                    set_property(t, "fluidboxes_" .. classify .. "_height", cfg.height)
                end
            end
        end
    end

    -- 显示环型菜单
    local vsobject = assert(vsobject_manager:get(vsobject_id))

    local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
    local ce = world:entity(mq.camera_ref)
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect

    local p = math3d.tovalue(mu.world_to_screen(vp, vr, vsobject:get_position()))
    iui.open("detail_panel.rml", t)

    -- 组装机才显示设置配方菜单
    local show_set_recipe = false
    local recipe_name = ""
    if has_type(typeobject.type, "assembling") then
        assert(e.assembling)
        show_set_recipe = true

        if e.assembling.recipe ~= 0 then
            local typeobject = gameplay.query(e.assembling.recipe)
            if typeobject.ingredients ~= "" then -- 配方没有原料也不需要显示[设置配方]
                recipe_name = typeobject.name
            end
        end
    end

    local vmin = get_vmin(vr.w, vr.h, vr.ratio)
    iui.open("build_function_pop.rml", show_set_recipe, recipe_name, vsobject_id, p[1] / vmin * 100, p[2] / vmin * 100)
    return true
end
return show_detail