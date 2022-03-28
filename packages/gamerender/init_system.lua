local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 60
local bgfx = require 'bgfx'
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local engine = ecs.require "engine"
local terrain = ecs.require "terrain"
local get_fluid_category = ecs.require "get_fluid_category"
local gameplay = ecs.require "gameplay"

local m = ecs.system 'init_system'
function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    iRmlUi.preload_dir "/pkg/vaststars.resources/ui"

    iui.open("construct.rml", get_fluid_category())
    engine.set_camera_prefab("camera_default.prefab")

    ecs.create_instance "/pkg/vaststars.resources/light_directional.prefab"
    ecs.create_instance "/pkg/vaststars.resources/skybox.prefab"
    terrain.create()
    icanvas.create()

    world:pub{"camera_controller", "stop", false}
end

function m:update_world()
    gameplay.update()
end
