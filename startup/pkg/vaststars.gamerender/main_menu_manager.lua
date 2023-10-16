local ecs = ...
local world = ecs.world
local w = world.w

local archiving = require "archiving"
local window = import_package "ant.window"
local global = require "global"

local function rebot()
    window.reboot {
        feature = {
            "vaststars.gamerender|gameplay",
        }
    }
end

local function new_game(game_template)
    global.startup_args = {"new_game", game_template}
    rebot()
end

local function continue_game()
    global.startup_args = {"continue_game", assert(archiving.last())}
    rebot()
end

local function load_game(index)
    if not archiving.check(index) then
        log.error("invalid index: %s", index)
        return
    end
    global.startup_args = {"load_game", index}
    rebot()
    return true
end

return {
    rebot = rebot,
    load_game = load_game,
    new_game = new_game,
    continue_game = continue_game,
}