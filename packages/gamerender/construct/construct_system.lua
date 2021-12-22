local ecs = ...
local world = ecs.world
local w = world.w

local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"
local iinput = ecs.import.interface "vaststars.input|iinput"
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local icamera = ecs.import.interface "ant.camera|icamera"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iui = ecs.import.interface "vaststars.ui|iui"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local iroad_arrow = ecs.import.interface "vaststars.gamerender|iroad_arrow"
local iroad = ecs.import.interface "vaststars.gamerender|iroad"
local iprefab_proxy = ecs.import.interface "vaststars.utility|iprefab_proxy"
local get_add_gameplay_entity_func = ecs.require "construct.gameplay_entity.get_func"
local gameplay = import_package "vaststars.gameplay"

local math3d = require "math3d"
local construct_cfg = import_package "vaststars.config".construct
local ROAD_YAXIS_DEFAULT <const> = import_package "vaststars.constant".ROAD_YAXIS_DEFAULT
local CONSTRUCT_RED_BASIC_COLOR <const> = {100.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 100.0, 0.0, 0.8}

local ui_construct_building_mb = world:sub {"ui", "construct.rml", "building"}
local ui_construct_confirm_mb = world:sub {"ui", "construct.rml", "confirm"}
local pickup_show_set_road_arrow_mb = world:sub {"pickup_mapping", "pickup_show_set_road_arrow"}
local pickup_set_road_mb = world:sub {"pickup_mapping", "pickup_set_road"}
local pickup_show_ui_mb = world:sub {"pickup_mapping", "pickup_show_ui"}

local pickup_mb = world:sub {"pickup"}
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local construct_sys = ecs.system "construct_system"

local construct_prefab -- assuming there is only one "construct entity" in the same time
local all_building = {} -- todo 移至 entity? = {[building_id] = tile_coord, ...} -- on the road

local __gen_building_id ; do
    local id = 0
    function __gen_building_id()
        id = id + 1
        return id
    end
end

local function __get_construct_entity(entity)
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

local function __update_basecolor_by_pos(entity, prefab, position) 
    local basecolor_factor
    local construct_entity = __get_construct_entity(entity)
    if construct_entity.detect and not construct_entity.detect(construct_entity.building_type, position) then
        basecolor_factor = CONSTRUCT_RED_BASIC_COLOR
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

local function on_prefab_ready(entity, prefab)
    local position = math3d.tovalue(iom.get_position(prefab.root))
    __update_basecolor_by_pos(entity, prefab, position)
    iui.post("construct.rml", "show_construct_confirm", true, math3d.tovalue(icamera.world_to_screen(position)) )
end

