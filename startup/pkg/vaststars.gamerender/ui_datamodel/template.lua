local ecs, mailbox = ...
local world = ecs.world

local start_game_mb = mailbox:sub {"start_game"}
local reboot_world = ecs.require "reboot_world"
local fs = require "filesystem"
local iui = ecs.require "engine.system.ui_system"

---------------
local M = {}
function M.create(func)
    local templates = {}
    for v in fs.pairs(fs.path("/pkg/vaststars.prototype/template/")) do
        if fs.is_directory(v) then
            assert(false)
        else
            assert(tostring(v:extension()) == ".lua")
            if not func(v:filename():string()) then
                goto continue
            end

            local filename = "template." .. v:stem():string()
            local f = ecs.require(("vaststars.prototype|%s"):format(filename))
            if f.show == false then
                goto continue
            end

            templates[#templates + 1] = {order = f.order or 0, mode = f.mode, name = f.name or "undef", filename = filename}
            ::continue::
        end
    end
    table.sort(templates, function(a, b) return a.order < b.order end)

    return {
        templates = templates
    }
end

function M.update(datamodel)
    for _, _, _, template in start_game_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/template.rml")
        reboot_world("new_game", template)
    end
end

return M