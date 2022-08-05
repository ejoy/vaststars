local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 60
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
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local ui_message_move_camera_mb = world:sub {"ui_message", "move_camera"}
local icanvas = ecs.require "engine.canvas"
local math3d = require "math3d"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local camera = ecs.require "engine.camera"
local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}

local m = ecs.system 'init_system'
function m:init_world()
    check_prototype()
    bgfx.maxfps(FRAMES_PER_SECOND)

    camera.init("camera_default.prefab")
    ecs.create_instance "/pkg/vaststars.resources/light_directional.prefab"
    ecs.create_instance "/pkg/vaststars.resources/skybox.prefab"
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
    icanvas:create(info)
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
        if not terrain.init then
            goto continue
        end
        local coord = terrain:align(camera.get_central_position(), terrain.ground_width, terrain.ground_height)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end
        ::continue::
    end

    local function _move_camera(delta)
        local mq = w:singleton("main_queue", "camera_ref:in")
        local e = world:entity(mq.camera_ref)

        local old = iom.get_position(e)
        local new = math3d.add(delta, old)

        camera.move({t = new})
    end
    local function _get_vmin(w, h, ratio)
        local w = w / ratio
        local h = h / ratio
        return math.min(w, h)
    end
    for _, _, left, top, object_id in ui_message_move_camera_mb:unpack() do
        local vsobject = assert(vsobject_manager:get(object_id))
        local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
        local vr = mq.render_target.view_rect
        local vmin = _get_vmin(vr.w, vr.h, vr.ratio)
        local pos = camera.screen_to_world(left / 100 * vmin, top / 100 * vmin, PLANES)[1]
        _move_camera(math3d.sub(vsobject:get_position(), pos))
    end
end