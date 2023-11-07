local ecs, mailbox = ...
local world = ecs.world

local save_mb = mailbox:sub {"save"}
local restore_mb = mailbox:sub {"restore"}
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
local rhwi = import_package "ant.hwi"
local irender = ecs.require "ant.render|render_system.render"
local igroup = ecs.require "group"
local reboot_world = ecs.require "reboot_world"

---------------
local M = {}
function M.create()
    local archival_files = {}
    for _, v in ipairs(archiving.list()) do
        archival_files[#archival_files+1] = v:match("([^/]+)$")
    end

    local whichratio = "scene_ratio" -- "ratio"
    local scene_ratio = irender.get_framebuffer_ratio(whichratio)

    return {
        archival_files = archival_files,
        info = gameplay_core.settings_get("info", true),
        debug = gameplay_core.settings_get("debug", true),
        lock_group = igroup.is_lock(),
        scene_ratio = scene_ratio,
    }
end

function M.update(datamodel)
    for _ in save_mb:unpack() do
        if saveload:backup() then
            iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
        end
    end

    for _, _, _, index in restore_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
        local list = archiving.list()
        reboot_world("load_game", assert(list[index]))
    end

    for _ in close_mb:unpack() do
        if saveload.running then
            iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
        end
    end

    for _ in info_mb:unpack() do
        local info = not gameplay_core.settings_get("info", true)
        gameplay_core.settings_set("info", info)
        icanvas.show("icon", info)
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
        reboot_world("new_game", "template.loading-scene")
    end

    for _ in lock_group_mb:unpack() do
        igroup.lock(not igroup.is_lock())
        iui.close("/pkg/vaststars.resources/ui/option_pop.rml")
    end

    for _ in change_ratio_mb:unpack() do
        local whichratio = "scene_ratio"    -- "ratio"
        datamodel.scene_ratio = irender.get_framebuffer_ratio(whichratio) - 0.1
        if datamodel.scene_ratio <= 0.01 then
            datamodel.scene_ratio = 1
        end
        irender.set_framebuffer_ratio(whichratio, datamodel.scene_ratio)
        gameplay_core.settings_set("ratio", datamodel.scene_ratio)
    end
end

return M