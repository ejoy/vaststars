local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local load_template_mb = mailbox:sub {"load_template"}
local new_game = ecs.require "main_menu_manager".new_game
local ia = ecs.import.interface "ant.audio|audio_interface"
local fs = require "filesystem"
local debugger <const> = require "debugger"

---------------
local M = {}
function M:create()
    local templates = {}
    for v in fs.pairs(fs.path("/pkg/vaststars.prototype/template/")) do
        if fs.is_directory(v) then
            assert(false)
        else
            assert(tostring(v:extension()) == ".lua")
            local filename = "template." .. v:stem():string()
            local name = import_package("vaststars.prototype")(filename).name or "undef"
            templates[#templates + 1] = {name = name, filename = filename}
        end
    end

    return {
        templates = templates
    }
end

function M:stage_camera_usage(datamodel)
    for _, _, _, filename in load_template_mb:unpack() do
        ia.play("event:/ui/button1")
        debugger.set_free_mode(true)
        world:pub {"rmlui_message_close", "template.rml"}
        new_game("free", filename)
    end
end

return M