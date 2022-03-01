local ecs = ...
local world = ecs.world
local w = world.w

local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"
local hwi  = import_package "ant.hwi"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local construct_sys = ecs.system "construct_system"
local prototype = ecs.require "prototype"
local math3d = require "math3d"
local terrain = ecs.require "terrain"
local input = ecs.require "input"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"}       -- 建造模式
local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工
local entity_cfg = import_package "vaststars.config".entity

local function replace_material(template)
    for _, v in ipairs(template) do
        for _, policy in ipairs(v.policy) do
            if policy == "ant.render|render" or policy == "ant.render|simplerender" then
                v.data.material = "/pkg/vaststars.resources/construct.material"
            end
        end
    end

    return template
end

local function construct_entity(prototype_name)
    local cfg = entity_cfg[prototype_name]
    if not cfg then
        log.error(("can not found prototype_name `%s`"):format(prototype_name))
        return
    end

    for game_object in w:select "constructing:in" do
        igame_object.remove(game_object)
    end

    local area = prototype.get_area(prototype_name)
    if not area then
        log.error(("can not found prototype `%s`"):format(prototype_name))
        return
    end

    local f = ("/pkg/vaststars.resources/%s"):format(cfg.prefab)
    local template = replace_material(serialize.parse(f, cr.read_file(f)))
    local prefab = ecs.create_instance(template)

    local screen_x, screen_y = hwi.screen_size()
    local coord, position = terrain.adjust_position(input.screen_to_world(screen_x / 2, screen_y / 2), area)
    iom.set_position(world:entity(prefab.root), position)
end

function construct_sys:data_changed()
    for _ in ui_construct_begin_mb:unpack() do
        print("construct")
    end

    for _ in ui_construct_complete_mb:unpack() do
        print("construct complete")
    end
end

function construct_sys:camera_usage()
    for _, _, _, prototype_name in ui_construct_entity_mb:unpack() do
        construct_entity(prototype_name)
    end
end
