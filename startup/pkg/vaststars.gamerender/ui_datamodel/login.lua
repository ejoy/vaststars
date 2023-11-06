local ecs, mailbox = ...
local world = ecs.world

local iui = ecs.require "engine.system.ui_system"

local start_game_mb = mailbox:sub {"start_game"}
local load_resources_mb = mailbox:sub {"load_resources"}
local load_archive_mb = mailbox:sub {"load_archive"}
local continue_mb = mailbox:sub {"continue"}
local load_template_mb = mailbox:sub {"load_template"}
local archiving = require "archiving"
local rebot_world = ecs.require "rebot_world"

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
        rebot_world("load_game", assert(archiving.last()))
    end

    for _, _, _, template in start_game_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/login.rml")
        rebot_world("new_game", template)
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