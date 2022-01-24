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

local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local construct_cfg = import_package "vaststars.config".construct
local backers_cfg = import_package "vaststars.config".backers
local CONSTRUCT_RED_BASIC_COLOR <const> = {50.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}

local ui_construct_building_mb = world:sub {"ui", "construct", "click_construct"}
local ui_construct_confirm_mb = world:sub {"ui", "construct", "click_construct_confirm"}
local ui_construct_cancel_mb = world:sub {"ui", "construct", "click_construct_cancel"}
local ui_construct_rotate_mb = world:sub {"ui", "construct", "click_construct_rotate"}
local ui_remove_message_mb = world:sub {"ui", "construct", "click_construct_remove"}

local pickup_show_remove_mb = world:sub {"pickup_mapping", "pickup_show_remove"}
local pickup_show_ui_mb = world:sub {"pickup_mapping", "pickup_show_ui"}
local pickup_mb = world:sub {"pickup"}
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local construct_sys = ecs.system "construct_system"

local base_path = fs.path('/pkg/vaststars.gamerender/construct_detector/')
local construct_detectors = {}
for f in fs.pairs(base_path) do
    local detector = fs.relative(f, base_path):stem():string()
    construct_detectors[detector] = ecs.require(('construct_detector.%s'):format(detector))
end

local function get_construct_entity(entity)
    w:sync("construct_entity:in", entity)
    return entity.construct_entity
end

local function __replace_material(template)
    for _, v in ipairs(template) do
        for _, policy in ipairs(v.policy) do
            if policy == "ant.render|render" or policy == "ant.render|simplerender" then
                v.data.material = "/pkg/vaststars.resources/construct.material"
            end
        end
    end

    return template
end

local function __update_basecolor_by_pos(game_object, prefab, position)
    local basecolor_factor
    local construct_entity = get_construct_entity(game_object)

    if construct_entity.detector then
        local func = construct_detectors[construct_entity.detector]
        if not func(construct_entity.building_type, position, construct_entity.entity.data.building.area) then
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

local function on_prefab_ready(game_object, prefab)
    local position = math3d.tovalue(iom.get_position(prefab.root))
    __update_basecolor_by_pos(game_object, prefab, position)
    local coord1, coord2, coord3 = iterrain.get_confirm_ui_position(position)
    world:pub {"ui_message", "construct_show_confirm", true, math3d.tovalue(icamera.world_to_screen(coord1)), math3d.tovalue(icamera.world_to_screen(coord2)), math3d.tovalue(icamera.world_to_screen(coord3)) }
end

local function deep_copy(src, dst)
    dst = dst or {}
    for k, v in pairs(src) do
        local t = type(v)
        if t == "table" then
            dst[k] = {}
            deep_copy(v, dst[k])
        else
            assert(t ~= "function")
            dst[k] = v
        end
    end
    return dst
end

