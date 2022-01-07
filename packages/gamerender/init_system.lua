local ecs = ...
local world = ecs.world
local w = world.w

local mathpkg = import_package "ant.math"
local game = import_package "vaststars.gameplay".createWorld()
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.ui|iui"
local iconstruct = ecs.import.interface "vaststars.gamerender|iconstruct"
local icamera = ecs.import.interface "ant.camera|icamera"

local FRAMES_PER_SECOND <const> = import_package "vaststars.constant".FRAMES_PER_SECOND
local math3d = require "math3d"
local mc = mathpkg.constant
local bgfx = require 'bgfx'

local m = ecs.system 'init_system'

local function print_camera_info(e, dir)
    w:sync("scene:in", e)
    local rc = e.scene
    local srt = rc.srt
    if rc.updir then
        local _srt = math3d.inverse(math3d.lookto(srt.t, dir, rc.updir))
        local s, r, t = math3d.srt(_srt)
        srt = {s = s, r = r, t = t}
    else
        srt.r.q = math3d.torotation(dir)
    end

    print("camera scale", table.concat(math3d.tovalue(srt.s), ","))
    local t = math3d.tovalue(math3d.quat2euler(srt.r))
    for k, v in pairs(t) do
        t[k] = math.deg(v)
    end
    print("camera rotation", table.concat(t, ","))
    print("camera translation", table.concat(math3d.tovalue(srt.t), ","))

    local frustum = icamera.get_frustum(e)
    print("camera frustum")
    for k, v in pairs(frustum) do
        print(k, v)
    end
end

function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    iRmlUi.preload_dir "/pkg/vaststars.resources/ui"

    iui.open("construct.rml")

    local mq = w:singleton("main_queue", "camera_ref:in")
    local eyepos = math3d.vector(0, 60, -60)
    local camera_ref = mq.camera_ref
    iom.set_position(camera_ref, eyepos)
    local dir = math3d.normalize(math3d.sub(mc.ZERO_PT, eyepos))
    iom.set_direction(camera_ref, dir)
    print_camera_info(camera_ref, dir)

    ecs.create_instance "/pkg/vaststars.resources/light_directional.prefab"
    ecs.create_instance "/pkg/vaststars.resources/skybox.prefab"
    iconstruct.init()
end

function m:data_changed()
    game.update()
end
