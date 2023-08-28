local ecs = ...
local world = ecs.world

local NOTHING <const> = require "debugger".nothing
local TERRAIN_ONLY <const> = require "debugger".terrain_only
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local camera_zoom_mb = world:sub {"camera_zoom"}
local icamera_controller = ecs.require "engine.system.camera_controller"
local imain_menu_manager = ecs.require "main_menu_manager"
local icanvas = ecs.require "engine.canvas"
local audio = import_package "ant.audio"
local rhwi = import_package "ant.hwi"
local gameplay_core = require "gameplay.core"
local iguide = require "gameplay.interface.guide"
local iui = ecs.require "engine.system.ui_system"
local terrain = ecs.require "terrain"
local iroadnet = ecs.require "roadnet"
local saveload = ecs.require "saveload"
local global = require "global"
local iefk = ecs.require "engine.efk"

local m = ecs.system 'game_init_system'

function m:init_world()
    ecs.create_instance "/pkg/vaststars.resources/daynight.prefab"
    ecs.create_instance "/pkg/vaststars.resources/light.prefab"

    iefk.preload "/pkg/vaststars.resources/effects/"

    if NOTHING then
        imain_menu_manager.init("camera_default.prefab")
        return
    end

    if TERRAIN_ONLY then
        imain_menu_manager.init("camera_default.prefab")
        return
    end

    rhwi.set_profie(gameplay_core.settings_get("debug", true))

    icanvas.create(icanvas.types().ICON, gameplay_core.settings_get("info", true), 10)
    icanvas.create(icanvas.types().BUILDING_BASE, true, 0.01)
    icanvas.create(icanvas.types().PICKUP_ICON, false, 10)
    icanvas.create(icanvas.types().ROAD_ENTRANCE_MARKER, false, 0.02)

    -- audio test (Master.strings.bank must be first)
    audio.load {
        "/pkg/vaststars.resources/sounds/Master.strings.bank",
        "/pkg/vaststars.resources/sounds/Master.bank",
        "/pkg/vaststars.resources/sounds/Building.bank",
        "/pkg/vaststars.resources/sounds/Function.bank",
        "/pkg/vaststars.resources/sounds/UI.bank",
    }

    -- audio.play("event:/openui1")
    audio.play("event:/background")

    terrain:create()
    iroadnet:create()

    local args = global.startup_args
    if args[1] == "new_game" then
        icamera_controller.set_camera_from_prefab("camera_default.prefab")
        local mode, game_template = args[2], args[3]
        saveload:restart(mode, game_template)
        iguide.world = gameplay_core.get_world()
        iui.set_guide_progress(iguide.get_progress())
    elseif args[1] == "continue_game" then
        local index = args[2]
        saveload:restore(index)
        iguide.world = gameplay_core.get_world()
        iui.set_guide_progress(iguide.get_progress())
    elseif args[1] == "load_game" then
        local index = args[2]
        saveload:restore(index)
        iguide.world = gameplay_core.get_world()
        iui.set_guide_progress(iguide.get_progress())
    else
        assert(false)
    end
    global.startup_args = {}
end

function m:gameworld_end()
    local gameplay_ecs = gameplay_core.get_world().ecs
    gameplay_ecs:clear "building_new"
    gameplay_ecs:clear "building_changed"
    gameplay_ecs:clear "base_changed"
    gameplay_ecs:clear "lorry_changed"
    gameplay_ecs:clear "drone_changed"
end

function m:camera_usage()
    local camera_changed = false
    for _ in dragdrop_camera_mb:unpack() do
        camera_changed = true
    end
    for _ in camera_zoom_mb:unpack() do
        camera_changed = true
    end
    if camera_changed and terrain.init then
        local coord = terrain:align(icamera_controller.get_central_position(), 1, 1)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end
    end
end

function m:frame_update()
    if NOTHING then
        return
    end

    if gameplay_core.system_changed_flags ~= 0 then
        print("build world")
        gameplay_core.system_changed_flags = 0
        world:pipeline_func "gameworld_prebuild" ()
        gameplay_core.update()
        world:pipeline_func "gameworld_build" ()
        -- world:pipeline_func "gameworld" () -- TODO: 
    else
        if gameplay_core.world_update then
            gameplay_core.update()
            world:pipeline_func "gameworld" ()
        end
    end
end