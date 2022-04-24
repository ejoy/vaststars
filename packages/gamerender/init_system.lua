local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 60
local bgfx = require 'bgfx'
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local camera = ecs.require "engine.camera"
local terrain = ecs.require "terrain"
local get_fluid_category = ecs.require "gameplay.utility.get_fluid_category"
local get_construct_menu = ecs.require "gameplay.utility.get_construct_menu"
local gameplay_core = ecs.require "gameplay.core"
local check_prototype = require "gameplay.check"
local construct_editor = ecs.require "construct_editor"
local fps = ecs.require "fps"
local fluid_icon = ecs.require "fluid_icon"

local m = ecs.system 'init_system'
function m:init_world()
    check_prototype()
    bgfx.maxfps(FRAMES_PER_SECOND)
    iRmlUi.preload_dir "/pkg/vaststars.resources/ui"

    iui.open("construct.rml", get_fluid_category(), get_construct_menu())
    camera.init("camera_default.prefab")

    ecs.create_instance "/pkg/vaststars.resources/light_directional.prefab"
    ecs.create_instance "/pkg/vaststars.resources/skybox.prefab"
    terrain.create()
    fluid_icon.create()

    world:pub {"ui", "saveload", "restore"}
end

local function get_object(x, y)
    return construct_editor:get_vsobject(x, y)
end

function m:update_world()
    camera.update()
    gameplay_core.update(get_object)
    fps()
end
