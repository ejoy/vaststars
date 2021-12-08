local ecs = ...
local world = ecs.world
local w = world.w

local serialize = import_package "ant.serialize"
local cr = import_package "ant.compile_resource"
local iinput = ecs.import.interface "vaststars|iinput"
local ipickup_mapping = ecs.import.interface "vaststars|ipickup_mapping"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local icamera = ecs.import.interface "ant.camera|icamera"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iui = ecs.import.interface "vaststars|iui"
local iterrain = ecs.import.interface "vaststars|iterrain"
local iroad_arrow = ecs.import.interface "vaststars|iroad_arrow"
local iroad = ecs.import.interface "vaststars|iroad"
local math3d = require "math3d"
local get_prefab_cfg_srt = ecs.require "world.prefab_cfg_srt"
local create_prefab_binding = ecs.require "world.prefab_binding"
local construct_cfg = ecs.require "lualib.config.construct"
local ROAD_YAXIS_DEFAULT <const> = ecs.require("lualib.define").ROAD_YAXIS_DEFAULT
local CONSTRUCT_RED_BASIC_COLOR <const> = {100.0, 0.0, 0.0, 0.8}
local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 100.0, 0.0, 0.8}

local ui_construct_building_mb = world:sub {"ui", "construct", "building"}
local ui_construct_confirm_mb = world:sub {"ui", "construct", "confirm"}
local pickup_mapping_mb = world:sub {"pickup_mapping"}
local pickup_mb = world:sub {"pickup"}
local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local shape_terrain_mb = world:sub {"shape_terrain", "on_ready"}
local terrain_road_mb = world:sub {"terrain_road", "on_ready"}
local construct_sys = ecs.system "construct_system"
local construct_prefab -- assuming there is only one "construct entity" in the same time
local road_binding_entity

local function __get_binding_entity(prefab)
    local s = #prefab.tag["*"]
    return prefab.tag["*"][s]
end

local function __get_construct_entity(prefab)
    local binding_entity = __get_binding_entity(prefab)
    w:sync("construct_entity:in", binding_entity)
    return binding_entity.construct_entity
end

local function __replace_material(template)
    for _, v in ipairs(template) do
        for _, policy in ipairs(v.policy) do
            if policy == "ant.render|render" or policy == "ant.render|simplerender" then
                v.data.material = "/pkg/vaststars/res/construct.material"
            end
        end
    end

    return template
end

local function __update_basecolor_by_pos(prefab, position) 
    local basecolor_factor
    local construct_entity = __get_construct_entity(prefab)
    if not construct_entity.test_func(construct_entity.building_type, position) then
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

local function on_prefab_ready(prefab)
    local position = math3d.tovalue(iom.get_position(prefab.root))
    __update_basecolor_by_pos(prefab, position)

    iui.post("construct", "show_construct_confirm", true, math3d.tovalue(icamera.world_to_screen(position)) )
end

