local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local save_mb = mailbox:sub {"save"}
local restore_mb = mailbox:sub {"restore"}
local restart_mb = mailbox:sub {"restart"}
local camera = ecs.require "engine.camera"
local saveload = ecs.require "saveload"

---------------
local M = {}

function M:create()
    return {
        archival_files = saveload:get_archival_relative_dir_list(),
    }
end

function M:stage_camera_usage()
    for _ in save_mb:unpack() do -- 存档时会保存摄像机的位置
        saveload:backup()
    end

    for _, _, _, index in restore_mb:unpack() do -- 读档时会还原摄像机的位置
        saveload:restore(index)
    end

    for _ in restart_mb:unpack() do
        camera.init("camera_default.prefab")
        saveload:restart()
    end
end

return M