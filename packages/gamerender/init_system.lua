local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 60
local bgfx = require 'bgfx'
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local fs = require "filesystem"
local default_camera_path <const> = fs.path "/pkg/vaststars.resources/camera_default.prefab"
local datalist  = require "datalist"
local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local terrain = ecs.require "terrain"
local get_fluid_category = ecs.require "get_fluid_category"

local function to_quat(t)
    for k, v in ipairs(t) do
        t[k] = math.rad(v)
    end
    return math3d.tovalue(math3d.quaternion(t))
end

local function get_camera_srt()
    local f<close> = fs.open(default_camera_path)
    if f then
        local srt = datalist.parse(f:read "a")[1].data.scene.srt
        return srt.s or mc.ONE, srt.r, srt.t
    end
    return mc.ONE, to_quat({45.0, 0, 0}), {0, 60, -60}
end

local m = ecs.system 'init_system'
function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    iRmlUi.preload_dir "/pkg/vaststars.resources/ui"

    iui.open("construct.rml", get_fluid_category())

    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref
    iom.set_srt(world:entity(camera_ref), get_camera_srt())

    ecs.create_instance "/pkg/vaststars.resources/light_directional.prefab"
    ecs.create_instance "/pkg/vaststars.resources/skybox.prefab"
    terrain.create()
    icanvas.create()

    world:pub{"camera_controller", "stop", false}
end
