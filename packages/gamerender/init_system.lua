local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 30
local bgfx = require 'bgfx'
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.gamerender|iui"
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
local NOTHING = require("debugger").nothing
local DISABLE_LOADING = require("debugger").disable_loading
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local pickup_mb = world:sub {"pickup"}
local icanvas = ecs.require "engine.canvas"
local icamera = ecs.require "engine.camera"
local math3d = require "math3d"
local camera = ecs.require "engine.camera"
local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}

local m = ecs.system 'init_system'
function m:init_world()
    -- check_prototype()
    bgfx.maxfps(FRAMES_PER_SECOND)

    iRmlUi.set_prefix "/pkg/vaststars.resources/ui/"
    iRmlUi.add_bundle "/pkg/vaststars.resources/ui/ui.bundle"
    iRmlUi.font_dir "/pkg/vaststars.resources/ui/font/"

    if not DISABLE_LOADING then
        iui.open("loading.rml")
        return
    end

    camera.init("camera_default.prefab")
    ecs.create_instance "/pkg/vaststars.resources/light.prefab"
    if NOTHING then
        saveload:restore_camera_setting()
        return
    end
    terrain:create()
    if TERRAIN_ONLY then
        saveload:restore_camera_setting()
        return
    end

    local info = true
    local storage = gameplay_core.get_storage()
    if storage.info ~= nil then
        info = storage.info
    end
    icanvas.create(icanvas.types().RECIPE, info)

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
        if not terrain.init then
            goto continue
        end
        local coord = terrain:align(camera.get_central_position(), terrain.ground_width, terrain.ground_height)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end
        ::continue::
    end

    -- for debug
    for _, _, x, y in pickup_mb:unpack() do
        if terrain.init then
            local pos = icamera.screen_to_world(x, y, {PLANES[1]})
            local coord = terrain:get_coord_by_position(pos[1])
            if coord then
                log.info(("pickup coord: (%s, %s) ground(%s, %s)"):format(coord[1], coord[2], coord[1] - (coord[1] % terrain.ground_width), coord[2] - (coord[2] % terrain.ground_height)))
            end
        end
    end
end