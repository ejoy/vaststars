local ecs = ...
local world = ecs.world
local w = world.w

local archiving = require "archiving"
local window = import_package "ant.window"
local global = require "global"

local function rebot(system)
    window.reboot {
        import = {
            "@ant.render",
            "@vaststars.gamerender"
        },
        feature = {
            "vaststars.gamerender|engine",
        },
        system = {
            system,
        },
        policy = {
            "ant.render|render",
            "ant.render|render_queue",
        }
    }
end

local function new_game(mode, game_template)
    global.startup_args = {"new_game", mode, game_template}
    rebot("vaststars.gamerender|game_init_system")
end

local function continue_game()
    global.startup_args = {"continue_game", assert(archiving.last())}
    rebot("vaststars.gamerender|game_init_system")
end

local function load_game(index)
    if not archiving.check(index) then
        log.error("invalid index: %s", index)
        return
    end
    global.startup_args = {"load_game", index}
    rebot("vaststars.gamerender|game_init_system")
    return true
end

return {
    rebot = rebot,
    load_game = load_game,
    new_game = new_game,
    continue_game = continue_game,
}