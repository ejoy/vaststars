local ecs = ...
local world = ecs.world
local w = world.w

local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iconstruct_button = ecs.import.interface "vaststars.gamerender|iconstruct_button"
local construct_sys = ecs.system "construct_system"
local prototype = ecs.require "prototype"
local dir = require "dir"
local gameplay = ecs.require "gameplay"
local dir_rotate = dir.rotate
local world_select = ecs.require "world_select"
local pipe = ecs.require "pipe"

local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"}       -- 建造模式
local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工
local ui_fluidbox_construct_mb = world:sub {"ui", "construct", "fluidbox_construct"}
local ui_fluidbox_update_mb = world:sub {"ui", "construct", "fluidbox_update"}
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local construct_button_mb = world:sub {"construct_button"}
local game_object_ready_mb = world:sub {"game_object_ready"}

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
    local construct_object = game_object.construct_object
    local basecolor_factor

    local x, y = igame_object.get_coord(game_object)
    if not check_construct_detector(construct_object.prototype_name, x, y, construct_object.dir) then
        basecolor_factor = CONSTRUCT_RED_BASIC_COLOR
    else
        basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
    end

    igame_object.set_state(game_object, "translucent", basecolor_factor)
end

local function confirm_construct(game_object)
    local construct_object = game_object.construct_object
    local construct_detector = prototype.get_construct_detector(construct_object.prototype_name)
    if construct_detector then
        local x, y = igame_object.get_coord(game_object)
        if not check_construct_detector(construct_object.prototype_name, x, y, construct_object.dir) then
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

local function get_entity(x, y)
    for _, game_object in world_select "gameplay_eid" do
        if not ((game_object.x == x and game_object.y == y) or (game_object.construct_object.x == x and game_object.construct_object.y == y)) then
            goto continue
        end

        if game_object.gameplay_eid == 0 then
            return game_object
        else
            return gameplay.get_entity(game_object.gameplay_eid)
        end
        ::continue::
    end
end

local function drapdrop_entity(game_object_eid, mouse_x, mouse_y)
    local game_object = world:entity(game_object_eid)
    if not game_object then
        log.error(("can not found game_object `%s`"):format(game_object_eid))
        return
    end
    assert(game_object.construct_pickup == true)

    local construct_object = game_object.construct_object
    local x, y = igame_object.drapdrop(game_object, construct_object.prototype_name, mouse_x, mouse_y)
    if not x or not y then
        log.error(("can not get coord(%s, %s)"):format(mouse_x, mouse_y))
        return
    end

    if prototype.is_pipe(construct_object.prototype_name) then
        local prototype_name = pipe.get_prototype_name(x, y, get_entity)
        if prototype_name ~= construct_object.prototype_name then
            construct_object.prototype_name = prototype_name
            igame_object.set_prototype_name(prototype_name)
        end
    end

    local area = prototype.get_area(construct_object.prototype_name)
    if not area then
        return
    end

    construct_object.x, construct_object.y = x, y
    update_basecolor_by_pos(game_object)
    iconstruct_button.show(construct_object.x, construct_object.y, area)
end

local construct_button_events = {}
construct_button_events.confirm = function()
    for _, game_object in world_select "construct_pickup" do
        if prototype.is_fluidbox(game_object.construct_object.prototype_name) then
            world:pub {"ui_message", "show_set_fluidbox", true}
        else
            confirm_construct(game_object)
        end
    end
end

construct_button_events.cancel = function()
    for _, game_object in world_select "construct_pickup" do
        iconstruct_button.hide()
        igame_object.remove(game_object.id)
    end
end

construct_button_events.rotate = function()
    for _, game_object in world_select "construct_pickup" do
        local dir = dir_rotate(game_object.construct_object.dir, -1) -- 逆时针方向旋转一次
        game_object.construct_object.dir = dir
        igame_object.set_dir(game_object, dir)
    end
end

function construct_sys:camera_usage()
    for _, _, _, prototype_name in ui_construct_entity_mb:unpack() do
        igame_object.create(prototype_name)
    end

    for _, game_object_eid, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        drapdrop_entity(game_object_eid, mouse_x, mouse_y)
    end
end

function construct_sys:data_changed()
    for _, game_object_eid in game_object_ready_mb:unpack() do
        local game_object = world:entity(game_object_eid)
        -- 只有选中状态 并且 非水管 才需要显示[建造按钮]
        if game_object and game_object.construct_pickup then
            iconstruct_button.show(game_object.construct_object.x, game_object.construct_object.y, prototype.get_area(game_object.construct_object.prototype_name))
        end
    end

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
        for _, v in ipairs(construct_queue) do
            if v.oper == "add" then
                local game_object = v.game_object
                igame_object.set_state(game_object, "opaque")
                game_object.gameplay_eid = gameplay.create_entity(game_object)
            end
        end
        gameplay.build()
    end

    for _, _, _, fluidname in ui_fluidbox_construct_mb:unpack() do
        for _, game_object in world_select "construct_pickup" do
            game_object.construct_object.fluid = {fluidname, 0}
            confirm_construct(game_object)
        end
    end

    for _, _, _, confirm, fluidname in ui_fluidbox_update_mb:unpack() do
        if confirm == "confirm" then
            for _, game_object in world_select "fluidbox_selected" do
                for v in gameplay.select "entity:in fluidbox:out" do
                    if v.entity.x == game_object.x and v.entity.y == game_object.y then
                        v.fluidbox.fluid = prototype.get_fluid_id(fluidname)
                        v.fluidbox.id = 0
                    end
                end
            end
            gameplay.build()
        end
        world:pub {"ui_message", "show_set_fluidbox", false}
    end
end
