local ecs, mailbox = ...
local world = ecs.world

local load_template_mb = mailbox:sub {"load_template"}
local new_game = ecs.require "main_menu_manager".new_game
local fs = require "filesystem"
local debugger <const> = require "debugger"
local iui = ecs.require "engine.system.ui_system"

---------------
local M = {}
function M.create()
    local templates = {}
    for v in fs.pairs(fs.path("/pkg/vaststars.prototype/template/")) do
        if fs.is_directory(v) then
            assert(false)
        else
            assert(tostring(v:extension()) == ".lua")
            local filename = "template." .. v:stem():string()
            local f = import_package("vaststars.prototype")(filename)
            templates[#templates + 1] = {order = f.order or 0, name = f.name or "undef", filename = filename}
        end
    end
    table.sort(templates, function(a, b) return a.order < b.order end)

    return {
        templates = templates
    }
end

function M.update(datamodel)
    for _, _, _, filename in load_template_mb:unpack() do
        debugger.set_free_mode(true)
        iui.close("/pkg/vaststars.resources/ui/template.rml")
        new_game("free", filename)
    end
end

return M