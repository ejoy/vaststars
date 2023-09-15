local ecs, mailbox = ...
local world = ecs.world

local save_mb = mailbox:sub {"save"}
local restore_mb = mailbox:sub {"restore"}
local restart_mb = mailbox:sub {"restart"}
local close_mb = mailbox:sub {"close"}
local info_mb = mailbox:sub {"info"}
local debug_mb = mailbox:sub {"debug"}
local back_to_main_menu_mb = mailbox:sub {"back_to_main_menu"}
local lock_group_mb = mailbox:sub {"lock_group"}
local iui = ecs.require "engine.system.ui_system"
local archiving = require "archiving"

local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local icanvas = ecs.require "engine.canvas"
local imain_menu_manager = ecs.require "main_menu_manager"
local rhwi = import_package "ant.hwi"
local terrain = ecs.require "terrain"

---------------
local M = {}
function M:create()
    local archival_files = {}
    for _, v in ipairs(archiving.list()) do
        archival_files[#archival_files+1] = v.dir
    end

    return {
        archival_files = archival_files,
        info = gameplay_core.settings_get("info", true),
        debug = gameplay_core.settings_get("debug", true),
        lock_group = terrain.lock_group,
    }
end

function M:stage_camera_usage()
    for _ in save_mb:unpack() do
        if saveload:backup() then
            iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
        end
    end

    for _, _, _, index in restore_mb:unpack() do
        if imain_menu_manager.load_game(index) then
            iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
        end
    end

    for _ in restart_mb:unpack() do
        imain_menu_manager.new_game()
        iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
    end

    for _ in close_mb:unpack() do
        if saveload.running then
            iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
        end
    end

    for _ in info_mb:unpack() do
        local info = not gameplay_core.settings_get("info", true)
        gameplay_core.settings_set("info", info)
        icanvas.show(icanvas.types().ICON, info)
        iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
    end

    for _ in debug_mb:unpack() do
        local debug = not gameplay_core.settings_get("debug", true)
        gameplay_core.settings_set("debug", debug)
        rhwi.set_profie(debug)
        iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
    end

    for _ in back_to_main_menu_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
        iui.close("/pkg/vaststars.resources/ui/main_menu.rml")
        imain_menu_manager.rebot("vaststars.gamerender|init_system")
    end

    for _ in lock_group_mb:unpack() do
        terrain.lock_group = not terrain.lock_group
        iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
    end
end

return M