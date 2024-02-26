local ecs, mailbox = ...
local world = ecs.world

local save_mb       = mailbox:sub {"save"}
local restore_mb    = mailbox:sub {"restore"}
local close_mb      = mailbox:sub {"close"}
local info_mb       = mailbox:sub {"info"}
local debug_mb      = mailbox:sub {"debug"}
local back_to_main_menu_mb = mailbox:sub {"back_to_main_menu"}
local lock_group_mb = mailbox:sub {"lock_group"}

local iui           = ecs.require "engine.system.ui_system"
local icanvas       = ecs.require "engine.canvas"
local igroup        = ecs.require "group"
local saveload      = ecs.require "saveload"

local archiving     = require "archiving"


local global = require "global"

local rhwi          = import_package "ant.hwi"
local window        = import_package "ant.window"
local setting       = import_package "vaststars.settings"

---------------
local M = {}
function M.create()
    local archival_files = {}
    for _, v in ipairs(archiving.list()) do
        archival_files[#archival_files+1] = v:match("([^/]+)$")
    end

    return {
        archival_files  = archival_files,
        info            = setting.get("info", true),
        debug           = setting.get("debug", true),
        lock_group      = igroup.is_lock(),
    }
end

function M.update(datamodel)
    for _ in save_mb:unpack() do
        if saveload:backup() then
            iui.close("/pkg/vaststars.resources/ui/option_pop.html")
        end
    end

    for _, _, _, index in restore_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/option_pop.html")
        local list = archiving.list()
        global.startup_args = {"restore", assert(list[index])}
        window.reboot {
            feature = {"vaststars.gamerender|gameplay"},
        }
    end

    for _ in close_mb:unpack() do
        if saveload.running then
            iui.close("/pkg/vaststars.resources/ui/option_pop.html")
        end
    end

    for _ in info_mb:unpack() do
        local info = not setting.get("info", true)
        setting.set("info", info)
        icanvas.show("icon", info)
        iui.close("/pkg/vaststars.resources/ui/option_pop.html")
    end

    for _ in debug_mb:unpack() do
        local debug = not setting.get("debug", false)
        setting.set("debug", debug)
        rhwi.set_profie(debug)
        iui.close("/pkg/vaststars.resources/ui/option_pop.html")
    end

    for _ in back_to_main_menu_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/option_pop.html")
        iui.close("/pkg/vaststars.resources/ui/main_menu.html")
        window.reboot {
            feature = {"vaststars.gamerender|login"},
        }
    end

    for _ in lock_group_mb:unpack() do
        igroup.lock(not igroup.is_lock())
        iui.close("/pkg/vaststars.resources/ui/option_pop.html")
    end
end

return M