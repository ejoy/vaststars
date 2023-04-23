local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local TERRAIN_ONLY <const> = require "debugger".terrain_only
local NOTHING <const> = require "debugger".nothing
local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local terrain = ecs.require "terrain"
local icanvas = ecs.require "engine.canvas"
local iguide = require "gameplay.interface.guide"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local resources_loader = ecs.require "ui_datamodel.common.resources_loader"
local resources = require "resources"
local current
---------------
local M = {}

-- TDOO: duplicate with startup\pkg\vaststars.gamerender\init_system.lua
local prefab_parse = require("engine.prefab_parser").parse
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ic = ecs.import.interface "ant.camera|icamera"
local function init_camera_position(prefab_file_name)
    local data = prefab_parse("/pkg/vaststars.resources/" .. prefab_file_name)
    if not data then
        return
    end
    assert(data[1] and data[1].data and data[1].data.camera)
    local c = data[1].data

    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref, "scene:update")
    e.scene.updir = mc.NULL -- TODO: use math3d.lookto() to reset updir

    iom.set_srt(e, c.scene.s or mc.ONE, c.scene.r, c.scene.t)
    -- Note: It will be inversed when the animation exceeds 90 degrees
    -- iom.set_view(e, iom.get_position(e), iom.get_direction(e), math3d.vector(data.scene.updir)) -- don't need to set updir, it will cause nan error
    ic.set_frustum(e, c.camera.frustum)
end

function M:create(load)
    current = 0

    if load == nil then
        load = true
    end

    return {
        closed = false, -- TODO: remove this?
        load = load,
        filename = resources[current] or "",
        progress = "0%",
    }
end

local function _load_game()
    init_camera_position("camera_default.prefab")
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

    local show = true
    local storage = gameplay_core.get_storage()
    if storage.info ~= nil then
        show = storage.info
    end
    icanvas.create(icanvas.types().ICON, show)
    icanvas.create(icanvas.types().BUILDING_BASE, true, 0.01)
    icanvas.create(icanvas.types().ROAD_ENTRANCE_MARKER, false, 0.02)

    if not saveload:restore() then
        return
    end
    iguide.world = gameplay_core.get_world()
    iui.set_guide_progress(iguide.get_progress())
end

function M:stage_camera_usage(datamodel)
    if datamodel.closed == true then -- prevent call _load_game() when window is closed
        return
    end
    if current + 1 > #resources then
        if datamodel.load then
            _load_game()
        end
        world:pub {"rmlui_message_close", "loading.rml"}
        datamodel.closed = true
        return
    end

    local filename
    repeat
        current = current + 1
        filename = resources[current]
        if current + 1 > #resources then
            break
        end
    until resources_loader.load(filename)

    datamodel.filename = filename
    datamodel.progress = string.format("%d%%", math.floor(current / #resources * 100))
end

return M