local ecs, mailbox = ...
local world = ecs.world

local iui = ecs.require "engine.system.ui_system"

local start_mode_mb = mailbox:sub {"start_mode"}
local load_resources_mb = mailbox:sub {"load_resources"}
local load_archive_mb = mailbox:sub {"load_archive"}
local continue_mb = mailbox:sub {"continue"}
local load_template_mb = mailbox:sub {"load_template"}
local new_game = ecs.require "main_menu_manager".new_game
local continue_game = ecs.require "main_menu_manager".continue_game
local debugger <const> = require "debugger"
local archiving = require "archiving"

---------------
local M = {}
function M.create()
    return {
        show_continue_game = (archiving.last() ~= nil)
    }
end

function M.update(datamodel)
    for _ in continue_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/login.rml")
        continue_game()
    end

    for _, _, _, mode in start_mode_mb:unpack() do
        debugger.set_free_mode(mode == "free")
        iui.close("/pkg/vaststars.resources/ui/login.rml")
        new_game(mode)
    end

    for _ in load_resources_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/loading.rml"})
    end

    for _ in load_archive_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/login.rml")
        iui.open({rml = "/pkg/vaststars.resources/ui/option_pop.rml"})
    end

    for _ in load_template_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/login.rml")
        iui.open({rml = "/pkg/vaststars.resources/ui/template.rml"})
    end
end

return M