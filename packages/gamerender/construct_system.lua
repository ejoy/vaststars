local ecs = ...
local world = ecs.world
local w = world.w

local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iconstruct_button = ecs.import.interface "vaststars.gamerender|iconstruct_button"
local construct_sys = ecs.system "construct_system"
local prototype = ecs.require "prototype"
local gameplay = ecs.require "gameplay"
local ecswrap = ecs.require "ecswrap"
local pipe = ecs.require "pipe"
local dir = require "dir"
local dir_rotate = dir.rotate

local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"}       -- 建造模式
local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工
local ui_fluidbox_update_mb = world:sub {"ui", "construct", "fluidbox_update"}
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local construct_button_mb = world:sub {"construct_button"}

local CONSTRUCT_RED_BASIC_COLOR <const> = {50.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}
local CONSTRUCT_WHITE_BASIC_COLOR <const> = {50.0, 50.0, 50.0, 0.8}
local DISMANTLE_YELLOW_BASIC_COLOR <const> = {50.0, 50.0, 0.0, 0.8}

local construct_queue = {}

local function check_construct_detector(prototype_name, x, y, dir)
    local construct_detector = prototype.get_construct_detector(prototype_name)
    if not construct_detector then
        return true
    end

    local area = prototype.get_area(prototype_name)
    if not area then
        return false
    end

    return true
end

local function update_basecolor_by_pos(game_object)
    local gameplay_entity = game_object.gameplay_entity
    local basecolor_factor

    local x, y = igame_object.get_coord(game_object)
    if not check_construct_detector(gameplay_entity.prototype_name, x, y, gameplay_entity.dir) then
        basecolor_factor = CONSTRUCT_RED_BASIC_COLOR
    else
        basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
    end

    igame_object.set_state(game_object, "translucent", basecolor_factor)
end

