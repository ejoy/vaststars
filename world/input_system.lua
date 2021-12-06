local ecs = ...
local world = ecs.world
local w = world.w

local rhwi  = import_package "ant.hwi"
local math3d = require "math3d"
local mathutils = ecs.require "lualib.mathutils"
local mc = import_package "ant.math".constant
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local mouse_mb = world:sub {"mouse"}
local last_mouse
local last_vx, last_vy

local input_sys = ecs.system 'input_system'
local camera_ref

function input_sys:init_world()
	for e in w:select "main_queue camera_ref:in" do
        camera_ref = e.camera_ref
    end
end

function input_sys:data_changed()
    for _, what, state, x, y in mouse_mb:unpack() do
        local vx, vy = x, y
        if vx and vy then
            if state == "DOWN" then
                last_vx, last_vy = vx, vy
                last_mouse = what
                world:pub {"mousedown", what, vx, vy}
            elseif state == "MOVE" and last_mouse == what then
                local dpiX, dpiY = rhwi.dpi()
                local dx, dy = (vx - last_vx) / dpiX, (vy - last_vy) / dpiY
                if what == "LEFT" or what == "RIGHT" or what == "MIDDLE" then
                    world:pub {"mousedrag", what, vx, vy, dx, dy}
                else
                    local i = 0
                end
                last_vx, last_vy = vx, vy
            elseif state == "UP" then
                world:pub {"mouseup", what, vx, vy}
            end
        end
    end
end

local iinput = ecs.interface "iinput"

function iinput.screen_to_world(screen_pos)
    return mathutils.ray_hit_plane(iom.ray(camera_ref, screen_pos), {dir = mc.YAXIS, pos = mc.ZERO_PT})
end

function iinput.get_mouse_world_position()
    return math3d.tovalue(iinput.screen_to_world({last_vx, last_vy}))
end