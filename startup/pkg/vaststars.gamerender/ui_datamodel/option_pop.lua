local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local save_mb = mailbox:sub {"save"}
local restore_mb = mailbox:sub {"restore"}
local restart_mb = mailbox:sub {"restart"}
local close_mb = mailbox:sub {"close"}
local info_mb = mailbox:sub {"info"}

local camera = ecs.require "engine.camera"
local saveload = ecs.require "saveload"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local gameplay_core = require "gameplay.core"
local icanvas = ecs.require "engine.canvas"
---------------
local M = {}

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
        camera.init("camera_default.prefab")
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