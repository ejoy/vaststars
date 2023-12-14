local ecs, mailbox = ...
local world = ecs.world

local start_game_mb = mailbox:sub {"start_game"}
local window = import_package "ant.window"
local global = require "global"
local fs = require "filesystem"
local iui = ecs.require "engine.system.ui_system"

---------------
local M = {}
function M.create(func)
    local tutorials = {}
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

            tutorials[#tutorials + 1] = {
                order = f.order or 0,
                name = f.name or "undef",
                template = filename,
                desc = f.tutorial_desc or "",
                details = f.tutorial_details or {},
            }
            ::continue::
        end
    end
    table.sort(tutorials, function(a, b) return a.order < b.order end)

    return {
        name = tutorials[1] and tutorials[1].name or "",
        tutorials = tutorials,
    }
end

function M.update(datamodel)
    for _, _, _, template in start_game_mb:unpack() do
        iui.close("/pkg/vaststars.resources/ui/template.rml")
        global.startup_args = {"new_game", template}
        window.reboot {
            feature = {"vaststars.gamerender|gameplay"},
        }
    end
end

return M