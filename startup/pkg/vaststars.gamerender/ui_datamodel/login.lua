local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"

local start_mode_mb = mailbox:sub {"start_mode"}
local load_mb = mailbox:sub {"load"}
local load_game = ecs.require "load_game"
local debugger <const> = require "debugger"

---------------
local M = {}
function M:create()
    return {}
end

function M:stage_camera_usage(datamodel)
    for _, _, _, mode in start_mode_mb:unpack() do
        debugger.set_free_mode(mode == "free")
        world:pub {"rmlui_message_close", "login.rml"}
        load_game()
    end

    for _ in load_mb:unpack() do
        world:pub {"rmlui_message_close", "login.rml"}
        iui.open({"option_pop.rml"})
    end
end

return M