local on_prefab_message ; do
    local funcs = {}
    funcs["basecolor"] = function(game_object, prefab, position)
        __update_basecolor_by_pos(game_object, prefab, position)
    end

    funcs["confirm_construct"] = function(game_object, prefab)
        local construct_entity = get_construct_entity(game_object)
        local position = math3d.tovalue(iom.get_position(prefab.root))
        local srt = prefab.root.scene.srt

        if construct_entity.detector then
            local func = construct_detectors[construct_entity.detector]
            if not func(construct_entity.building_type, position, construct_entity.entity.data.building.area) then
                print("can not construct") -- todo error tips
                return
            end
        end

        -- create entity
        local tile_coord = iterrain.get_coord_by_position(position)
        if construct_entity.entity.data.building.building_type == "road" then -- todo road
            iroad.construct(nil, tile_coord)
        elseif construct_entity.entity.data.building.building_type == "pipe" then
            ipipe.construct(nil, tile_coord)
        else
            local new_prefab = ecs.create_instance(("/pkg/vaststars.resources/%s"):format(construct_entity.prefab))
            iom.set_srt(new_prefab.root, srt.s, srt.r, srt.t)
            local template = deep_copy(construct_entity.entity)
            template.data.building.tile_coord = tile_coord
            template.data.x = tile_coord[1]
            template.data.y = tile_coord[2]
            template.data.dir = 'N' -- todo

            new_prefab.on_ready = function(game_object, prefab)
                w:sync("building:in", game_object)
                print("building", tile_coord[1], tile_coord[2] + (-1 * (game_object.building.area[2] // 2)) - 1)

                if construct_entity.entity.data.building.building_type == "logistics_center" then
                    w:sync("building:in", game_object)
                    local function packCoord(x, y)
                        return x | (y<<8)
                    end

                    local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in")
                    if gameplay_adapter then
                        w:sync("scene:in", prefab.root)
                        gameplay_adapter.gameplay_world.ecs:new {
                            station = {
                                id = prefab.root.scene.id,
                                position = packCoord(tile_coord[1], tile_coord[2] + (-1 * (game_object.building.area[2] // 2)) - 1),
                            }
                        }
                    end
                end
            end
            iprefab_object.create(new_prefab, template)
        end

        -- remove construct entity
        world:pub {"ui_message", "construct_show_confirm", false}
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
	for e in w:select "INIT building:in" do
        iterrain.set_tile_building_type(e.building.tile_coord, e.building.building_type, e.building.area)
    end

    --
    for e in w:select "INIT set_road_entry_during_init:in building:in" do
        local tile_coord = e.building.tile_coord
        local coord = {
            tile_coord[1],
            (tile_coord[2] - e.building.area[2] // 2),
        }
        iroad.set_building_entry(coord)
    end
    w:clear "set_road_entry_during_init"

    --
    for e in w:select "INIT named:in name:out" do
        e.name = backers_cfg[math.random(1, #backers_cfg)]
    end
end

function construct_sys:camera_usage()
    local position
    for _, game_object, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        w:sync("construct_entity?in", game_object)
        if game_object.construct_entity then
            local prefab_object = igame_object.get_prefab_object(game_object)
            position = iinput.screen_to_world {mouse_x, mouse_y}
            position = iterrain.get_tile_centre_position(math3d.tovalue(position))
            iom.set_position(prefab_object.root, position)
            local coord1, coord2, coord3 = iterrain.get_confirm_ui_position(position)
            world:pub {"ui_message", "construct_show_confirm", true, math3d.tovalue(icamera.world_to_screen(coord1)), math3d.tovalue(icamera.world_to_screen(coord2)), math3d.tovalue(icamera.world_to_screen(coord3)) }
            prefab_object:send("basecolor", position)
        end
    end
end

function construct_sys:data_changed()
    local cfg
    for _, _, _, building_type in ui_construct_building_mb:unpack() do
        cfg = construct_cfg[building_type]
        if cfg then
            for game_object in w:select "construct_entity:in" do
                igame_object.get_prefab_object(game_object):remove()
            end

            local f = ("/pkg/vaststars.resources/%s"):format(cfg.construct_prefab)
            local template = __replace_material(serialize.parse(f, cr.read_file(f)))
            local prefab = ecs.create_instance(template)
            iom.set_position(prefab.root, iterrain.get_tile_centre_position({0, 0, 0})) -- todo 可能需要根据屏幕中间位置来设置?

            prefab.on_message = on_prefab_message
            prefab.on_ready = on_prefab_ready
            iprefab_object.create(prefab, cfg.construct_entity)
        else
            print(("Can not found building_type `%s`"):format(building_type))
        end
    end

    local prefab_object
    for _, _, _ in ui_construct_confirm_mb:unpack() do
        for game_object in w:select "construct_entity:in" do
            prefab_object = igame_object.get_prefab_object(game_object)
            prefab_object:send("confirm_construct")
        end
    end

    for _, _, _ in ui_construct_cancel_mb:unpack() do
        for game_object in w:select "construct_entity:in" do
            prefab_object = igame_object.get_prefab_object(game_object)
            world:pub {"ui_message", "construct_show_confirm", false}
            prefab_object:remove()
        end
    end

    for _, _, _ in ui_construct_rotate_mb:unpack() do
        for game_object in w:select "construct_entity:in" do
            prefab_object = igame_object.get_prefab_object(game_object)
            local rotation = iom.get_rotation(prefab_object.root)
            local deg = math.deg(math3d.tovalue(math3d.quat2euler(rotation))[2])
            iom.set_rotation(prefab_object.root, math3d.quaternion{axis=mc.YAXIS, r=math.rad(deg + 90)})
        end
    end

    for _ in ui_remove_message_mb:unpack() do
        for game_object in w:select("pickup_show_remove:in building:in pickup_show_set_road_arrow?in pickup_show_set_pipe_arrow?in x:in y:in") do
            if game_object and game_object.pickup_show_remove and not game_object.pickup_show_set_road_arrow and not game_object.pickup_show_set_pipe_arrow then
                igame_object.get_prefab_object(game_object):remove()
                iterrain.set_tile_building_type(game_object.building.tile_coord, nil, game_object.building.area)
            end
        end
    end
end

function construct_sys:after_pickup_mapping()
    local url
    for _, _, entity in pickup_show_ui_mb:unpack() do
        w:sync("pickup_show_ui:in", entity)
        url = entity.pickup_show_ui.url
        iui.open(url)
    end

    local show_pickup_show_remove
    for _, _, game_object in pickup_show_remove_mb:unpack() do
        w:sync("x:in y:in pickup_show_remove:in ", game_object)
        local pos = iterrain.get_begin_position_by_coord(game_object.x, game_object.y)
        world:pub {"ui_message", "construct_show_remove", math3d.tovalue(icamera.world_to_screen(pos))}
        game_object.pickup_show_remove = true
        w:sync("pickup_show_remove:out", game_object)
        show_pickup_show_remove = true
    end

    for _ in pickup_mb:unpack() do
        if not show_pickup_show_remove then
            for e in w:select("pickup_show_remove:update") do
                e.pickup_show_remove = false
            end

            world:pub {"ui_message", "construct_show_remove", nil}
            break
        end
    end
end

local iconstruct = ecs.interface "iconstruct"
function iconstruct.init()
    iterrain.create()
end
