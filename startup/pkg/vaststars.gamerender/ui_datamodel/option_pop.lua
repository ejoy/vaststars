local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local save_mb = mailbox:sub {"save"}
local restore_mb = mailbox:sub {"restore"}
local restart_mb = mailbox:sub {"restart"}
local close_mb = mailbox:sub {"close"}
local info_mb = mailbox:sub {"info"}
local back_to_main_menu_mb = mailbox:sub {"back_to_main_menu"}

local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local icanvas = ecs.require "engine.canvas"
local new_game = ecs.require "main_menu_manager".new_game
local imain_menu_manager = ecs.require "main_menu_manager"
local ia = ecs.import.interface "ant.audio|audio_interface"
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
    for _ in save_mb:unpack() do
        ia.play("event:/ui/button1")
        if saveload:backup() then
            world:pub {"rmlui_message_close", "option_pop.rml"}
        end
    end

    for _, _, _, index in restore_mb:unpack() do
        ia.play("event:/ui/button1")
        if imain_menu_manager.load_game(index) then
            world:pub {"rmlui_message_close", "option_pop.rml"}
        end
    end

    for _ in restart_mb:unpack() do
        ia.play("event:/ui/button1")
        new_game()
    end

    for _ in close_mb:unpack() do
        ia.play("event:/ui/button1")
        if saveload.running then
            world:pub {"rmlui_message_close", "option_pop.rml"}
        end
    end

    for _ in info_mb:unpack() do
        ia.play("event:/ui/button1")
        local storage = gameplay_core.get_storage()
        if storage.info == nil then
            storage.info = true
        end
        storage.info = not storage.info
        icanvas.show(icanvas.types().ICON, storage.info)
    end

    for _ in back_to_main_menu_mb:unpack() do
        ia.play("event:/ui/button1")
        world:pub {"rmlui_message_close", "option_pop.rml"}
        imain_menu_manager.back_to_main_menu()
    end
end

return M