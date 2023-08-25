local ecs = ...
local world = ecs.world
local w = world.w

local icamera_controller = ecs.require "engine.system.camera_controller"
local saveload = ecs.require "saveload"
local window = import_package "ant.window"
local global = require "global"

local function init(prefab)
    icamera_controller.set_camera_from_prefab(prefab)
end

local function rebot(system)
    window.reboot {
        import = {
            "@vaststars.gamerender"
        },
        pipeline = {
            "init",
            "update",
            "exit",
        },
        system = {
            system,
        },
        policy = {
            "ant.general|name",
            "ant.scene|scene_object",
            "ant.render|render",
            "ant.render|render_queue",
            "ant.objcontroller|pickup",
        }
    }
end

local function new_game(mode, game_template)
    rebot("vaststars.gamerender|game_init_system")
    global.startup_args = {"new_game", mode, game_template}
end

local function continue_game()
    if not saveload:restore() then
        return
    end
    global.startup_args = {"continue_game"}
    rebot("vaststars.gamerender|game_init_system")
end

local function load_game(index)
    if not saveload:restore(index) then
        return
    end
    global.startup_args = {"load_game"}
    rebot("vaststars.gamerender|game_init_system")
    return true
end

return {
    init = init,
    rebot = rebot,
    load_game = load_game,
    new_game = new_game,
    continue_game = continue_game,
}