local on_prefab_message ; do
    local funcs = {}
    funcs["basecolor"] = function(prefab, position)
        __update_basecolor_by_pos(prefab, position)
    end

    funcs["confirm_construct"] = function(prefab)
        local binding_entity = __get_binding_entity(prefab)
        w:sync("construct_entity:in", binding_entity)
        local construct_entity = binding_entity.construct_entity
        local position = math3d.tovalue(iom.get_position(binding_entity))
        local building_type = construct_entity.building_type

        if construct_entity.test_func(building_type, position) then         
            local tile_coord = iterrain.get_coord_by_position(position)

            if building_type == "road" then -- todo bad taste
                iroad.construct(nil, tile_coord, "O0")
            else
                local prefab_file_name = construct_entity.prefab_file_name
                local srt = get_prefab_cfg_srt(prefab_file_name)
                srt.t = position
                create_prefab_binding("/pkg/vaststars/" .. prefab_file_name, {
                    policy = {
                        "ant.scene|scene_object",
                        "vaststars|prefab_binding",
                    },
                    data = {
                        scene = {
                            srt = srt,
                        },
                    },
                })

                -- todo bad taste
                local cfg = construct_cfg[building_type]
                if cfg then
                    local coord = {
                        tile_coord[1],
                        (tile_coord[2] - cfg.size[2] // 2),
                    }
                    iroad.set_building_entry(coord)
                end
            end

            iterrain.set_tile_building_type(tile_coord, building_type)
            iui.post("construct", "show_construct_confirm", false)
            prefab:send("remove")
            construct_prefab = nil
        else
            -- todo error tips
            print("can not construct")
        end
    end

    function on_prefab_message(prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(prefab, ...)
        end
    end
end

local function __create_construct_entity(building_type, prefab_file_name, test_func)
    local p = "/pkg/vaststars/" .. prefab_file_name
    local template = __replace_material(serialize.parse(p, cr.read_file(p)))

    return create_prefab_binding(template, {
        policy = {
            "ant.scene|scene_object",
            "vaststars|construct_entity",
            "vaststars|drapdrop",
            "vaststars|prefab_binding",
        },
        data = {
            construct_entity = {
                building_type = building_type,
                prefab_file_name = prefab_file_name,
                test_func = test_func,
            },
            scene = {
                srt = get_prefab_cfg_srt(prefab_file_name),
            },
            drapdrop = true,
            prefab_binding_on_ready = on_prefab_ready,
            prefab_binding_on_message = on_prefab_message,
        },
    })
end

----------------------------------
local show_road_arrow, hide_road_arrow ; do
    local road_arrow_prefabs = {}
    local arrow_tile_coord_offset = {{0, -1}, {-1, 0}, {1, 0}, {0, 1}}
    local arrow_yaxis_rotation = {math.rad(180.0), math.rad(-90.0), math.rad(90.0), math.rad(0.0)}
    local arrow_direction = {"top", "left", "right", "bottom"}

    function hide_road_arrow(idx)
        if not idx then
            for idx, prefab in pairs(road_arrow_prefabs) do
                prefab:send("remove")
                road_arrow_prefabs[idx] = nil
            end
        else
            local prefab = road_arrow_prefabs[idx]
            if prefab then
                prefab:send("remove")
                road_arrow_prefabs[idx] = nil
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

            local building_type = iterrain.get_tile_building_type(arrow_tile_coord)
            if building_type and building_type ~= "road" then
                hide_road_arrow(idx)
                goto continue
            end

            tile_position[2] = ROAD_YAXIS_DEFAULT
            local prefab = road_arrow_prefabs[idx]
            if not prefab then
                road_arrow_prefabs[idx] = iroad_arrow.create(tile_position, arrow_yaxis_rotation[idx], arrow_direction[idx], tile_coord, arrow_tile_coord)
            else
                prefab:send("arrow_tile_coord", arrow_tile_coord, tile_coord)
                prefab:send("position", tile_position)
            end
            ::continue::
        end
    end
end

function construct_sys:data_changed()
    local cfg
    for _, _, _, building_type in ui_construct_building_mb:unpack() do
        cfg = construct_cfg[building_type]
        if cfg then
            if construct_prefab then
                construct_prefab:send("remove")
            end
            construct_prefab = __create_construct_entity(cfg.building_type, cfg.prefab_file_name, ecs.require(cfg.test_func))
        end
    end

    for _, _, _ in ui_construct_confirm_mb:unpack() do
        if construct_prefab then
            construct_prefab:send("confirm_construct")
        end
    end

    local entity, position
    for _, eid, mouse_x, mouse_y in drapdrop_entity_mb:unpack() do
        entity = ipickup_mapping.get_entity(eid)
        if entity then
            w:sync("construct_entity?in", entity)
            if entity.construct_entity then
                position = iinput.screen_to_world {mouse_x, mouse_y}
                position = iterrain.get_tile_centre_position(math3d.tovalue(position))
                iom.set_position(entity, position)
                iui.post("construct", "show_construct_confirm", true, math3d.tovalue(icamera.world_to_screen(position)))

                construct_prefab:send("basecolor", position)
            end
        end
    end

    --
    for _, _, e, parent in shape_terrain_mb:unpack() do
        w:sync("scene:in", e)
        ipickup_mapping.mapping(e.scene.id, parent)
    end

    for _, _, prefab in terrain_road_mb:unpack() do
        for _, e in ipairs(prefab.tag["*"]) do
            w:sync("scene:in", e)
            ipickup_mapping.mapping(e.scene.id, road_binding_entity)
        end
    end
end

function construct_sys:after_pickup_mapping()
    local mapping_entity, is_show_road_arrow
    for _, _, meid in pickup_mapping_mb:unpack() do
        mapping_entity = ipickup_mapping.get_entity(meid)
        if mapping_entity then
            w:sync("building?in", mapping_entity)
            if mapping_entity.building then
                if mapping_entity.building.building_type == "road" then
                    show_road_arrow( iterrain.get_tile_centre_position(iinput.get_mouse_world_position()) )
                    is_show_road_arrow = true
                end
            end

            w:sync("road_arrow?in", mapping_entity)
            if mapping_entity.road_arrow then
                local arrow_tile_coord = mapping_entity.road_arrow.arrow_tile_coord
                iterrain.set_tile_building_type(arrow_tile_coord, "road")
                iroad.construct(mapping_entity.road_arrow.tile_coord, arrow_tile_coord)
            end
        end
    end

    for _ in pickup_mb:unpack() do
        if not is_show_road_arrow then
            hide_road_arrow()
            break
        end
    end
end

local iconstruct = ecs.interface "iconstruct"
function iconstruct.init()
    road_binding_entity = ecs.create_entity {
        policy = {
            "ant.scene|scene_object",
            "vaststars|building",
        },
        data = {
            scene = {
                srt = {}
            },
            building = {
                building_type = "road",
            },
            reference = true,
        },
    }

    iterrain.create({
        on_ready = function(entity)
            w:sync("scene:in", entity)
            ipickup_mapping.mapping(entity.scene.id, entity)
        end,
    })
end
