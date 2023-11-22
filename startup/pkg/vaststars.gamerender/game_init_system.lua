local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local FPS <const> = CONSTANT.FPS

local debugger = ecs.require "debugger"
local iprototype = require "gameplay.interface.prototype"
local icanvas = ecs.require "engine.canvas"
local rhwi = import_package "ant.hwi"
local gameplay_core = require "gameplay.core"
local iguide = require "gameplay.interface.guide"
local iui = ecs.require "engine.system.ui_system"
local iroadnet = ecs.require "engine.roadnet"
local saveload = ecs.require "saveload"
local global = require "global"
local irender = ecs.require "ant.render|render_system.render"
local imountain = ecs.require "engine.mountain"
local iterrain  = ecs.require "terrain"
local iinventory = require "gameplay.interface.inventory"
local imineral = ecs.require "mineral"
local iscience = require "gameplay.interface.science"
local bgfx = require 'bgfx'
local font = import_package "ant.font"
local irq = ecs.require "ant.render|render_system.renderqueue"
local init = ecs.require "init"

local m = ecs.system "game_init_system"
local gameworld_prebuild
local gameworld_build
local gameworld
local need_update = false

bgfx.maxfps(FPS)
font.import "/pkg/vaststars.resources/ui/font/Alibaba-PuHuiTi-Regular.ttf"

local function get_lorrys()
    local l = {}
    for _, typeobject in pairs(iprototype.each_type("factory")) do
        local item = iprototype.queryByName(typeobject.item)
        l[item.id] = true
    end
    return l
end

local function init_game(template)
    local gameplay_world = gameplay_core.get_world()

    imineral.init(template.mineral)
    imountain:init(template.mountain)
    iscience.update_tech_list(gameplay_world)

    rhwi.set_profie(template.performance_stats ~= false and gameplay_core.settings_get("debug", true) or false)
    irender.set_framebuffer_ratio("scene_ratio", gameplay_core.settings_get("ratio", 1))

    iinventory.set_infinite_item(debugger.infinite_item)
    iinventory.set_lorry_list(get_lorrys())

    icanvas.create("icon", template.canvas_icon ~= false and gameplay_core.settings_get("info", true) or false, 10)
    icanvas.create("pickup_icon", false, 10)
    icanvas.create("road_entrance_marker", false, 0.02)

    if template.research_queue then
        gameplay_world:research_queue(template.research_queue)
    end

    iguide.init(gameplay_world, template.guide)
    if next(template.guide) and debugger.skip_guide then
        print("skip guide")
        for _, guide in ipairs(template.guide) do
            if next(guide.narrative_end.task) then
                for _, task in ipairs(guide.narrative_end.task) do
                    local typeobject = iprototype.queryByName(task)
                    gameplay_world:research_progress(task, typeobject.count)
                end
            end
        end
        gameplay_core.get_storage().guide_id = #template.guide + 1
    end
    iui.set_guide_progress(iguide.get_progress())

    for _, prefab in ipairs(template.init_instances) do
        world:create_instance {
            prefab = prefab
        }
    end

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
    world:create_instance {
        prefab = assert(template.camera),
        on_ready = function(self)
            local eid = assert(self.tag["camera"][1])
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
    init()

    gameworld_prebuild = world:pipeline_func "gameworld_prebuild"
    gameworld_build = world:pipeline_func "gameworld_build"
    gameworld = world:pipeline_func "gameworld"

    -- the light must be created in the frame before all entities are created
    world:create_instance {
        prefab = "/pkg/vaststars.resources/daynight_day.prefab"
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