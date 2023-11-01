local ecs = ...
local world = ecs.world
local w = world.w

local debugger = ecs.require "debugger"
local NOTHING <const> = debugger.nothing
local TERRAIN_ONLY <const> = debugger.terrain_only
local DISABLE_AUDIO <const> = debugger.disable_audio

local icamera_controller = ecs.require "engine.system.camera_controller"
local icanvas = ecs.require "engine.canvas"
local audio = import_package "ant.audio"
local rhwi = import_package "ant.hwi"
local gameplay_core = require "gameplay.core"
local iguide = require "gameplay.interface.guide"
local iui = ecs.require "engine.system.ui_system"
local iroadnet = ecs.require "roadnet"
local saveload = ecs.require "saveload"
local global = require "global"
local math3d = require "math3d"
local irender = ecs.require "ant.render|render_system.render"
local imountain = ecs.require "engine.mountain"
local iterrain  = ecs.require "terrain"
local igroup = ecs.require "group"
local ibackpack = require "gameplay.interface.backpack"

local m = ecs.system 'game_init_system'
local gameworld_prebuild
local gameworld_build
local gameworld

function m:init_world()
    gameworld_prebuild = world:pipeline_func "gameworld_prebuild"
    gameworld_build = world:pipeline_func "gameworld_build"
    gameworld = world:pipeline_func "gameworld"

    world:create_instance {
        prefab = "/pkg/vaststars.resources/daynight.prefab"
    }
    world:create_instance {
        prefab = "/pkg/vaststars.resources/light.prefab"
    }
    world:create_instance {
        prefab = "/pkg/vaststars.resources/sky.prefab"
    }

    if NOTHING then
        icamera_controller.set_camera_from_prefab("camera_default.prefab")
        return
    end

    iterrain.create()
    iroadnet:create()

    if TERRAIN_ONLY then
        icamera_controller.set_camera_from_prefab("camera_default.prefab")
        return
    end

    rhwi.set_profie(gameplay_core.settings_get("debug", true))

    irender.set_framebuffer_ratio("scene_ratio", gameplay_core.settings_get("ratio", 1))

    icanvas.create("icon", gameplay_core.settings_get("info", true), 10)
    icanvas.create("pickup_icon", false, 10)
    icanvas.create("road_entrance_marker", false, 0.02)

    -- audio test (Master.strings.bank must be first)
    audio.load {
        "/pkg/vaststars.resources/sounds/Master.strings.bank",
        "/pkg/vaststars.resources/sounds/Master.bank",
        "/pkg/vaststars.resources/sounds/Building.bank",
        "/pkg/vaststars.resources/sounds/Function.bank",
        "/pkg/vaststars.resources/sounds/UI.bank",
    }

    if not DISABLE_AUDIO then
        audio.play("event:/background")
    end

    local args = global.startup_args
    if args[1] == "new_game" then
        icamera_controller.set_camera_from_prefab("camera_default.prefab")
        local game_template_file = args[2]
        local game_template = ecs.require(("vaststars.prototype|%s"):format(game_template_file))
        local mode = game_template.mode
        imountain:create(game_template.mountain)
        debugger.set_free_mode(mode == "free")
        saveload:restart(mode, game_template_file)
        iguide.init(gameplay_core.get_world(), game_template.guide)
        iui.set_guide_progress(iguide.get_progress())
    elseif args[1] == "continue_game" then
        local index = args[2]
        saveload:restore(index)
        iui.set_guide_progress(iguide.get_progress())
    elseif args[1] == "load_game" then
        local index = args[2]
        saveload:restore(index)
        iui.set_guide_progress(iguide.get_progress())
    else
        assert(false)
    end

    ibackpack.set_infinite_item(debugger.infinite_item)
    global.startup_args = {}
end

function m:gameworld_end()
    local gameplay_ecs = gameplay_core.get_world().ecs
    gameplay_ecs:clear("building_new")
end

function m:camera_usage()
    local mq = w:first "main_queue camera_ref:in"
    local ce = world:entity(mq.camera_ref, "camera_changed?in camera:in scene:in")
    if ce.camera_changed then
        local points = icamera_controller.get_interset_points(ce)
        igroup.enable(points[2], math3d.set_index(points[3], 1, math3d.index(points[4], 1)))
    end
end

function m:frame_update()
    if NOTHING then
        return
    end

    local gameplay_world = gameplay_core.get_world()
    if gameplay_core.system_changed_flags ~= 0 then
        print("build world")
        gameplay_core.system_changed_flags = 0
        gameworld_prebuild()
        gameplay_world:update()
        gameworld_build()
    else
        if gameplay_core.world_update then
            gameplay_world:update()
            gameworld()
        end
    end
end