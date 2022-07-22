local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 60
local bgfx = require 'bgfx'
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local camera = ecs.require "engine.camera"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local check_prototype = require "gameplay.check"
local fps = ecs.require "fps"
local world_update = ecs.require "world_update.init"
local saveload = ecs.require "saveload"
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"
local iguide = require "gameplay.interface.guide"
local TERRAIN_ONLY = require("debugger").terrain_only
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}

local m = ecs.system 'init_system'
function m:init_world()
    check_prototype()
    bgfx.maxfps(FRAMES_PER_SECOND)

    camera.init("camera_default.prefab")
    ecs.create_instance "/pkg/vaststars.resources/light_directional.prefab"
    ecs.create_instance "/pkg/vaststars.resources/skybox.prefab"
    terrain:create()
    if TERRAIN_ONLY then
        saveload:restore_camera_setting()
        return
    end

    iRmlUi.preload_dir "/pkg/vaststars.resources/ui"
    iRmlUi.font_dir "/pkg/vaststars.resources/ui/font/"
    iui.preload_datamodel_dir "/pkg/vaststars.gamerender/ui_datamodel"

    if not saveload:restore() then
        return
    end
    iguide.world = gameplay_core.get_world()
    iui.set_guide_progress(iguide.get_progress())
end

local function get_object(x, y) -- TODO: optimize
    local object = objects:coord(x, y)
    if object then
        return vsobject_manager:get(object.id)
    end
end

function m:update_world()
    camera.update()
    gameplay_core.update()
    if gameplay_core.world_update then
        world_update(gameplay_core.get_world(), get_object)
    end
    fps()
end

function m:camera_usage()
    for _ in dragdrop_camera_mb:unpack() do
        local coord = terrain:align(camera.get_central_position(), terrain.ground_width, terrain.ground_height)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end
    end
end