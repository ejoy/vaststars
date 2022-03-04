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
local vector2 = require "vector2"
local math3d = require "math3d"
local dir = require "dir"
local gameplay = ecs.require "gameplay"
local dir_rotate = dir.rotate
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local iinput = ecs.import.interface "vaststars.gamerender|iinput"
local irq = ecs.import.interface "ant.render|irenderqueue"
local world_select = ecs.require "world_select"

local ui_construct_begin_mb = world:sub {"ui", "construct", "construct_begin"}       -- 建造模式
local ui_construct_entity_mb = world:sub {"ui", "construct", "construct_entity"}
local ui_construct_complete_mb = world:sub {"ui", "construct", "construct_complete"} -- 开始施工
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local pickup_mapping_canvas_mb = world:sub {"pickup_mapping", "canvas"}
local ui_fluidbox_construct_mb = world:sub {"ui", "construct", "fluidbox_construct"}
local ui_fluidbox_update_mb = world:sub {"ui", "construct", "fluidbox_update"}

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
    local construct_object = game_object.construct_object
    local basecolor_factor
    local prefab_object = igame_object.get_prefab_object(game_object.id)
    local position = math3d.tovalue(iom.get_position(world:entity(prefab_object.root)))
    local construct_detector = get_construct_detector(construct_object.prototype_name)

    if construct_detector then
        local area = prototype.get_area(construct_object.prototype_name)
        if not area then
            return
        end

        local coord = terrain.get_coord_by_position(position)
        if not check_construct_detector(construct_detector, coord[1], coord[2], construct_object.dir, area) then
            basecolor_factor = CONSTRUCT_RED_BASIC_COLOR
        else
            basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
        end
    else
        basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
    end
    prefab_object:send("update_basecolor", basecolor_factor)
end

