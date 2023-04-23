local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 30
local bgfx = require 'bgfx'
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local world_update = ecs.require "world_update.init"
local gameplay_update = require "gameplay.update.init"
local NOTHING <const> = require "debugger".nothing
local DISABLE_LOADING <const> = require "debugger".disable_loading
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local pickup_gesture_mb = world:sub {"pickup_gesture"}
local icamera_controller = ecs.import.interface "vaststars.gamerender|icamera_controller"
local math3d = require "math3d"
local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}
local lorry_manager = ecs.require "lorry_manager"
local iefk = ecs.require "engine.efk"
local iroadnet = ecs.require "roadnet"
local irender_layer = ecs.require "engine.render_layer"
local idn = ecs.import.interface "mod.daynight|idaynight"
local DayTick <const> = require("gameplay.interface.constant").DayTick
local m = ecs.system 'init_system'

iRmlUi.set_prefix "/pkg/vaststars.resources/ui/"
iRmlUi.add_bundle "/pkg/vaststars.resources/ui/ui.bundle"
iRmlUi.font_dir "/pkg/vaststars.resources/ui/font/"

local function daynight_update(gameplayWorld)
    local dne = w:first "daynight:in"
    if not dne then
        return
    end

    local cycle = (gameplayWorld:now() % DayTick) / DayTick
    idn.update_cycle(dne, cycle)
end

function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    ecs.create_instance "/pkg/vaststars.resources/daynight.prefab"

    -- "foreground", "opacity", "background", "translucent", "decal_stage", "ui_stage"
    irender_layer.init({
        {
            "foreground",
            {"TERRAIN"},
            {"MINERAL"},
            {"BUILDING_BASE"},
            {"TRANSLUCENT_PLANE"},
        },
        {
            "opacity",
            {"LORRY_SHADOW", "LORRY"},
        },
        {
            "background",
            {"ICON"},
            {"ICON_CONTENT"},
            {"WIRE"},
        },
        {
            "translucent",
            {"SELECTED_BOXES"},
        },
    })

    iefk.preload "/pkg/vaststars.resources/effect/efk/"

    iroadnet:create(not NOTHING)
    if not DISABLE_LOADING then
        iui.open({"loading.rml"})
        return
    end

    iui.open({"login.rml"})
end

function m:update_world()
    if NOTHING then
        return
    end

    local gameplay_world = gameplay_core.get_world()
    daynight_update(gameplay_world)
    iroadnet:update()

    if gameplay_core.world_update then
        gameplay_core.update()
        world_update(gameplay_world)
        gameplay_update(gameplay_world)

        local mc, x, y, z
        for lorry_id, rc, tick in gameplay_world:roadnet_each_lorry() do
            mc = gameplay_world:roadnet_map_coord(rc)
            x, y, z = mc & 0xFF, (mc >> 8) & 0xFF, (mc >> 16) & 0xFF
            lorry_manager.update(lorry_id, x, y, z, tick)
        end
    end
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

    -- for debug
    for _, _, x, y in pickup_gesture_mb:unpack() do
        if terrain.init then
            local pos = icamera_controller.screen_to_world(x, y, {PLANES[1]})
            local coord = terrain:get_coord_by_position(pos[1])
            if coord then
                log.info(("pickup coord: (%s, %s)"):format(coord[1], coord[2]))
            end
        end
    end
end