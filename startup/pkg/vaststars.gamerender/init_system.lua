local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local FPS <const> = CONSTANT.FPS
local NOTHING <const> = ecs.require "debugger".nothing
local TERRAIN_ONLY <const> = ecs.require "debugger".terrain_only
local DISABLE_AUDIO <const> = ecs.require "debugger".disable_audio
local PROTOTYPE_VERSION <const> = ecs.require "vaststars.prototype|version"

local debugger = ecs.require "debugger"
local iprototype = require "gameplay.interface.prototype"
local icanvas = ecs.require "engine.canvas"
local rhwi = import_package "ant.hwi"
local gameplay_core = require "gameplay.core"
local iguide = require "gameplay.interface.guide"
local iui = ecs.require "engine.system.ui_system"
local iroadnet = ecs.require "roadnet"
local saveload = ecs.require "saveload"
local global = require "global"
local irender = ecs.require "ant.render|render_system.render"
local imountain = ecs.require "engine.mountain"
local iterrain  = ecs.require "terrain"
local ibackpack = require "gameplay.interface.backpack"
local imineral = ecs.require "mineral"
local iscience = require "gameplay.interface.science"
local bgfx = require 'bgfx'
local audio = import_package "ant.audio"
local font = import_package "ant.font"
local archiving = require "archiving"
local start_web = ecs.require "webcgi"
local irq = ecs.require "ant.render|render_system.renderqueue"
local imodifier = ecs.require "ant.modifier|modifier"

local m = ecs.system "game_init_system"
local gameworld_prebuild
local gameworld_build
local gameworld
local need_update = false

bgfx.maxfps(FPS)
font.import "/pkg/vaststars.resources/ui/font/Alibaba-PuHuiTi-Regular.ttf"

local function init()
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
        global.startup_args = {"nothing"}
        return
    end

    if TERRAIN_ONLY then
        global.startup_args = {"terrain_only"}
        return
    end

    global.startup_args = {"new_game", "template.loading-scene"}
end

local function init_game(template)
    imineral.init(template.mineral)
    imountain:init(template.mountain)
    iscience.update_tech_list(gameplay_core.get_world())

    rhwi.set_profie(template.performance_stats ~= false and gameplay_core.settings_get("debug", true) or false)
    ibackpack.set_infinite_item(debugger.infinite_item)
    irender.set_framebuffer_ratio("scene_ratio", gameplay_core.settings_get("ratio", 1))

    icanvas.create("icon", template.canvas_icon ~= false and gameplay_core.settings_get("info", true) or false, 10)
    icanvas.create("pickup_icon", false, 10)
    icanvas.create("road_entrance_marker", false, 0.02)

    iguide.init(gameplay_core.get_world(), template.guide)
    if next(template.guide) and debugger.skip_guide then
        print("skip guide")
        for _, guide in ipairs(template.guide) do
            if next(guide.narrative_end.task) then
                for _, task in ipairs(guide.narrative_end.task) do
                    local typeobject = iprototype.queryByName(task)
                    gameplay_core.get_world():research_progress(task, typeobject.count)
                end
            end
        end
        gameplay_core.get_storage().guide_id = #template.guide + 1
    end
    iui.set_guide_progress(iguide.get_progress())

    for _, rml in ipairs(template.init_ui) do
        iui.open({rml = rml})
    end
end

local funcs = {}
funcs["nothing"] = function()
    world:create_instance {
        prefab = "/pkg/vaststars.resources/camera_default.prefab",
        on_ready = function(self)
            local eid = assert(self.tag["camera"][1])
            irq.set_camera("main_queue", eid)
        end
    }
end

funcs["terrain_only"] = function()
    need_update = true
    iterrain.create()
    world:create_instance {
        prefab = "/pkg/vaststars.resources/camera_default.prefab",
        on_ready = function(self)
            local eid = assert(self.tag["camera"][1])
            irq.set_camera("main_queue", eid)
        end
    }
end

funcs["new_game"] = function(file)
    need_update = true
    iterrain.create()
    iroadnet:create()

    saveload:restart(file)
    local template = ecs.require(("vaststars.prototype|%s"):format(file))
    for k, v in pairs(template.debugger or {}) do
        debugger[k] = v
    end

    -- replace the default camera
    local mf = imodifier.create_srt_modifier_from_file(nil, 0, "/pkg/vaststars.resources/animations/camera.anim", false, true)
    world:create_instance {
        prefab = assert(template.camera),
        on_ready = function(self)
            local eid = assert(self.tag["camera"][1])
            imodifier.set_target(mf, eid)
            imodifier.start(mf, {loop = true})
            irq.set_camera("main_queue", eid)
        end
    }

    init_game(template)
end

funcs["restore"] = function(path)
    need_update = true
    iterrain.create()
    iroadnet:create()

    saveload:restore(path)
    local file = assert(gameplay_core.get_storage().game_template)
    local template = ecs.require(("vaststars.prototype|%s"):format(file))
    for k, v in pairs(template.debugger or {}) do
        debugger[k] = v
    end
    init_game(template)
end

function m:init()
    if not global.init then
        init()
        global.init = true
    end

    gameworld_prebuild = world:pipeline_func "gameworld_prebuild"
    gameworld_build = world:pipeline_func "gameworld_build"
    gameworld = world:pipeline_func "gameworld"

    -- the light must be created in the frame before all entities are created
    world:create_instance {
        prefab = "/pkg/vaststars.resources/daynight.prefab"
    }
    world:create_instance {
        prefab = "/pkg/vaststars.resources/light.prefab"
    }
    world:create_instance {
        prefab = "/pkg/vaststars.resources/sky.prefab"
    }
end

function m:init_world()
    local args = global.startup_args
    local func = assert(funcs[args[1]])
    func(table.unpack(args, 2))
    global.startup_args = {}
end

function m:gameworld_end()
    local gameplay_ecs = gameplay_core.get_world().ecs
    gameplay_ecs:clear("building_new")
end

function m:frame_update()
    if not need_update then
        return
    end

    local gameplay_world = gameplay_core.get_world()
    if gameplay_core.system_changed_flags ~= 0 then
        print("build world")
        gameplay_core.system_changed_flags = 0
        gameworld_prebuild()
        gameplay_world:update()
        gameworld_build()
    else
        if gameplay_core.world_update then
            gameplay_world:update()
            gameworld()
        end
    end
end