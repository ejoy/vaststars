local ecs = ...
local world = ecs.world
local w = world.w

local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local construct_sys = ecs.system "construct_system"
local prototype = ecs.require "prototype"
local gameplay = ecs.require "gameplay"
local engine = ecs.require "engine"
local irq = ecs.import.interface "ant.render|irenderqueue"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local math3d = require "math3d"
local terrain = ecs.require "terrain"
local fluidbox = ecs.require "fluidbox"
local dir = require "dir"
local dir_rotate = dir.rotate

local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"}       -- 建造模式
local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_rotate_mb = world:sub {"ui", "construct", "rotate"}
local ui_construct_confirm_mb = world:sub {"ui", "construct", "construct_confirm"}
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工
local ui_construct_cancel_mb = world:sub {"ui", "construct", "cancel"}
local ui_fluidbox_update_mb = world:sub {"ui", "construct", "fluidbox_update"}
local pickup_mapping_mb = world:sub {"pickup_mapping"}
local touch_mb = world:sub {"touch"}

local CONSTRUCT_RED_BASIC_COLOR <const> = {50.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}
local CONSTRUCT_WHITE_BASIC_COLOR <const> = {50.0, 50.0, 50.0, 0.8}
local DISMANTLE_YELLOW_BASIC_COLOR <const> = {50.0, 50.0, 0.0, 0.8}

local cur_mode = ""

local function get_data_object(game_object)
    if game_object.construct_pickup then
        return game_object.gameplay_entity
    end

    return setmetatable(game_object.gameplay_entity, {
        __index = gameplay.entity(game_object.game_object.x, game_object.game_object.y) or {}
    })
end

local function check_construct_detector(prototype_name, x, y, dir)
    local game_object = igame_object.get_game_object(x, y)
    if not game_object then
        return true
    end
    return (game_object.construct_pickup == true)
end

local function update_game_object_color(game_object)
    local data_object = get_data_object(game_object)
    local color
    local construct_detector = prototype.get_construct_detector(data_object.prototype_name)
    if construct_detector then
        if not check_construct_detector(data_object.prototype_name, data_object.x, data_object.y, data_object.dir) then
            color = CONSTRUCT_RED_BASIC_COLOR
        else
            color = CONSTRUCT_GREEN_BASIC_COLOR
        end
    end
    igame_object.update(game_object.id, {color = color})
end

local math_util = import_package "ant.math".util
local pt2D_to_NDC = math_util.pt2D_to_NDC
local ndc_to_world = math_util.ndc_to_world
local plane = math3d.ref(math3d.vector(0, 1, 0, 0))

local function get_central_position()
    local ce = world:entity(irq.main_camera())
    local ray = {o = iom.get_position(ce), d = math3d.mul(math.maxinteger, iom.get_direction(ce))}
    return math3d.tovalue(math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, plane), ray.o))
end

local function screen_to_position(x, y)
    local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
    local ce = world:entity(mq.camera_ref)
    local vpmat = ce.camera.viewprojmat -- in `camera_usage` stage

    local vr = irq.view_rect "main_queue"
    local ndcpt = pt2D_to_NDC({x, y}, vr)
    ndcpt[3] = 0
    local p0 = ndc_to_world(vpmat, ndcpt)
    ndcpt[3] = 1
    local p1 = ndc_to_world(vpmat, ndcpt)

    local ray = {o = p0, d = math3d.sub(p0, p1)}
    return math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, plane), ray.o)
end

local function new_construct_object(prototype_name)
    local typeobject = prototype.query_by_name("entity", prototype_name)
    local coord = terrain.adjust_position(get_central_position(), typeobject.area)

    local color
    local construct_detector = prototype.get_construct_detector(prototype_name)
    if construct_detector then
        if not check_construct_detector(prototype_name, coord[1], coord[2], 'N') then
            color = CONSTRUCT_RED_BASIC_COLOR
        else
            color = CONSTRUCT_GREEN_BASIC_COLOR
        end
    end
    igame_object.create(prototype_name, coord[1], coord[2], 'N', "translucent", color, true)
    if prototype.is_fluidbox(prototype_name) then
        world:pub {"ui_message", "show_set_fluidbox", true}
    end
end

local function clear_construct_pickup_object()
    local game_object = engine.world_singleton("construct_pickup", "construct_pickup")
    if game_object then
        igame_object.remove(game_object.id)
    end
end