local function confirm_construct(game_object)
    local gameplay_entity = game_object.gameplay_entity
    local construct_detector = prototype.get_construct_detector(gameplay_entity.prototype_name)
    if construct_detector then
        local x, y = igame_object.get_coord(game_object)
        if not check_construct_detector(gameplay_entity.prototype_name, x, y, gameplay_entity.dir) then
            print("can not construct") -- todo error tips
            return
        end
    end

    igame_object.set_state(game_object, "translucent", CONSTRUCT_WHITE_BASIC_COLOR)
    game_object.drapdrop = false
    game_object.construct_pickup = false
    iconstruct_button.hide()

    construct_queue[#construct_queue + 1] = {oper = "add", game_object = game_object}
end

local function get_object(game_object)
    local obj = {}
    for k, v in pairs(game_object.gameplay_entity) do
        obj[k] = v
    end

    if game_object.gameplay_eid ~= 0 then
        local e = gameplay.entity(game_object.gameplay_eid)
        for k, v in pairs(e) do
            obj[k] = obj[k] or v
        end
    end
    return obj
end

local function get_entity(x, y)
    for _, game_object in ecswrap.select "gameplay_eid" do
        -- entity 是否已经删除?
        if not igame_object.get_prefab_object(game_object.id) then
            goto continue
        end

        local obj = get_object(game_object)
        if obj.x == x and obj.y == y then
            return obj
        end
        ::continue::
    end
end

local function get_game_object(x, y)
    for _, game_object in ecswrap.select "gameplay_eid" do
        if not igame_object.get_prefab_object(game_object.id) then
            goto continue
        end

        local obj = get_object(game_object)
        if obj.x == x and obj.y == y then
            return game_object
        end
        ::continue::
    end
end

local adjust_neighbor_pipe ; do
    local vector2 = ecs.require "vector2"
    local neighbor <const> = {
        vector2.DOWN,
        vector2.UP,
        vector2.LEFT,
        vector2.RIGHT,
    }

    local function packCoord(x, y)
        assert(x & 0xFF == x)
        assert(y & 0xFF == y)
        return x | (y << 8)
    end

    local function unpackCoord(v)
        return v & 0xFF, v >> 8
    end

    function adjust_neighbor_pipe(...)
        local t = {}
        local a = {...}
        local x, y

        for _, n in ipairs(neighbor) do
            for _, v in ipairs(a) do
                x = v[1] + n[1]
                y = v[2] + n[2]
                t[packCoord(x, y)] = true
            end
        end

        for c in pairs(t) do
            x, y = unpackCoord(c)
            local game_object = get_game_object(x, y)
            if not game_object then
                goto continue
            end

            local prototype_name, dir = pipe.adjust(x, y, get_entity)
            if prototype_name then
                game_object.gameplay_entity.prototype_name = prototype_name
                game_object.gameplay_entity.dir = dir

                igame_object.set_prototype_name(game_object, prototype_name)
                igame_object.set_dir(game_object, dir)
            end
            ::continue::
        end
    end
end

local function drapdrop_entity(game_object_eid, mouse_x, mouse_y)
    local game_object = world:entity(game_object_eid)
    if not game_object then
        log.error(("can not found game_object `%s`"):format(game_object_eid))
        return
    end
    assert(game_object.construct_pickup == true)

    local gameplay_entity = game_object.gameplay_entity
    local x, y, position = prototype.get_coord(gameplay_entity.prototype_name, mouse_x, mouse_y)
    if x and y and gameplay_entity.x == x and gameplay_entity.y == y then
        return
    end

    igame_object.set_position(game_object, position)

    local sx, sy = gameplay_entity.x, gameplay_entity.y
    gameplay_entity.x, gameplay_entity.y = x, y

    -- 针对水管的特殊处理
    if prototype.is_pipe(gameplay_entity.prototype_name) then
        adjust_neighbor_pipe({sx, sy}, {x, y})

        local prototype_name, dir = pipe.adjust(gameplay_entity.x, gameplay_entity.y, get_entity)
        if prototype_name and (prototype_name ~= gameplay_entity.prototype_name or dir ~= gameplay_entity.dir )then
            gameplay_entity.prototype_name = prototype_name
            igame_object.set_prototype_name(game_object, prototype_name)

            gameplay_entity.dir = dir
            igame_object.set_dir(game_object, dir)
        end
    end

    local area = prototype.get_area(gameplay_entity.prototype_name)
    if not area then
        return
    end

    update_basecolor_by_pos(game_object)
    iconstruct_button.show(gameplay_entity.x, gameplay_entity.y, area)
end

local construct_button_events = {}
construct_button_events.confirm = function()
    local game_object = ecswrap.singleton("construct_pickup", "construct_pickup")
    if game_object then
        if prototype.is_fluidbox(game_object.gameplay_entity.prototype_name) then
            if not game_object.gameplay_entity.fluid[1] then
                world:pub {"ui_message", "show_set_fluidbox", true}
            else
                confirm_construct(game_object)
            end
        else
            confirm_construct(game_object)
        end
    end
end

construct_button_events.cancel = function()
    local game_object = ecswrap.singleton("construct_pickup", "construct_pickup")
    if game_object then
        iconstruct_button.hide()
        igame_object.remove(game_object.id)
    end
end

construct_button_events.rotate = function()
    local game_object = ecswrap.singleton("construct_pickup", "construct_pickup")
    if game_object then
        local dir = dir_rotate(game_object.gameplay_entity.dir, -1) -- 逆时针方向旋转一次
        game_object.gameplay_entity.dir = dir
        igame_object.set_dir(game_object, dir)
    end
end

function construct_sys:camera_usage()
    for _, _, _, prototype_name in ui_construct_entity_mb:unpack() do
        construct_button_events.cancel()
        igame_object.create(prototype_name, {
            on_ready = function(game_object)
                local gameplay_entity = game_object.gameplay_entity
                iconstruct_button.show(gameplay_entity.x, gameplay_entity.y, prototype.get_area(gameplay_entity.prototype_name))
            end
        })
        if prototype.is_fluidbox(prototype_name) then
            world:pub {"ui_message", "show_set_fluidbox", true}
        end
    end

    for _, game_object_eid, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        drapdrop_entity(game_object_eid, mouse_x, mouse_y)
    end
end

function construct_sys:data_changed()
    for _ in ui_construct_begin_mb:unpack() do
        print("construct begin")
    end

    for _, button in construct_button_mb:unpack() do
        local func = construct_button_events[button]
        if func then
            func()
        end
    end

    for _ in ui_construct_complete_mb:unpack() do
        local adjust = {}
        local game_object = ecswrap.singleton("construct_pickup", "construct_pickup")
        if game_object then
            local obj = get_object(game_object)
            adjust[#adjust+1] = {obj.x, obj.y}

            igame_object.remove(game_object.id)
        end
        iconstruct_button.hide()

        -- 还原未施工的水管形状
        for _, v in ipairs(adjust) do
            adjust_neighbor_pipe(v)
        end

        for _, v in ipairs(construct_queue) do
            if v.oper == "add" then
                local gameplay_entity = v.game_object.gameplay_entity
                adjust_neighbor_pipe({gameplay_entity.x, gameplay_entity.y})

                igame_object.set_state(v.game_object, "opaque")
                v.game_object.gameplay_eid = gameplay.create_entity(v.game_object)
                v.game_object.gameplay_entity = {}
            end
        end
        construct_queue = {}
        gameplay.build()
    end

    for _, _, _, fluidname in ui_fluidbox_update_mb:unpack() do
        local game_object = ecswrap.singleton("construct_pickup", "construct_pickup")
        if game_object then
            game_object.gameplay_entity.fluid = {fluidname, 0}
        end
    end
end
