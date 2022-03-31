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
local fluidbox_map = ecs.require "fluidbox_map"
local dir = require "dir"
local dir_rotate = dir.rotate
local pipe = ecs.require "pipe"

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

local CONSTRUCT_BLOCK_RED_BASIC_COLOR <const> = {20000, 0.0, 0.0, 1.0}
local CONSTRUCT_BLOCK_GREEN_BASIC_COLOR <const> = {0.0, 20000, 0.0, 1.0}

local cur_mode = ""

local function get_data_object(game_object)
    return setmetatable(game_object.gameplay_entity, {
        __index = gameplay.entity(game_object.game_object.x, game_object.game_object.y) or {}
    })
end

local function check_construct_detector(prototype_name, x, y, dir)
    for _, game_object in engine.world_select "game_object" do
        local data_object = get_data_object(game_object)
        if data_object.x == x and data_object.y == y then
            return (game_object.construct_pickup == true)
        end
    end
end

local function update_game_object_color(game_object)
    local data_object = get_data_object(game_object)
    local color, block_color
    local construct_detector = prototype.get_construct_detector(data_object.prototype_name)
    if construct_detector then
        if not check_construct_detector(data_object.prototype_name, data_object.x, data_object.y, data_object.dir) then
            color = CONSTRUCT_RED_BASIC_COLOR
            block_color = CONSTRUCT_BLOCK_RED_BASIC_COLOR
        else
            color = CONSTRUCT_GREEN_BASIC_COLOR
            block_color = CONSTRUCT_BLOCK_GREEN_BASIC_COLOR
        end
    end
    igame_object.update(game_object.id, {color = color, block_color = block_color})
end

local plane = math3d.ref(math3d.vector(0, 1, 0, 0))

local function get_central_position()
    local ce = world:entity(irq.main_camera())
    local ray = {o = iom.get_position(ce), d = math3d.mul(math.maxinteger, iom.get_direction(ce))}
    return math3d.tovalue(math3d.muladd(ray.d, math3d.plane_ray(ray.o, ray.d, plane), ray.o))
end

local function new_construct_object(prototype_name)
    local typeobject = prototype.query_by_name("entity", prototype_name)
    local coord = terrain.adjust_position(get_central_position(), typeobject.area)

    local color, blockcolor
    local construct_detector = prototype.get_construct_detector(prototype_name)
    if construct_detector then
        if not check_construct_detector(prototype_name, coord[1], coord[2], 'N') then
            color = CONSTRUCT_RED_BASIC_COLOR
            blockcolor = CONSTRUCT_BLOCK_RED_BASIC_COLOR
        else
            color = CONSTRUCT_GREEN_BASIC_COLOR
            blockcolor = CONSTRUCT_BLOCK_GREEN_BASIC_COLOR
        end
    end
    igame_object.create(prototype_name, coord[1], coord[2], 'N', "opaque", color, blockcolor, true)

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

local function is_fluidbox(x, y)
    local game_object = engine.world_singleton("construct_pickup", "construct_pickup")
    if game_object then
        local gameplay_entity = game_object.gameplay_entity
        if gameplay_entity.x == x and gameplay_entity.y == y then
            if prototype.is_pipe(game_object.gameplay_entity.prototype_name) then
                return true
            end
        end

        for _, v in ipairs(fluidbox_map:precheck(gameplay_entity.x, gameplay_entity.y, gameplay_entity.prototype_name)) do
            if v[1] == x and v[2] == y then
                return true
            end
        end
    end

    return fluidbox_map:check(x, y)
end

local vector2 = ecs.require "vector2"
local pipe_neighbor <const> = {
    vector2.DOWN,
    vector2.UP,
    vector2.LEFT,
    vector2.RIGHT,
    {0, 0},
}