local on_prefab_message ; do
    local funcs = {}
    funcs["basecolor"] = function(entity, prefab, position)
        __update_basecolor_by_pos(entity, prefab, position)
    end

    funcs["confirm_construct"] = function(entity, prefab)
        local construct_entity = __get_construct_entity(entity)
        local position = math3d.tovalue(iom.get_position(prefab.root))
        local building_type = construct_entity.building_type
        local srt = prefab.root.scene.srt

        if construct_entity.detect then
            if not construct_entity.detect(building_type, position) then
                -- todo error tips
                print("can not construct")
                return
            end
        end

        local tile_coord = iterrain.get_coord_by_position(position)
        local add_gameplay_entity = get_add_gameplay_entity_func(building_type)
        local building_id = 0

        if building_type == "road" then -- todo bad taste
            iroad.construct(nil, tile_coord, "O0") -- add gameplay entity in road_system
        else
            building_id = __gen_building_id()
            local cfg = construct_cfg[building_type]

            local prefab_file_name = construct_entity.prefab_file_name
            local template = {
                policy = {
                    "vaststars.gamerender|building",
                    "vaststars.gamerender|pickup_show_ui",
                },
                data = {
                    building = {
                        id = building_id,
                        building_type = building_type,
                    },
                    pickup_mapping_tag = "pickup_show_ui",
                    pickup_show_ui = {url = cfg.ui_url},
                },
            }
            if cfg and cfg.tag then
                for _, tag in ipairs(cfg.tag) do
                    template.data[tag] = true
                end
            end
            iprefab_proxy.create(ecs.create_instance("/pkg/vaststars.resources/" .. prefab_file_name),
                {},
                template,
                {
                    on_ready = function(_, prefab)
                        iom.set_srt(prefab.root, srt.s, srt.r, srt.t)
                    end
                }
            )

            -- todo hard coded 此处需要根据建筑物的转向计算坐标
            if cfg then
                local coord = {
                    tile_coord[1],
                    (tile_coord[2] - cfg.size[2] // 2),
                }

                if building_type ~= "container" and building_type ~= "rock" then
                    iroad.set_building_entry(coord) -- todo 并非所有建筑都需要 set_building_entry
                end

                if add_gameplay_entity then
                    local gpcoord = {
                        tile_coord[1],
                        (tile_coord[2] - cfg.size[2] // 2 - 1),
                    }
                    gameplay.new(add_gameplay_entity(building_id, gpcoord))
                    all_building[building_id] = gpcoord
                end
            end
        end

        iterrain.set_tile_building_type(tile_coord, building_type)
        iui.post("construct.rml", "show_construct_confirm", false)
        prefab:send("remove")
        construct_prefab = nil
    end

    function on_prefab_message(entity, prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(entity, prefab, ...)
        end
    end
end

local function __create_construct_entity(building_type, prefab_file_name, detect)
    local f = "/pkg/vaststars.resources/" .. prefab_file_name
    local template = __replace_material(serialize.parse(f, cr.read_file(f)))

    return iprefab_proxy.create(ecs.create_instance(template),
    iprefab_proxy.get_config_srt(prefab_file_name),
        {
            policy = {
                "ant.scene|scene_object",
                "vaststars.gamerender|construct_entity",
                "vaststars.input|drapdrop",
            },
            data = {
                construct_entity = {
                    building_type = building_type,
                    prefab_file_name = prefab_file_name,
                    detect = detect,
                },
                drapdrop = false,
            },
        },
        {
            on_ready = on_prefab_ready,
            on_message = on_prefab_message,
        }
    )
end

----------------------------------
local show_road_arrow, hide_road_arrow ; do
    local road_arrow_prefab_proxys = {}
    local arrow_tile_coord_offset = {{0, -1}, {-1, 0}, {1, 0}, {0, 1}}
    local arrow_yaxis_rotation = {math.rad(180.0), math.rad(-90.0), math.rad(90.0), math.rad(0.0)}

    function hide_road_arrow(idx)
        if not idx then
            for idx, prefab_proxy in pairs(road_arrow_prefab_proxys) do
                iprefab_proxy.remove(prefab_proxy)
                road_arrow_prefab_proxys[idx] = nil
            end
        else
            local prefab_proxy = road_arrow_prefab_proxys[idx]
            if prefab_proxy then
                iprefab_proxy.remove(prefab_proxy)
                road_arrow_prefab_proxys[idx] = nil
            end
        end
    end

    function show_road_arrow(position)
        local tile_coord = iterrain.get_coord_by_position(position)
        local arrow_tile_coord

        for idx, coord_offset in ipairs(arrow_tile_coord_offset) do
            arrow_tile_coord = {
                tile_coord[1] + coord_offset[1],
                tile_coord[2] + coord_offset[2],
            }

            -- todo bad taste
            local tile_position = iterrain.get_position_by_coord(arrow_tile_coord)
            if not tile_position then
                hide_road_arrow(idx)
                goto continue
            end

            -- todo bad taste 此处不应该依赖于 building_type 的类型判断?
            local building_type = iterrain.get_tile_building_type(arrow_tile_coord)
            if building_type and building_type ~= "road" then
                hide_road_arrow(idx)
                goto continue
            end

            tile_position[2] = ROAD_YAXIS_DEFAULT
            local prefab_proxy = road_arrow_prefab_proxys[idx]
            if not prefab_proxy then
                road_arrow_prefab_proxys[idx] = iroad_arrow.create(tile_position, arrow_yaxis_rotation[idx], tile_coord, arrow_tile_coord)
            else
                iprefab_proxy.message(prefab_proxy, "set_arrow_tile_coord", arrow_tile_coord, tile_coord)
                iprefab_proxy.message(prefab_proxy, "set_position", tile_position)
            end
            ::continue::
        end
    end
end

function construct_sys:camera_usage()
    local position
    for _, e, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        w:sync("construct_entity?in", e)
        if e.construct_entity and construct_prefab then
            position = iinput.screen_to_world {mouse_x, mouse_y}
            position = iterrain.get_tile_centre_position(math3d.tovalue(position))
            iom.set_position(iprefab_proxy.get_root(e), position)
            iui.post("construct.rml", "show_construct_confirm", true, math3d.tovalue(icamera.world_to_screen(position)))
            iprefab_proxy.message(e, "basecolor", position) -- todo 此处可能会发送很多 basecolor 消息
        end
    end
end

function construct_sys:data_changed()
    local cfg
    for _, _, _, building_type in ui_construct_building_mb:unpack() do
        cfg = construct_cfg[building_type]
        if cfg then
            if construct_prefab then
                iprefab_proxy.message(construct_prefab, "remove")
            end

            local detect
            if cfg.detect then
                detect = ecs.require(("construct.detect.%s"):format(cfg.detect))
            end
            construct_prefab = __create_construct_entity(cfg.building_type, cfg.prefab_file_name, detect)
        end
    end

    for _, _, _ in ui_construct_confirm_mb:unpack() do
        if construct_prefab then
            iprefab_proxy.message(construct_prefab, "confirm_construct")
        end
    end
end

function construct_sys:after_pickup_mapping()
    local is_show_road_arrow
    for _, _, entity in pickup_show_set_road_arrow_mb:unpack() do
        show_road_arrow( iterrain.get_tile_centre_position(iinput.get_mouse_world_position()) )
        is_show_road_arrow = true
    end

    for _ in pickup_mb:unpack() do
        if not is_show_road_arrow then
            hide_road_arrow()
            break
        end
    end

    for _, _, entity in pickup_set_road_mb:unpack() do
        w:sync("pickup_set_road:in", entity)
        local arrow_tile_coord = entity.pickup_set_road.arrow_tile_coord
        iterrain.set_tile_building_type(arrow_tile_coord, "road")
        iroad.construct(entity.pickup_set_road.tile_coord, arrow_tile_coord) -- add gameplay entity in road_system
    end

    local url
    for _, _, entity in pickup_show_ui_mb:unpack() do
        w:sync("pickup_show_ui:in", entity)
        url = entity.pickup_show_ui.url
        if url and url ~= "" then
            iui.open(entity.pickup_show_ui.url)
        end
    end
end

local iconstruct = ecs.interface "iconstruct"
function iconstruct.init()
    iterrain.create()
end

-- todo 删除此接口
function iconstruct.show_route(building_id, path)
    local coord = assert(all_building[building_id])
    iroad.show_route(coord, path)
end