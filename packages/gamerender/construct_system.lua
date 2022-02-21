local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"
local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"
local iinput = ecs.import.interface "vaststars.input|iinput"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local icamera = ecs.import.interface "ant.camera|icamera"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iui = ecs.import.interface "vaststars.ui|iui"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local iroad = ecs.import.interface "vaststars.gamerender|iroad"
local ipipe = ecs.import.interface "vaststars.gamerender|ipipe"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"

local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local entities_cfg = import_package "vaststars.config".entity
local backers_cfg = import_package "vaststars.config".backers
local fluid_list_cfg = import_package "vaststars.config".fluid_list
local utility = import_package "vaststars.utility"
local dir_rotate = utility.dir.rotate
local dir_offset_of_entry = utility.dir.offset_of_entry

local CONSTRUCT_RED_BASIC_COLOR <const> = {50.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}

local ui_construct_building_mb = world:sub {"ui", "construct", "click_construct"}
local ui_remove_message_mb = world:sub {"ui", "construct", "click_construct_remove"}
local ui_get_fluid_catagory = world:sub {"ui", "GET_DATA", "fluid_catagory"}
local pickup_show_ui_mb = world:sub {"pickup_mapping", "pickup_show_ui"}
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local construct_sys = ecs.system "construct_system"
local pickup_mapping_canvas_mb = world:sub {"pickup_mapping", "canvas"}
local pickup_mb = world:sub {"pickup"}

