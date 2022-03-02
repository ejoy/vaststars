local ecs = ...
local world = ecs.world
local w = world.w

local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local construct_sys = ecs.system "construct_system"
local prototype = ecs.require "prototype"
local terrain = ecs.require "terrain"
local input = ecs.require "input"
local math3d = require "math3d"

local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"}       -- 建造模式
local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}

local CONSTRUCT_RED_BASIC_COLOR <const> = {50.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}
local CONSTRUCT_WHITE_BASIC_COLOR <const> = {50.0, 50.0, 50.0, 0.8}
local DISMANTLE_YELLOW_BASIC_COLOR <const> = {50.0, 50.0, 0.0, 0.8}

local entity_cfg = import_package "vaststars.config".entity

local function check_construct_detector(...)
    return true
end

local function update_basecolor(prefab, basecolor_factor)
    local e
    for _, eid in ipairs(prefab.tag["*"]) do
        e = world:entity(eid)
        if e.material then
            imaterial.set_property(e, "u_basecolor_factor", basecolor_factor)
        end
    end
end

local function get_construct_detector(prototype_name)
    local cfg = entity_cfg[prototype_name]
    if not cfg then
        log.error(("can not found prototype_name `%s`"):format(prototype_name))
        return
    end
    return cfg.construct_detector
end

local function update_basecolor_by_pos(game_object)
    local basecolor_factor
    local prefab = igame_object.get_prefab(game_object)
    local position = math3d.tovalue(iom.get_position(prefab.root))
    local construct_detector = get_construct_detector(game_object.prototype_name)

    if construct_detector then
        local area = prototype.get_area(game_object.constructing.prototype_name)
        if not area then
            return
        end

        local coord = terrain.get_coord_by_position(position)
        if not check_construct_detector(construct_detector, coord[1], coord[2], game_object.constructing.dir, area) then
            basecolor_factor = CONSTRUCT_RED_BASIC_COLOR
        else
            basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
        end
    else
        basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
    end
    update_basecolor(prefab, basecolor_factor)
end

--
local on_prefab_message ; do
    local funcs = {}
    funcs["update_basecolor"] = function(game_object)
        update_basecolor_by_pos(game_object)
    end

    function on_prefab_message(game_object, prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(game_object, prefab, ...)
        end
    end
end

--
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

    for game_object in w:select "id:in constructing:in" do
        igame_object.remove(game_object.id)
    end

    local area = prototype.get_area(prototype_name)
    if not area then
        return
    end

    local f = ("/pkg/vaststars.resources/%s"):format(cfg.prefab)
    local template = replace_material(serialize.parse(f, cr.read_file(f)))
    local prefab = ecs.create_instance(template)
    prefab.on_message = on_prefab_message

    local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
    local rect = mq.render_target.view_rect
    local coord, position = terrain.adjust_position(input.screen_to_world(rect.w // 2, rect.h // 2), area)
    iom.set_position(world:entity(prefab.root), position)

    igame_object.create(prefab, {
        policy = {},
        data = {
            drapdrop = true,
            pause_animation = true,
            constructing = {
                prototype_name = prototype_name,
                prefab = cfg.prefab,
                fluid = {},
                dir = "N",
                x = coord[1],
                y = coord[2],
            }
        }
    },
    {
        "drapdrop",
    })
end

local function drapdrop_entity(game_object_eid, mouse_x, mouse_y)
    local game_object = world:entity(game_object_eid)
    if not game_object then
        log.error(("can not found game_object `%s`"):format(game_object_eid))
        return
    end

    if not game_object.constructing then
        return
    end

    local prefab_object = igame_object.get_prefab_object(game_object_eid)
    if not prefab_object then
        log.error(("can not found prefab_object `%s`"):format(game_object_eid))
        return
    end

    local area = prototype.get_area(game_object.constructing.prototype_name)
    if not area then
        return
    end

    local coord, position = terrain.adjust_position(input.screen_to_world(mouse_x, mouse_y), area)
    if not coord then
        return
    end

    game_object.constructing.x = coord[1]
    game_object.constructing.y = coord[2]

    iom.set_position(world:entity(prefab_object.root), position)
    prefab_object:send("update_basecolor")
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

    for _, game_object_eid, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        drapdrop_entity(game_object_eid, mouse_x, mouse_y)
    end
end
