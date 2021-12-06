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
local math3d = require "math3d"
local get_prefab_cfg_srt = ecs.require "world.prefab_cfg_srt"
local create_prefab_binding = ecs.require "world.prefab_binding"

local ui_mb = world:sub {"ui", "construct", "building"}
local ui_confirm_mb = world:sub {"ui", "construct", "confirm"}

local drapdrop_entity_mb = world:sub {"drapdrop_entity"}
local construct_sys = ecs.system 'construct_system'
local construct_prefab -- assuming there is only one "construct entity" in the same time

local function __get_binding_entity(prefab)
    local s = #prefab.tag["*"]
    return prefab.tag["*"][s]
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

local function __set_basecolor_by_pos(prefab, position)
    local basecolor_factor
    if not iterrain.can_construct(position) then
        basecolor_factor = {100.0, 0.0, 0.0, 0.8}
    else
        basecolor_factor = {0.0, 100.0, 0.0, 0.8}
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
    __set_basecolor_by_pos(prefab, position)
    iui.post("construct", "show_construct_confirm", true, icamera.world_to_screen(position))
end

local on_prefab_message ; do
    local funcs = {}
    funcs["basecolor"] = function(prefab, position)
        __set_basecolor_by_pos(prefab, position)
    end

    funcs["confirm_construct"] = function(prefab)
        local binding_entity = __get_binding_entity(prefab)
        local position = math3d.tovalue(iom.get_position(binding_entity))
        if iterrain.can_construct(position) then
            --
            w:sync("construct_entity:in", binding_entity)

            local position = math3d.tovalue(iom.get_position(binding_entity))
            local building_type = binding_entity.construct_entity.building_type
            local tile_coord = iterrain.get_coord_by_position(position)
            iterrain.set_tile_building_type(tile_coord, building_type)

            iui.post("construct", "show_construct_confirm", false)

            --
            prefab:send("remove")

            --
            construct_prefab = nil -- todo bad taste
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

local function create_construct_entity(building_type, prefab_file_name)
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
local funcs = {}
funcs["road"] = function()
    construct_prefab = create_construct_entity("road", "res/road/O_road.prefab")
end

function construct_sys:data_changed()
    local func
    for _, _, _, building_type in ui_mb:unpack() do
        func = funcs[building_type]
        if func then
            if construct_prefab then
                construct_prefab:send("remove")
                construct_prefab = nil
            end

            func()
        end
    end

    for _, _, _ in ui_confirm_mb:unpack() do
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
                iui.post("construct", "show_construct_confirm", true, icamera.world_to_screen(position))

                construct_prefab:send("basecolor", position)
            end
        end
    end
end
