local ecs = ...
local world = ecs.world
local w = world.w

local mathpkg = import_package "ant.math"
local gameplay_update = import_package "vaststars.gameplay".update
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.ui|iui"
local iconstruct = ecs.import.interface "vaststars.gamerender|iconstruct"
local FRAMES_PER_SECOND <const> = import_package "vaststars.constant".FRAMES_PER_SECOND
local math3d = require "math3d"
local mc = mathpkg.constant
local bgfx = require 'bgfx'

local m = ecs.system 'init_system'

function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    iRmlUi.preload_dir "/pkg/vaststars.resources/ui"

    iui.open("construct.rml")

    local mq = w:singleton("main_queue", "camera_ref:in")
    local eyepos = math3d.vector(0, 8, -8)
    local camera_ref = mq.camera_ref
    iom.set_position(camera_ref, eyepos)
    local dir = math3d.normalize(math3d.sub(mc.ZERO_PT, eyepos))
    iom.set_direction(camera_ref, dir)

    ecs.create_instance "/pkg/vaststars.resources/light_directional.prefab"
    ecs.create_instance "/pkg/vaststars.resources/skybox.prefab"
    iconstruct.init()
end

function m:data_changed()
    gameplay_update()
end