local ecs = ...
local world = ecs.world

local FRAMES_PER_SECOND <const> = 30
local bgfx = require 'bgfx'
local gameplay_core = require "gameplay.core"
local icamera_controller = ecs.require "engine.system.camera_controller"
local iefk = ecs.require "engine.efk"
local audio = import_package "ant.audio"
local rhwi = import_package "ant.hwi"
local font = import_package "ant.font"
local iom = ecs.require "ant.objcontroller|obj_motion"
local iani = ecs.require "ant.animation|controller.state_machine"
local iui = ecs.require "engine.system.ui_system"

local m = ecs.system 'init_system'

font.import "/pkg/vaststars.resources/ui/font/Alibaba-PuHuiTi-Regular.ttf"

local function createPrefabInst(prefab)
    local p = ecs.create_instance(prefab)
    function p:on_ready()
        local root <close> = world:entity(self.tag['*'][1])
        iom.set_position(root, {0, 0, 0})

        for _, eid in ipairs(self.tag['*']) do
            local e <close> = world:entity(eid, "animation_birth?in")
            if e.animation_birth then
                iani.play(self, {name = e.animation_birth, loop = true, speed = 1.0, manual = false})
            end
        end
    end
    function p:on_message()
    end
    return world:create_object(p)
end

function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    ecs.create_instance "/pkg/vaststars.resources/daynight.prefab"
    ecs.create_instance "/pkg/vaststars.resources/light.prefab"

    iefk.preload "/pkg/vaststars.resources/effects/"

    rhwi.set_profie(gameplay_core.settings_get("debug", true))

    -- audio test (Master.strings.bank must be first)
    audio.load {
        "/pkg/vaststars.resources/sounds/Master.strings.bank",
        "/pkg/vaststars.resources/sounds/Master.bank",
        "/pkg/vaststars.resources/sounds/Building.bank",
        "/pkg/vaststars.resources/sounds/Function.bank",
        "/pkg/vaststars.resources/sounds/UI.bank",
    }

    -- audio.play("event:/openui1")
    audio.play("event:/background")

    --
    icamera_controller.set_camera_from_prefab("camera_gamecover.prefab")
    createPrefabInst("/pkg/vaststars.resources/glbs/game-cover.glb|mesh.prefab")
    iui.open({"/pkg/vaststars.resources/ui/login.rml"})
end