do
    local begin_pos
    function construct_sys:camera_usage()
        local last_move_x, last_move_y
        for _, state, data in touch_mb:unpack() do
            if state == "START" then
                begin_pos = math3d.ref(screen_to_position(data[1].x, data[1].y))

            elseif state == "MOVE" then
                last_move_x, last_move_y = data[1].x, data[1].y

            elseif state == "CANCEL" or state == "END" then
                begin_pos = nil

                local game_object = engine.world_singleton("construct_pickup", "construct_pickup")
                if game_object then
                    local typeobject = prototype.query_by_name("entity", game_object.gameplay_entity.prototype_name)
                    local coord, position = terrain.adjust_position(get_central_position(), typeobject.area)
                    igame_object.set_position(game_object.id, position)
                    game_object.gameplay_entity.x, game_object.gameplay_entity.y = coord[1], coord[2]
                    game_object.game_object.x, game_object.game_object.y = coord[1], coord[2]
                    update_game_object_color(game_object)
                end
            end
        end

        if begin_pos and last_move_x and last_move_y then
            local pos = screen_to_position(last_move_x, last_move_y)
            local mq = w:singleton("main_queue", "camera_ref:in render_target:in")
            local ce = world:entity(mq.camera_ref)
            local delta = math3d.inverse(math3d.sub(pos, begin_pos))
            iom.move_delta(ce, delta)
        end
    end
end

function construct_sys:data_changed()
    for _, _, _, prototype_name in ui_construct_entity_mb:unpack() do
        clear_construct_pickup_object()
        new_construct_object(prototype_name)
    end

    for _ in ui_construct_rotate_mb:unpack() do
        local game_object = engine.world_singleton("construct_pickup", "construct_pickup")
        if game_object then
            game_object.gameplay_entity.dir = dir_rotate(game_object.gameplay_entity.dir, -1) -- 逆时针方向旋转一次
            igame_object.set_dir(game_object.id, game_object.gameplay_entity.dir)
        end
    end

    for _ in ui_construct_confirm_mb:unpack() do
        local game_object = engine.world_singleton("construct_pickup", "construct_pickup")
        if game_object then
            local gameplay_entity = game_object.gameplay_entity
            local construct_detector = prototype.get_construct_detector(gameplay_entity.prototype_name)
            if construct_detector then
                if not check_construct_detector(gameplay_entity.prototype_name, gameplay_entity.x, gameplay_entity.y, gameplay_entity.dir) then
                    print("can not construct") -- todo error tips
                else
                    igame_object.update(game_object.id, {state = "translucent", color = CONSTRUCT_WHITE_BASIC_COLOR})
                    game_object.construct_pickup = false

                    print("construct_confirm", gameplay_entity.x, gameplay_entity.y, gameplay_entity.prototype_name, game_object.id)
                    fluidbox:set(game_object.id, gameplay_entity.x, gameplay_entity.y, gameplay_entity.prototype_name)
                end
            end
            new_construct_object(gameplay_entity.prototype_name)

            -- 显示"开始施工"
            world:pub {"ui_message", "show_construct_complete", true}
        end
    end

    for _ in ui_construct_begin_mb:unpack() do
        cur_mode = "construct"
        gameplay.world_update = false
        engine.set_camera_prefab("camera_construct.prefab")
    end

    for _ in ui_construct_complete_mb:unpack() do
        clear_construct_pickup_object()
        cur_mode = ""
        gameplay.world_update = true
        engine.set_camera_prefab("camera_default.prefab")
        world:pub {"ui_message", "show_set_fluidbox", false}

        for _, game_object in engine.world_select "construct_modify" do
            if not game_object then
                goto continue
            end

            local entity = gameplay.entity(game_object.game_object.x, game_object.game_object.y)
            if not entity then
                gameplay.create_entity(game_object.gameplay_entity)
                igame_object.update(game_object.id, {state = "opaque"})
            else
                for k, v in pairs(game_object.gameplay_entity) do
                    entity[k] = v
                end
                igame_object.update(game_object.id, {state = "opaque"})
                game_object.game_object.x, game_object.game_object.y = entity.x, entity.y
            end
            game_object.gameplay_entity = {}
            game_object.construct_modify = false
            ::continue::
        end

        gameplay.build()
    end

    for _ in ui_construct_cancel_mb:unpack() do
        clear_construct_pickup_object()
        cur_mode = ""
        gameplay.world_update = true
        engine.set_camera_prefab("camera_default.prefab")
        world:pub {"ui_message", "show_set_fluidbox", false}
    end

    for _, _, _, fluidname in ui_fluidbox_update_mb:unpack() do
        local game_object = engine.world_singleton("construct_pickup", "construct_pickup")
        if game_object then
            game_object.gameplay_entity.fluid = {fluidname, 0}
        end
    end

    for _, param, eid in pickup_mapping_mb:unpack() do
        if cur_mode == "construct" then

        end
    end
end
