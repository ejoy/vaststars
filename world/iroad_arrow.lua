local ecs   = ...
local world = ecs.world
local w     = world.w

local math3d = require "math3d"
local mc = import_package "ant.math".constant
local create_prefab_binding = ecs.require "world.prefab_binding"
local get_prefab_cfg_srt = ecs.require "world.prefab_cfg_srt"

local iroad_arrow = ecs.interface "iroad_arrow"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local function __get_binding_entity(prefab)
    local s = #prefab.tag["*"]
    return prefab.tag["*"][s]
end

local on_prefab_message ; do
    local funcs = {}
    funcs["arrow_tile_coord"] = function(prefab, arrow_tile_coord, tile_coord)
        local binding_entity = __get_binding_entity(prefab)
        w:sync("road_arrow:in", binding_entity)

        binding_entity.road_arrow.arrow_tile_coord = arrow_tile_coord
        binding_entity.road_arrow.tile_coord = tile_coord
    end

    funcs["position"] = function (prefab, position)
        local binding_entity = __get_binding_entity(prefab)
        iom.set_position(binding_entity, position)
    end

    function on_prefab_message(prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(prefab, ...)
        end
    end
end

function iroad_arrow.create(position, yaxis_rotation, direction, tile_coord, arrow_tile_coord)
    local prefab_file_name = "res/road/arrow.prefab"
    local srt = get_prefab_cfg_srt(prefab_file_name)
    srt.t = position
    srt.r = math3d.ref(math3d.quaternion{axis = mc.YAXIS, r = yaxis_rotation})

    return create_prefab_binding("/pkg/vaststars/" .. prefab_file_name, {
        policy = {
            "ant.scene|scene_object",
            "vaststars|prefab_binding",
            "vaststars|road_arrow",
        },
        data = {
            scene = {
                srt = srt,
            },
            road_arrow = {
                direction = direction,
                tile_coord = tile_coord,
                arrow_tile_coord = arrow_tile_coord,
            },
            prefab_binding_on_message = on_prefab_message,
        },
    })
end