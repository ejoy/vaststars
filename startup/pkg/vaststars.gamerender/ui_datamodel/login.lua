local ecs, mailbox = ...
local world = ecs.world

local iui = ecs.require "engine.system.ui_system"

local restore_mb = mailbox:sub {"restore"}

local M = {}
function M.create()
    return {}
end

function M.update(datamodel)
    for _ in restore_mb:unpack() do
        iui.open({rml = "/pkg/vaststars.resources/ui/option_pop.rml"})
    end
end

return M