local confirm_construct
local construct_button_canvas_items = {}
local show_construct_button, hide_construct_button; do
    local UP_LEFT <const> = vector2.UP_LEFT
    local UP_RIGHT <const> = vector2.UP_RIGHT
    local DOWN <const> = vector2.DOWN
    local RIGHT <const> = vector2.RIGHT

    local coord_offset = {
        {
            name = "confirm.png",
            coord_func = function(x, y, area)
                return x + UP_LEFT[1], y + UP_LEFT[2]
            end,
            event = function()
                for _, game_object in world_select "construct_pickup" do
                    if prototype.is_fluidbox(game_object.construct_object.prototype_name) then
                        world:pub {"ui_message", "show_set_fluidbox", true}
                    else
                        confirm_construct(game_object)
                    end
                end
            end
        },
        {
            name = "cancel.png",
            coord_func = function(x, y, area)
                local width = prototype.unpack_coord(area)
                return x + UP_RIGHT[1] * width, y + UP_RIGHT[2]
            end,
            event = function()
                for _, game_object in world_select "construct_pickup" do
                    hide_construct_button()
                    igame_object.remove(game_object.id)
                end
            end,
        },
        {
            name = "rotate.png",
            coord_func = function(x, y, area)
                local dx, dy
                local width, height = prototype.unpack_coord(area)
                -- 针对建筑宽度大于 1 的特殊处理
                if width > 1 then
                    if width % 2 == 0 then
                        x = x + RIGHT[1] * ((width - 1) // 2)
                        y = y + DOWN[2] * height
                        dx = x + RIGHT[1]
                        dy = y + DOWN[2] * height
                        return x, y, dx, dy
                    else
                        dx = x + RIGHT[1] * (width // 2)
                        dy = y + DOWN[2] * height
                        return dx, dy
                    end
                else
                    return x + DOWN[1], y + DOWN[2]
                end
            end,
            event = function()
                local prefab_object
                for _, game_object in world_select "construct_pickup" do
                    game_object.construct_object.dir = dir_rotate(game_object.construct_object.dir, -1)
                    prefab_object = igame_object.get_prefab_object(game_object.id)

                    local re = world:entity(prefab_object.root)
                    local rotation = iom.get_rotation(re)
                    local deg = math.deg(math3d.tovalue(math3d.quat2euler(rotation))[2])
                    iom.set_rotation(re, math3d.quaternion{axis=mc.YAXIS, r=math.rad(deg - 90)})
                    update_basecolor_by_pos(game_object)
                end
            end,
        },
    }

    function hide_construct_button()
        for _, v in pairs(construct_button_canvas_items) do
            icanvas.remove_item(v.id)
        end
        construct_button_canvas_items = {}
    end

    function show_construct_button(x, y, area)
        hide_construct_button()

        for _, v in ipairs(coord_offset) do
            local cx, cy, dx, dy = v.coord_func(x, y, area)
            if not terrain.verify_coord(cx, cy) then
                goto continue
            end

            local pcoord = prototype.pack_coord(cx, cy)
            local id
            if dx and dy then
                id = icanvas.add_items(v.name, cx, cy, {t = {5, 0}})
            else
                id = icanvas.add_items(v.name, cx, cy)
            end
            construct_button_canvas_items[pcoord] = {id = id, event = v.event}

            if dx and dy then
                local pcoord = prototype.pack_coord(dx, dy)
                construct_button_canvas_items[pcoord] = {id = id, event = v.event}
            end
            ::continue::
        end
    end
end

function confirm_construct(game_object)
    local prefab_object = igame_object.get_prefab_object(game_object.id)
    if not prefab_object then
        log.error(("can not found prefab_object `%s`"):format(game_object.id))
        return
    end

    local construct_object = game_object.construct_object
    if construct_object.construct_detector then
        local position = math3d.tovalue(iom.get_position(world:entity(prefab_object.root)))
        local coord = terrain.get_coord_by_position(position)
        local area = prototype.get_area(construct_object.prototype_name)
        if not check_construct_detector(construct_object.construct_detector, coord[1], coord[2], construct_object.dir, area) then
            print("can not construct") -- todo error tips
            return
        end
    end

    prefab_object:send("update_basecolor", CONSTRUCT_WHITE_BASIC_COLOR)

    game_object.construct_pickup = false
    game_object.construct_queue = true
    game_object.drapdrop = false
    hide_construct_button()
end

--
local function on_prefab_ready(game_object)
    local area = prototype.get_area(game_object.construct_object.prototype_name)
    if not area then
        return
    end
    update_basecolor_by_pos(game_object)
    show_construct_button(game_object.construct_object.x, game_object.construct_object.y, area)
end

local on_prefab_message ; do
    local funcs = {}
    funcs["update_basecolor"] = function(game_object, prefab, basecolor_factor)
        update_basecolor(prefab, basecolor_factor)
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

    for _, game_object in world_select "construct_pickup" do
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
    prefab.on_ready = on_prefab_ready

    local viewdir = iom.get_direction(world:entity(irq.main_camera()))
    local origin = math3d.tovalue(iinput.ray_hit_plane({origin = mc.ZERO, dir = math3d.mul(math.maxinteger, viewdir)}, {dir = mc.YAXIS, pos = mc.ZERO_PT}))
    local coord, position = terrain.adjust_position(origin, area)
    iom.set_position(world:entity(prefab.root), position)

    local game_object_eid = ecs.create_entity {
        policy = {},
        data = {
            drapdrop = true,
            pause_animation = true,
            construct_pickup = true,
            construct_object = {
                prototype_name = prototype_name,
                fluid = {},
                dir = "N",
                x = coord[1],
                y = coord[2],
            },
            pickup_mapping = {
                ["drapdrop"] = true,
                ["construct_pickup"] = true,
            },
        }
    }
    igame_object.bind(game_object_eid, prefab)
end

local function drapdrop_entity(game_object_eid, mouse_x, mouse_y)
    local game_object = world:entity(game_object_eid)
    if not game_object then
        log.error(("can not found game_object `%s`"):format(game_object_eid))
        return
    end

    if not game_object.construct_pickup then
        return
    end

    local prefab_object = igame_object.get_prefab_object(game_object_eid)
    if not prefab_object then
        log.error(("can not found prefab_object `%s`"):format(game_object_eid))
        return
    end

    local construct_object = game_object.construct_object
    local area = prototype.get_area(construct_object.prototype_name)
    if not area then
        return
    end

    local coord, position = terrain.adjust_position(iinput.screen_to_world(mouse_x, mouse_y), area)
    if not coord then
        return
    end

    construct_object.x = coord[1]
    construct_object.y = coord[2]

    iom.set_position(world:entity(prefab_object.root), position)
    update_basecolor_by_pos(game_object)
    show_construct_button(construct_object.x, construct_object.y, area)
end

local function construct_complete(game_object)
    local prefab_file = prototype.get_prefab_file(game_object.construct_object.prototype_name)
    if not prefab_file then
        return
    end

    local old_prefab_object = igame_object.get_prefab_object(game_object.id)
    if not old_prefab_object then
        return
    end
    local position = iom.get_position(world:entity(old_prefab_object.root))

    local prefab = ecs.create_instance(("/pkg/vaststars.resources/%s"):format(prefab_file))
    iom.set_position(world:entity(prefab.root), position)
    igame_object.bind(game_object.id, prefab)
    gameplay.create_entity(game_object)
end

function construct_sys:data_changed()
    for _ in ui_construct_begin_mb:unpack() do
        print("construct begin")
    end

    for _ in ui_construct_complete_mb:unpack() do
        for _, game_object in world_select "construct_queue" do
            construct_complete(game_object)
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

function construct_sys:camera_usage()
    for _, _, _, prototype_name in ui_construct_entity_mb:unpack() do
        construct_entity(prototype_name)
    end

    for _, game_object_eid, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        drapdrop_entity(game_object_eid, mouse_x, mouse_y)
    end
end

function construct_sys:pickup_mapping()
    for _ in pickup_mapping_canvas_mb:unpack() do
        local coord = terrain.get_coord_by_position(iinput.get_mouse_world_position())
        local k = prototype.pack_coord(coord[1], coord[2])
        local v = construct_button_canvas_items[k]
        if v then
            v.event()
        else
            log.error(("unknown canvas event (%s, %s)"):format(coord[1], coord[2]))
        end
    end
end
