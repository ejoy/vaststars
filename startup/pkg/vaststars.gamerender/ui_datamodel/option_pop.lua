local ecs, mailbox = ...
local world = ecs.world

local save_mb = mailbox:sub {"save"}
local restore_mb = mailbox:sub {"restore"}
local restart_mb = mailbox:sub {"restart"}
local close_mb = mailbox:sub {"close"}
local info_mb = mailbox:sub {"info"}
local debug_mb = mailbox:sub {"debug"}
local back_to_main_menu_mb = mailbox:sub {"back_to_main_menu"}
local change_ratio_mb = mailbox:sub {"change_ratio"}
local lock_group_mb = mailbox:sub {"lock_group"}
local iui = ecs.require "engine.system.ui_system"
local archiving = require "archiving"

local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local icanvas = ecs.require "engine.canvas"
local imain_menu_manager = ecs.require "main_menu_manager"
local rhwi = import_package "ant.hwi"
local terrain = ecs.require "terrain"
local irender = ecs.require "ant.render|render_system.render"

---------------
local M = {}
function M:create()
    local archival_files = {}
    for _, v in ipairs(archiving.list()) do
        archival_files[#archival_files+1] = v.dir
    end

    local whichratio = "scene_ratio" -- "ratio"
    local scene_ratio = irender.get_framebuffer_ratio(whichratio)

    return {
        archival_files = archival_files,
        info = gameplay_core.settings_get("info", true),
        debug = gameplay_core.settings_get("debug", true),
        lock_group = terrain.lock_group,
        scene_ratio = scene_ratio,
    }
end

function M:stage_camera_usage(datamodel)
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
        local window = import_package "ant.window"
        window.reboot {
            feature = {
                "vaststars.gamerender|login",
            }
        }
    end

    for _ in lock_group_mb:unpack() do
        terrain.lock_group = not terrain.lock_group
        iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
    end

    for _ in change_ratio_mb:unpack() do
        local whichratio = "scene_ratio"    -- "ratio"
        datamodel.scene_ratio = datamodel.scene_ratio - 0.1
        if datamodel.scene_ratio <= 0.0000001 then
            datamodel.scene_ratio = 1
        end
        irender.set_framebuffer_ratio(whichratio, datamodel.scene_ratio)
    end
end

return M