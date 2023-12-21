local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local FPS <const> = CONSTANT.FPS

local bgfx = require "bgfx"
local rhwi = import_package "ant.hwi"
local irender = ecs.require "ant.render|render_system.render"
local irq = ecs.require "ant.render|render_system.renderqueue"
local imodifier = ecs.require "ant.modifier|modifier"
local iroadnet = ecs.require "engine.roadnet"
local icanvas = ecs.require "engine.canvas"
local imountain = ecs.require "engine.mountain"
local iprototype = require "gameplay.interface.prototype"
local iinventory = require "gameplay.interface.inventory"
local iscience = require "gameplay.interface.science"
local gameplay_core = require "gameplay.core"
local saveload = ecs.require "saveload"
local iterrain  = ecs.require "terrain"
local imineral = ecs.require "mineral"
local init = ecs.require "init"
local game_settings = ecs.require "game_settings"
local iRmlUi = ecs.require "ant.rmlui|rmlui_system"

local m = ecs.system "login_scene_system"

bgfx.maxfps(FPS)

local function get_lorrys()
    local l = {}
    for _, typeobject in pairs(iprototype.each_type("factory")) do
        local item = iprototype.queryByName(typeobject.lorry)
        l[item.id] = true
    end
    return l
end

local function init_game(template)
    local gameplay_world = gameplay_core.get_world()

    imineral.init(template.mineral)
    imountain:init(template.mountain)
    iscience.update_tech_list(gameplay_world)

    rhwi.set_profie(gameplay_core.settings_get("debug", false))
    irender.set_framebuffer_ratio("scene_ratio", gameplay_core.settings_get("ratio", 1))

    iinventory.set_infinite_item(game_settings.infinite_item)
    iinventory.set_lorry_list(get_lorrys())

    icanvas.create("icon", template.canvas_icon ~= false and gameplay_core.settings_get("info", true) or false, 10)
    icanvas.create("pickup_icon", false, 10)
    icanvas.create("road_entrance_marker", false, 0.02)

    if template.research_queue then
        gameplay_world:research_queue(template.research_queue)
    end

    for _, prefab in ipairs(template.init_instances) do
        world:create_instance {
            prefab = prefab
        }
    end

    iRmlUi.open "/pkg/vaststars.resources/ui/login.rml"
end

function m:init()
    init()

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
    local file = "template.loading-scene"
    iterrain.create()
    iroadnet:create()

    saveload:restart(file)
    local template = ecs.require(("vaststars.prototype|%s"):format(file))
    for k, v in pairs(template.game_settings or {}) do
        game_settings[k] = v
    end

    local mf
    if template.camera_animation then
        mf = imodifier.create_srt_modifier_from_file(nil, 0, template.camera_animation, false, true)
    end

    -- replace the default camera
    world:create_instance {
        prefab = assert(template.camera),
        on_ready = function(self)
            local eid = assert(self.tag["camera"][1])
            irq.set_camera_from_queuename("main_queue", eid)

            if mf then
                imodifier.set_target(mf, eid)
                imodifier.start(mf, {loop = true})
            end
        end
    }

    init_game(template)
    world:import_feature "vaststars.gamerender|gameplay_update"
end