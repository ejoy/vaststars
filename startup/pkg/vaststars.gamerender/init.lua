local ecs = ...
local world = ecs.world
local w = world.w

local DISABLE_AUDIO <const> = ecs.require "game_settings".disable_audio
local NOTHING <const> = ecs.require "game_settings".nothing
local TERRAIN_ONLY <const> = ecs.require "game_settings".terrain_only

local global = require "global"
local audio = import_package "ant.audio"
local start_web = ecs.require "engine.webcgi"
local ltask = require "ltask"
local window = import_package "ant.window"

return function()
    if global.init then
        return
    end
    global.init = true

    ltask.uniqueservice "vaststars.gamerender|memtexture"

    start_web()

    -- audio test (Master.strings.bank must be first)
    audio.load {
        "/pkg/vaststars.resources/sounds/Master.strings.bank",
        "/pkg/vaststars.resources/sounds/Master.bank",
        "/pkg/vaststars.resources/sounds/Building.bank",
        "/pkg/vaststars.resources/sounds/Function.bank",
        "/pkg/vaststars.resources/sounds/UI.bank",
    }
    if not DISABLE_AUDIO then
        audio.play("event:/background")
    end

    if NOTHING then
        global.startup_args = {"nothing"}
        window.reboot {
            feature = {"vaststars.gamerender|gameplay"},
        }
        return
    end

    if TERRAIN_ONLY then
        global.startup_args = {"terrain_only"}
        window.reboot {
            feature = {"vaststars.gamerender|gameplay"},
        }
        return
    end

    global.startup_args = {"new_game", "template.loading-scene"}
end