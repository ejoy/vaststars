local ecs = ...
local world = ecs.world
local w = world.w

local mathpkg = import_package "ant.math"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.ui|iui"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"

local FRAMES_PER_SECOND <const> = import_package "vaststars.constant".FRAMES_PER_SECOND
local math3d = require "math3d"
local mc = mathpkg.constant
local fs = require "filesystem"
local datalist  = require "datalist"
local bgfx = require 'bgfx'

local m = ecs.system 'init_system'
local default_camera_path <const> = fs.path "/pkg/vaststars.resources/camera_default.prefab"
local camera_reset_mb = world:sub {"camera", "reset"}
local camera_lookdown_mb = world:sub {"camera", "lookdown"}

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

function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    iRmlUi.preload_dir "/pkg/vaststars.resources/ui"

    iui.open("construct.rml")

    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref
    iom.set_srt(camera_ref, get_camera_srt())

    ecs.create_instance "/pkg/vaststars.resources/light_directional.prefab"
    ecs.create_instance "/pkg/vaststars.resources/skybox.prefab"
    iterrain.create()

    world:pub{"camera_controller", "stop", false}
end

function m:data_changed()
    local mq = w:singleton("main_queue", "camera_ref:in")
    local camera_ref = mq.camera_ref

    for _ in camera_reset_mb:unpack() do
        iom.set_srt(camera_ref, get_camera_srt())
    end

    for _ in camera_lookdown_mb:unpack() do
        iom.set_srt(camera_ref, mc.ONE, to_quat({90.0, 0, 0}), {0, 60, 0})
    end
end