local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 30
local bgfx = require 'bgfx'
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local fps = ecs.require "fps"
local world_update = ecs.require "world_update.init"
local gameplay_update = require "gameplay.update.init"
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
local lorry_update = ecs.require "lorry"
local iefk = ecs.require "engine.efk"
local iroadnet = ecs.require "roadnet"
local task = ecs.require "task"
local ltask = require "ltask"
local ltask_now = ltask.now
local irender_layer = ecs.require "engine.render_layer"
local RENDER_LAYERS = {
    {
        "WIRE",
    }
}

local function _gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end
local task_update; do
    local last_update_time
    function task_update()
        local current = _gettime()
        last_update_time = last_update_time or current
        if current - last_update_time < 300 then
            return
        end
        last_update_time = current
        task.update_progress("lorry_count")
    end
end

local m = ecs.system 'init_system'
function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    irender_layer.init(RENDER_LAYERS)

    iefk.preload "/pkg/vaststars.resources/effect/efk/"

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

local tick = 0
function m:update_world()
    camera.update()
    iroadnet.world_update()
    iroadnet.render_update()

    local gameplay_world = gameplay_core.get_world()
    local roadnet = gameplay_world.roadnet
    if gameplay_core.world_update then
        roadnet:update()
        gameplay_core.update()
        world_update(gameplay_world, get_object)
        gameplay_update(gameplay_world)
        task_update()

        tick = tick + 1
        if tick > 3 then -- TODO: remove this
            local is_cross, mc, x, y, z
            for lorry_id, rc, tick in roadnet:each_lorry() do
                is_cross = (rc & 0x8000 ~= 0) -- see also: push_road_coord() in c code
                mc = roadnet:map_coord(rc)
                x = (mc >>  0) & 0xFF
                y = (mc >>  8) & 0xFF
                z = (mc >> 16) & 0xFF
                lorry_update(lorry_id, is_cross, x, y, z, tick)
            end
        end
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