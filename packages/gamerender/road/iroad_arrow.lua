local ecs   = ...
local world = ecs.world
local w     = world.w

local math3d = require "math3d"
local mc = import_package "ant.math".constant
local iprefab_proxy = ecs.import.interface "vaststars.utility|iprefab_proxy"

local iroad_arrow = ecs.interface "iroad_arrow"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local on_prefab_message ; do
    local funcs = {}
    funcs["arrow_tile_coord"] = function(entity, prefab, arrow_tile_coord, tile_coord)
        w:sync("road_arrow:in", entity)
        entity.road_arrow.arrow_tile_coord = arrow_tile_coord
        entity.road_arrow.tile_coord = tile_coord
    end

    funcs["position"] = function (entity, prefab, position)
        iom.set_position(prefab.root, position)
    end

    function on_prefab_message(prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(prefab, ...)
        end
    end
end

function iroad_arrow.create(position, yaxis_rotation, direction, tile_coord, arrow_tile_coord)
    local prefab_file_name = "road/arrow.prefab"
    local srt = iprefab_proxy.get_config_srt(prefab_file_name)
    srt.t = position
    srt.r = math3d.ref(math3d.quaternion{axis = mc.YAXIS, r = yaxis_rotation})

    return iprefab_proxy.create(ecs.create_instance("/pkg/vaststars.resources/" .. prefab_file_name),
        {},
        {
            policy = {
                "vaststars.gamerender|road_arrow",
            },
            data = {
                road_arrow = {
                    direction = direction,
                    tile_coord = tile_coord,
                    arrow_tile_coord = arrow_tile_coord,
                },
            },
        },
        {
            on_ready = function(_, prefab)
                iom.set_srt(prefab.root, srt.s, srt.r, srt.t)
            end,
            on_message = on_prefab_message,
        }
    )
end
