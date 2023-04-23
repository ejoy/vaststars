local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local save_mb = mailbox:sub {"save"}
local restore_mb = mailbox:sub {"restore"}
local restart_mb = mailbox:sub {"restart"}
local close_mb = mailbox:sub {"close"}
local info_mb = mailbox:sub {"info"}

local saveload = ecs.require "saveload"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local gameplay_core = require "gameplay.core"
local icanvas = ecs.require "engine.canvas"

---------------
local M = {}

-- TDOO: duplicate with startup\pkg\vaststars.gamerender\load_game.lua
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

function M:create()
    local archival_files = {}
    for _, v in ipairs(saveload:get_archival_list()) do
        archival_files[#archival_files+1] = v.dir
    end

    local info = true
    local storage = gameplay_core.get_storage()
    if storage.info ~= nil then
        info = storage.info
    end
    return {
        archival_files = archival_files,
        info = info,
    }
end

function M:stage_camera_usage()
    for _ in save_mb:unpack() do -- 存档时会保存摄像机的位置
        if saveload:backup() then
            iui.close("option_pop.rml")
        end
    end

    for _, _, _, index in restore_mb:unpack() do -- 读档时会还原摄像机的位置
        if saveload:restore(index) then
            iui.close("option_pop.rml")
        end
    end

    for _ in restart_mb:unpack() do
        init_camera_position("camera_default.prefab")
        saveload:restart()
    end

    for _ in close_mb:unpack() do
        if saveload.running then
            iui.close("option_pop.rml")
        end
    end

    for _ in info_mb:unpack() do
        local storage = gameplay_core.get_storage()
        if storage.info == nil then
            storage.info = true
        end
        storage.info = not storage.info
        icanvas.show(icanvas.types().ICON, storage.info)
    end
end

return M