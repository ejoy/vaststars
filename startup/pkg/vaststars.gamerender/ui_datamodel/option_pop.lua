local ecs, mailbox = ...
local world = ecs.world

local save_mb = mailbox:sub {"save"}
local restore_mb = mailbox:sub {"restore"}
local restart_mb = mailbox:sub {"restart"}
local close_mb = mailbox:sub {"close"}
local info_mb = mailbox:sub {"info"}
local debug_mb = mailbox:sub {"debug"}
local back_to_main_menu_mb = mailbox:sub {"back_to_main_menu"}

local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local icanvas = ecs.require "engine.canvas"
local new_game = ecs.require "main_menu_manager".new_game
local imain_menu_manager = ecs.require "main_menu_manager"
local rhwi = import_package "ant.hwi"

---------------
local M = {}
function M:create()
    local archival_files = {}
    for _, v in ipairs(saveload:get_archival_list()) do
        archival_files[#archival_files+1] = v.dir
    end

    return {
        archival_files = archival_files,
        info = gameplay_core.settings_get("info", true),
        debug = gameplay_core.settings_get("debug", true),
    }
end

function M:stage_camera_usage()
    for _ in save_mb:unpack() do
        if saveload:backup() then
            world:pub {"rmlui_message_close", "option_pop.rml"}
        end
    end

    for _, _, _, index in restore_mb:unpack() do
        if imain_menu_manager.load_game(index) then
            world:pub {"rmlui_message_close", "option_pop.rml"}
        end
    end

    for _ in restart_mb:unpack() do
        new_game()
        world:pub {"rmlui_message_close", "option_pop.rml"}
    end

    for _ in close_mb:unpack() do
        if saveload.running then
            world:pub {"rmlui_message_close", "option_pop.rml"}
        end
    end

    for _ in info_mb:unpack() do
        local info = not gameplay_core.settings_get("info", true)
        gameplay_core.settings_set("info", info)
        icanvas.show(icanvas.types().ICON, info)
        world:pub {"rmlui_message_close", "option_pop.rml"}
    end

    for _ in debug_mb:unpack() do
        local debug = not gameplay_core.settings_get("debug", true)
        gameplay_core.settings_set("debug", debug)
        rhwi.set_profie(debug)
        world:pub {"rmlui_message_close", "option_pop.rml"}
    end

    for _ in back_to_main_menu_mb:unpack() do
        world:pub {"rmlui_message_close", "option_pop.rml"}
        world:pub {"rmlui_message_close", "main_menu.rml"}
        imain_menu_manager.back_to_main_menu()
    end
end

return M