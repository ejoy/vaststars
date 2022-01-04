local ecs   = ...
local world = ecs.world
local w     = world.w

local math3d = require "math3d"
local mc = import_package "ant.math".constant
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local iroad_arrow = ecs.interface "iroad_arrow"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"

local on_prefab_message ; do
    local funcs = {}
    funcs["set_arrow_tile_coord"] = function(game_object, prefab, arrow_tile_coord, tile_coord)
        w:sync("pickup_set_road:in", game_object)
        game_object.pickup_set_road.arrow_tile_coord = arrow_tile_coord
        game_object.pickup_set_road.tile_coord = tile_coord
    end

    funcs["set_position"] = function (game_object, prefab, position)
        iom.set_position(prefab.root, position)
    end

    function on_prefab_message(game_object, prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(game_object, prefab, ...)
        end
    end
end

function iroad_arrow.create(position, yaxis_rotation, tile_coord, arrow_tile_coord)
    local prefab = ecs.create_instance("/pkg/vaststars.resources/road/arrow.prefab")
    iom.set_position(prefab.root, position)
    iom.set_rotation(prefab.root, math3d.ref(math3d.quaternion{axis = mc.YAXIS, r = yaxis_rotation}))

    prefab.on_message = on_prefab_message
    local game_object = iprefab_object.create(prefab, {
        policy = {
            "vaststars.gamerender|pickup_set_road"
        },
        data = {
            pickup_set_road = {
                tile_coord = tile_coord,
                arrow_tile_coord = arrow_tile_coord,
            },
            pickup_mapping_tag = "pickup_set_road",
        },
    })

    return game_object
end
