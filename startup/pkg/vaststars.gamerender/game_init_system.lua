local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local FPS <const> = CONSTANT.FPS

local bgfx = require "bgfx"
local rhwi = import_package "ant.hwi"
local font = import_package "ant.font"
local irender = ecs.require "ant.render|render_system.render"
local irq = ecs.require "ant.render|render_system.renderqueue"
local iui = ecs.require "engine.system.ui_system"
local iroadnet = ecs.require "engine.roadnet"
local icanvas = ecs.require "engine.canvas"
local imountain = ecs.require "engine.mountain"
local iprototype = require "gameplay.interface.prototype"
local iguide = require "gameplay.interface.guide"
local iinventory = require "gameplay.interface.inventory"
local iscience = require "gameplay.interface.science"
local gameplay_core = require "gameplay.core"
local saveload = ecs.require "saveload"
local global = require "global"
local iterrain  = ecs.require "terrain"
local imineral = ecs.require "mineral"
local init = ecs.require "init"
local game_settings = ecs.require "game_settings"

local m = ecs.system "game_init_system"

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

    iinventory.set_infinite_item(game_settings.infinite_item)
    iinventory.set_lorry_list(get_lorrys())

    icanvas.create("icon", template.canvas_icon ~= false and gameplay_core.settings_get("info", true) or false, 10)
    icanvas.create("pickup_icon", false, 10)
    icanvas.create("road_entrance_marker", false, 0.02)

    if template.research_queue then
        gameplay_world:research_queue(template.research_queue)
    end

    iguide.init(gameplay_world, template.guide)
    if next(template.guide) and game_settings.skip_guide then
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
    iterrain.create()
    iroadnet:create()

    saveload:restart(file)
    local template = ecs.require(("vaststars.prototype|%s"):format(file))
    for k, v in pairs(template.game_settings or {}) do
        game_settings[k] = v
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
    world:import_feature "vaststars.gamerender|gameplay_update"
end

funcs["restore"] = function(path)
    iterrain.create()
    iroadnet:create()

    saveload:restore(path)
    local file = assert(gameplay_core.get_storage().game_template)
    local template = ecs.require(("vaststars.prototype|%s"):format(file))
    for k, v in pairs(template.game_settings or {}) do
        game_settings[k] = v
    end

    init_game(template)
    world:import_feature "vaststars.gamerender|gameplay_update"
end

function m:init()
    init()

    -- the light must be created in the frame before all entities are created
    world:create_instance {
        prefab = "/pkg/vaststars.resources/daynight_day.prefab"
    }
    world:create_instance {
        prefab = "/pkg/vaststars.resources/daynight_night.prefab"
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
