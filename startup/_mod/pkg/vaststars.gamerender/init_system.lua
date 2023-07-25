local ecs = ...
local world = ecs.world

local FRAMES_PER_SECOND <const> = 30
local bgfx = require 'bgfx'
local iRmlUi = ecs.import.interface "ant.rmlui|irmlui"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local NOTHING <const> = require "debugger".nothing
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local icamera_controller = ecs.import.interface "vaststars.gamerender|icamera_controller"
local iefk = ecs.require "engine.efk"
local imain_menu_manager = ecs.require "main_menu_manager"

local m = ecs.system 'init_system'

iRmlUi.set_prefix "/pkg/vaststars.resources/ui/"
iRmlUi.add_bundle "/pkg/vaststars.resources/ui/ui.bundle"
iRmlUi.font_dir "/pkg/vaststars.resources/ui/font/"

function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    ecs.create_instance "/pkg/vaststars.resources/daynight.prefab"
    ecs.create_instance "/pkg/vaststars.resources/light.prefab"

    iefk.preload "/pkg/vaststars.resources/effect/efk/"

    terrain:create()
    imain_menu_manager.init("camera_default.prefab")

    local p = ecs.create_instance("/pkg/vaststars.resources/prefabs/stackeditems/stack-aluminium-hydroxide.prefab")
    world:create_object(p)
end

function m:gameplay_update()
    if NOTHING then
        return
    end

    if gameplay_core.system_changed_flags ~= 0 then
        gameplay_core.system_changed_flags = 0
        gameplay_core.update()
        world:pipeline_func "gameworld_prebuild" ()
        world:pipeline_func "gameworld_build" ()
    end

    if gameplay_core.world_update then
        gameplay_core.update()
    end
end

function m:gameworld_end()
    local gameplay_world = gameplay_core.get_world()
    gameplay_world.ecs:clear "building_new"
    gameplay_world.ecs:clear "building_changed"
    gameplay_world.ecs:clear "base_changed"
end

function m:camera_usage()
    for _ in dragdrop_camera_mb:unpack() do
        if not terrain.init then
            goto continue
        end
        local coord = terrain:align(icamera_controller.get_central_position(), 1, 1)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end
        ::continue::
    end
end