local get_fluid_catagory; do
    local function is_type(prototype, t)
        for _, v in ipairs(prototype.type) do
            if v == t then
                return true
            end
        end
        return false
    end

    local t = {}
    for _, v in pairs(igameplay_adapter.prototype_name()) do
        if is_type(v, 'fluid') then
            for _, c in ipairs(v.catagory) do
                t[c] = t[c] or {}
                t[c][#t[c]+1] = {id = v.id, name = v.name, icon = v.icon}
            end
        end
    end

    local r = {}
    for catagory, v in pairs(t) do
        r[#r+1] = {catagory = catagory, icon = fluid_list_cfg[catagory].icon, pos = fluid_list_cfg[catagory].pos, fluid = v}
        table.sort(v, function(a, b) return a.id < b.id end)
    end
    table.sort(r, function(a, b) return a.pos < b.pos end)

    -- = {{catagory = xxx, icon = xxx, fluid = {{id = xxx, name = xxx, icon = xxx}, ...} }, ...}
    function get_fluid_catagory()
        return r
    end
end

local check_construct_detector; do
    local base_path = fs.path('/pkg/vaststars.gamerender/construct_detector/')
    local construct_detectors = {}
    for f in fs.pairs(base_path) do
        local detector = fs.relative(f, base_path):stem():string()
        construct_detectors[detector] = ecs.require(('construct_detector.%s'):format(detector))
    end

    function check_construct_detector(detectors, position, dir, area)
        local func
        for _, v in ipairs(detectors) do
            func = construct_detectors[v]
            if not func(position, dir, area) then
                return false
            end
        end
        return true
    end
end

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

local function __update_basecolor_by_pos(game_object)
    w:sync("construct_detector:in dir:in prototype:in", game_object)

    local basecolor_factor
    local prefab = igame_object.get_prefab(game_object)
    local position = math3d.tovalue(iom.get_position(prefab.root))

    if game_object.construct_detector then
        local entity = igameplay_adapter.query("entity", game_object.prototype)
        if not check_construct_detector(game_object.construct_detector, position, game_object.dir, entity.area) then
            basecolor_factor = CONSTRUCT_RED_BASIC_COLOR
        else
            basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
        end
    else
        basecolor_factor = CONSTRUCT_GREEN_BASIC_COLOR
    end

    for _, e in ipairs(prefab.tag["*"]) do
        w:sync("material?in", e)
        if e.material then
            imaterial.set_property(e, "u_basecolor_factor", basecolor_factor)
        end
    end
end

local construct_button_canvas_items = {}
local show_construct_button, hide_construct_button; do
    local coord_offset = {
        {
            name = "confirm.png",
            coord = {-1, 1},
            event = function()
                local prefab_object
                for game_object in w:select "construct_entity:in" do
                    prefab_object = igame_object.get_prefab_object(game_object)
                    prefab_object:send("confirm_construct")
                end
            end
        },
        {
            name = "cancel.png",
            coord = {1,  1},
            event = function()
                local prefab_object
                for game_object in w:select "construct_entity:in" do
                    hide_construct_button()
                    prefab_object = igame_object.get_prefab_object(game_object)
                    prefab_object:remove()
                end
            end,
        },
        {
            name = "rotate.png",
            coord = {0,  -1},
            event = function()
                local prefab_object
                for game_object in w:select "construct_entity:in dir:in" do
                    game_object.dir = dir_rotate(game_object.dir, -1)
                    w:sync("dir:out", game_object)
                    prefab_object = igame_object.get_prefab_object(game_object)
                    local rotation = iom.get_rotation(prefab_object.root)
                    local deg = math.deg(math3d.tovalue(math3d.quat2euler(rotation))[2])
                    iom.set_rotation(prefab_object.root, math3d.quaternion{axis=mc.YAXIS, r=math.rad(deg - 90)})
                    __update_basecolor_by_pos(game_object)
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

    function show_construct_button(x, y)
        hide_construct_button()

        for _, v in ipairs(coord_offset) do
            local cx = x + v.coord[1]
            local cy = y + v.coord[2]
            local pcoord = igameplay_adapter.pack_coord(cx, cy)
            local id = icanvas.add_items(v.name, cx, cy)
            construct_button_canvas_items[pcoord] = {id = id, event = v.event}
        end
    end
end

local on_prefab_ready; do
    function on_prefab_ready(game_object, prefab)
        local position = math3d.tovalue(iom.get_position(prefab.root))
        __update_basecolor_by_pos(game_object)
        local coord = iterrain.get_coord_by_position(position)
        show_construct_button(coord[1], coord[2])
    end
end

local on_prefab_message ; do
    local funcs = {}
    funcs["basecolor"] = function(game_object)
        __update_basecolor_by_pos(game_object)
    end

    funcs["confirm_construct"] = function(game_object, prefab)
        local position = math3d.tovalue(iom.get_position(prefab.root))
        local srt = prefab.root.scene.srt

        w:sync("construct_detector?in dir:in x:in y:in area:in", game_object)
        if game_object.construct_detector then
            local entity = igameplay_adapter.query("entity", game_object.prototype)
            if not check_construct_detector(game_object.construct_detector, position, game_object.dir, entity.area) then
                print("can not construct") -- todo error tips
                return
            end
        end

        -- create entity
        w:sync("construct_road?in construct_pipe?in dir:in construct_prefab:in construct_entity:in", game_object)

        if game_object.construct_road then
            iroad.construct(nil, {game_object.x, game_object.y})
        elseif game_object.construct_pipe then
            ipipe.construct(nil, {game_object.x, game_object.y}, game_object.dir)
        else
            local new_prefab = ecs.create_instance(("/pkg/vaststars.resources/%s"):format(game_object.construct_prefab))
            iom.set_srt(new_prefab.root, srt.s, srt.r, srt.t)
            local template = {
                policy = {},
                data = {
                    prototype = game_object.prototype,
                    pause_animation = true,
                    x = game_object.x,
                    y = game_object.y,
                    dir = game_object.dir,
                    area = igameplay_adapter.query("entity", game_object.prototype).area,
                }
            }

            for k, v in pairs(game_object.construct_entity) do
                template.data[k] = v
            end

            new_prefab.on_ready = function(game_object, prefab)
                w:sync("prototype:in x:in y:in dir:in", game_object)
                local gameplay_entity = {
                    x = game_object.x,
                    y = game_object.y,
                    dir = game_object.dir,
                }

                w:sync("station?in", game_object)
                if game_object.station then
                    w:sync("scene:in", prefab.root)
                    gameplay_entity.station = {
                        id = prefab.root.scene.id,
                        coord = igameplay_adapter.pack_coord(game_object.x, game_object.y), -- todo
                    }
                end

                igameplay_adapter.create_entity(game_object.prototype, gameplay_entity)
            end
            iprefab_object.create(new_prefab, template)
        end

        -- remove construct entity
        hide_construct_button()
        prefab:remove()
    end

    function on_prefab_message(game_object, prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(game_object, prefab, ...)
        end
    end
end

function construct_sys:entity_init()
    --
	for e in w:select "INIT x:in y:in area:in prototype:in construct_entity?in" do
        if not e.construct_entity then
            iterrain.set_tile_building_type({e.x, e.y}, e.prototype, e.area)
        end
    end

    --
    for e in w:select "INIT set_road_entry:in x:in y:in dir:in area:in" do
        local offset = dir_offset_of_entry(e.dir)
        local width, heigh = igameplay_adapter.unpack_coord(e.area)
        local coord = {
            e.x + offset[1] + (offset[1] * (width // 2)),
            e.y + offset[2] + (offset[2] * (heigh // 2)),
        }

        iroad.set_building_entry(coord, e.dir)
    end
    w:clear "set_road_entry"

    --
    for e in w:select "INIT random_name:in name:out" do
        e.name = backers_cfg[math.random(1, #backers_cfg)]
    end
end

function construct_sys:camera_usage()
    local coord, position
    for _, game_object, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        w:sync("area:in x:in y:in", game_object)

        local prefab_object = igame_object.get_prefab_object(game_object)
        position = iinput.screen_to_world {mouse_x, mouse_y}
        coord, position = iterrain.adjust_building_position(math3d.tovalue(position), game_object.area)

        game_object.x = coord[1]
        game_object.y = coord[2]
        w:sync("x:out y:out", game_object)

        iom.set_position(prefab_object.root, position)
        show_construct_button(coord[1], coord[2])
        prefab_object:send("basecolor")
    end
end

function construct_sys:data_changed()
    local cfg
    for _, _, _, prototype in ui_construct_building_mb:unpack() do
        cfg = entities_cfg[prototype]
        if cfg then
            for game_object in w:select "construct_entity:in" do
                igame_object.get_prefab_object(game_object):remove()
            end

            local f = ("/pkg/vaststars.resources/%s"):format(cfg.prefab)
            local template = replace_material(serialize.parse(f, cr.read_file(f)))
            local prefab = ecs.create_instance(template)

            local gpentity = igameplay_adapter.query("entity", prototype)
            local coord, position = iterrain.adjust_building_position({0, 0, 0}, gpentity.area) -- todo 可能需要根据屏幕中间位置来设置?
            iom.set_position(prefab.root, position)

            local t = {
                policy = {},
                data = {
                    prototype = prototype,
                    drapdrop = false,
                    construct_entity = cfg.component,
                    pause_animation = true,
                    dir = 'N',
                    x = coord[1],
                    y = coord[2],
                    construct_prefab = cfg.prefab,
                    area = gpentity.area,
                },
            }

            for k, v in pairs(cfg.construct_component) do
                t.data[k] = v
            end

            prefab.on_message = on_prefab_message
            prefab.on_ready = on_prefab_ready
            iprefab_object.create(prefab, t)
        else
            print(("Can not found prototype `%s`"):format(prototype))
        end
    end

    for _ in ui_remove_message_mb:unpack() do
        for game_object in w:select("pickup_show_remove:in pickup_show_set_road_arrow?in pickup_show_set_pipe_arrow?in x:in y:in area:in") do
            if game_object and game_object.pickup_show_remove and not game_object.pickup_show_set_road_arrow and not game_object.pickup_show_set_pipe_arrow then
                igame_object.get_prefab_object(game_object):remove()
                iterrain.set_tile_building_type({game_object.x, game_object.y}, nil, game_object.area)
                igameplay_adapter.remove_entity(game_object.x, game_object.y)
                world:pub {"ui_message", "construct_show_remove", nil}
            end
        end
    end

    for _ in ui_get_fluid_catagory:unpack() do
        world:pub {"ui_message", "SET_DATA", {["fluid_catagory"] = get_fluid_catagory()}}
    end
end

function construct_sys:after_pickup_mapping()
    local url
    for _, _, entity in pickup_show_ui_mb:unpack() do
        w:sync("pickup_show_ui:in", entity)
        url = entity.pickup_show_ui.url
        iui.open(url)
    end

    local show = true
    for _ in pickup_mapping_canvas_mb:unpack() do
        local pos = iinput.get_mouse_world_position()
        local coord = iterrain.get_coord_by_position(pos)
        local k = igameplay_adapter.pack_coord(coord[1], coord[2])
        local v = construct_button_canvas_items[k]
        if v then
            v.event()
            show = true
        end
    end

    for _ in pickup_mb:unpack() do
        if not show then
            hide_construct_button()
        end
        break
    end
end
