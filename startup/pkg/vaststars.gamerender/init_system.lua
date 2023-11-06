local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local FPS <const> = CONSTANT.FPS
local NOTHING <const> = ecs.require "debugger".nothing
local TERRAIN_ONLY <const> = ecs.require "debugger".terrain_only
local DISABLE_AUDIO <const> = ecs.require "debugger".disable_audio
local CUSTOM_ARCHIVING <const> = ecs.require "debugger".custom_archiving
local PROTOTYPE_VERSION <const> = ecs.require "vaststars.prototype|version"

local ARCHIVAL_BASE_DIR
if not __ANT_RUNTIME__ and CUSTOM_ARCHIVING then
    local fs = require "bee.filesystem"
    ARCHIVAL_BASE_DIR = (fs.exe_path():parent_path() / CUSTOM_ARCHIVING):lexically_normal():string()
end

local bgfx = require 'bgfx'
local audio = import_package "ant.audio"
local font = import_package "ant.font"
local ltask = require "ltask"
local archiving = require "archiving"

local m = ecs.system 'init_system'

bgfx.maxfps(FPS)
font.import "/pkg/vaststars.resources/ui/font/Alibaba-PuHuiTi-Regular.ttf"

-- todo: more info
local function register_debug()
	local S = ltask.dispatch()

    local COMMAND = {}
    COMMAND.ping = function(q)
        return {COMMAND = q}
    end

	function S.send(what, ...)
        world:pub {"game_debug", what, ...}
        return "SUCCESS"
    end

    function S.call(what, ...)
        local c = assert(COMMAND[what])
		return c(what, ...)
	end
end

local function start_web()
    if not __ANT_RUNTIME__ then
		return
	end

	register_debug()
	local webserver = import_package "vaststars.webcgi"
	webserver.start()
end

function m:init_world()
	start_web()

    archiving.set_dir(ARCHIVAL_BASE_DIR)
    archiving.set_version(PROTOTYPE_VERSION)

    if NOTHING or TERRAIN_ONLY then
        ecs.require "main_menu_manager".new_game()
        return
    end

    world:create_instance {
        prefab = "/pkg/vaststars.resources/light.prefab",
    }

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

    local login = ecs.require "main_menu_manager".login
    login()
end