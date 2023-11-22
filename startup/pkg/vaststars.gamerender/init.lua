local ecs = ...
local world = ecs.world
local w = world.w

local PROTOTYPE_VERSION <const> = ecs.require "vaststars.prototype|version"
local DISABLE_AUDIO <const> = ecs.require "debugger".disable_audio
local NOTHING <const> = ecs.require "debugger".nothing
local TERRAIN_ONLY <const> = ecs.require "debugger".terrain_only

local global = require "global"
local reboot_world = ecs.require "reboot_world"
local audio = import_package "ant.audio"
local start_web = ecs.require "engine.webcgi"
local archiving = require "archiving"
local ltask = require "ltask"

return function()
    if global.init then
        return
    end
    global.init = true

    ltask.uniqueservice "vaststars.gamerender|memtexture"

    start_web()

    archiving.set_version(PROTOTYPE_VERSION)

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
        reboot_world({"vaststars.gamerender|gameplay"}, "nothing")
        return
    end

    if TERRAIN_ONLY then
        reboot_world({"vaststars.gamerender|gameplay"}, "terrain_only")
        return
    end

    global.startup_args = {"new_game", "template.loading-scene"}
end