function construct_sys:camera_usage()
    for _, state in touch_mb:unpack() do
        if not (state == "CANCEL" or state == "END") then
            goto continue
        end

        local game_object = engine.world_singleton("construct_pickup", "construct_pickup")
        if not game_object then
            goto continue
        end

        -- 还原由于拖动而变更过的水管
        for _, object in engine.world_select("pipe_modified") do
            local pipe_modified = object.pipe_modified
            igame_object.update(object.id, {prototype_name = pipe_modified.old_prototype_name})
            igame_object.set_dir(object.id, pipe_modified.old_dir)
        end
        w:clear "pipe_modified"

        -- 自动吸附至附近的格子
        local typeobject = prototype.query_by_name("entity", game_object.gameplay_entity.prototype_name)
        local coord, position = terrain.adjust_position(get_central_position(), typeobject.area)
        igame_object.set_position(game_object.id, position)
        game_object.gameplay_entity.x, game_object.gameplay_entity.y = coord[1], coord[2]
        game_object.game_object.x, game_object.game_object.y = coord[1], coord[2]
        update_game_object_color(game_object)

        -- 如果拖动的建筑是水管, 检查是否需要变更水管的形状
        local gameplay_entity = game_object.gameplay_entity
        if prototype.has_fluidbox(gameplay_entity.prototype_name) then
            local check = {}
            if prototype.is_pipe(gameplay_entity.prototype_name) then
                for _, v in ipairs(pipe_neighbor) do
                    check[#check+1] = {gameplay_entity.x + v[1], gameplay_entity.y + v[2]}
                end
            else
                local neighbor = {vector2.DOWN, vector2.UP, vector2.LEFT, vector2.RIGHT}
                for _, v in ipairs(fluidbox_map:precheck(gameplay_entity.x, gameplay_entity.y, gameplay_entity.prototype_name)) do
                    for _, n in ipairs(neighbor) do
                        check[#check+1] = {v[1] + n[1], v[2] + n[2]}
                    end
                end
            end

            for _, v in ipairs(check) do
                for raw_object, object in engine.world_select "game_object pipe_modified?new" do
                    if game_object.game_object.x == v[1] and game_object.game_object.y == v[2] then
                        local data_object = get_data_object(object)
                        if prototype.is_pipe(data_object.prototype_name) then
                            local prototype_name, dir = pipe.update(data_object.prototype_name, data_object.x, data_object.y, is_fluidbox)
                            engine.new_component(raw_object, "pipe_modified", {
                                old_prototype_name = data_object.prototype_name,
                                old_dir = data_object.dir,
                                prototype_name = prototype_name,
                                dir = dir,
                            })
                            igame_object.update(object.id, {prototype_name = prototype_name})
                            igame_object.set_dir(object.id, dir)
                        end
                    end
                end
            end
        end
        ::continue::
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
            -- 由于拖动水管而变更过的物体
            for _, object in engine.world_select("pipe_modified") do
                local gameplay_entity = object.gameplay_entity
                local pipe_modified = object.pipe_modified
                gameplay_entity.prototype_name = pipe_modified.prototype_name
                gameplay_entity.dir = pipe_modified.dir
                object.construct_modify = true
            end

            local gameplay_entity = game_object.gameplay_entity
            local construct_detector = prototype.get_construct_detector(gameplay_entity.prototype_name)
            if construct_detector then
                if not check_construct_detector(gameplay_entity.prototype_name, gameplay_entity.x, gameplay_entity.y, gameplay_entity.dir) then
                    print("can not construct") -- todo error tips
                    goto continue
                else
                    igame_object.update(game_object.id, {state = "translucent", color = CONSTRUCT_WHITE_BASIC_COLOR, show_block = false})
                    game_object.construct_pickup = false

                    print("construct_confirm", gameplay_entity.x, gameplay_entity.y, gameplay_entity.prototype_name, game_object.id)
                    fluidbox_map:set(game_object.id, gameplay_entity.x, gameplay_entity.y, gameplay_entity.prototype_name)
                end
            end

            new_construct_object(gameplay_entity.prototype_name)

            -- 显示"开始施工"
            world:pub {"ui_message", "show_construct_complete", true}
        end

        w:clear "pipe_modified"
        ::continue::
    end

    for _ in ui_construct_begin_mb:unpack() do
        cur_mode = "construct"
        gameplay.world_update = false
        engine.set_camera_prefab("camera_construct.prefab")
    end

    for _ in ui_construct_complete_mb:unpack() do
        fluidbox_map:flush()
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
                igame_object.update(game_object.id, {state = "opaque", show_block = false})
            else
                for k, v in pairs(game_object.gameplay_entity) do
                    entity[k] = v
                end
                igame_object.update(game_object.id, {state = "opaque", show_block = false})
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
