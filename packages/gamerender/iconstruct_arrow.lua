local ecs = ...
local world = ecs.world
local w = world.w

local arrow_coord_offset = {{0, -1}, {-1, 0}, {1, 0}, {0, 1}}
local arrow_yaxis_rotation = {math.rad(180.0), math.rad(-90.0), math.rad(90.0), math.rad(0.0)}
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local math3d = require "math3d"
local mc = import_package "ant.math".constant
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ifs = ecs.import.interface "ant.scene|ifilter_state"

local iconstruct_arrow = ecs.interface "iconstruct_arrow"

local funcs = {}
funcs["set_arrow_coord"] = function(game_object, prefab, component_name, arrow_coord, tile_coord, tile_position)
    w:sync(("%s:in"):format(component_name), game_object)
    game_object[component_name].arrow_coord = arrow_coord
    game_object[component_name].tile_coord = tile_coord
    w:sync(("%s:out"):format(component_name), game_object)
    iom.set_position(prefab.root, tile_position)
end

funcs["show"] = function(game_object, prefab)
    for _, e in ipairs(prefab.tag['*']) do
        ifs.set_state(e, "main_view", true)
        ifs.set_state(e, "selectable", true)
    end
end

funcs["hide"] = function(game_object, prefab)
    for _, e in ipairs(prefab.tag['*']) do
        ifs.set_state(e, "main_view", false)
        ifs.set_state(e, "selectable", false)
    end
end

local function on_prefab_message(game_object, prefab, cmd, ...)
    local func = funcs[cmd]
    if func then
        func(game_object, prefab, ...)
    end
end

function iconstruct_arrow.hide(e, idx)
    w:sync("construct_arrows:in", e)
    if not idx then
        for idx, game_object in pairs(e.construct_arrows) do
            igame_object.get_prefab_object(game_object):remove()
            e.construct_arrows[idx] = nil
            -- igame_object.get_prefab_object(game_object):send("hide")
        end
    else
        local game_object = e.construct_arrows[idx]
        if game_object then
            igame_object.get_prefab_object(game_object):remove()
            e.construct_arrows[idx] = nil
            -- igame_object.get_prefab_object(game_object):send("hide")
        end
    end
    w:sync("construct_arrows:out", e)
end

function iconstruct_arrow.show(e, yaxis, component_name, position)
    w:sync("construct_arrows:in construct_arrows_building_type:in", e)
    local tile_coord = iterrain.get_coord_by_position(position)
    local arrow_coord

    for idx, coord_offset in ipairs(arrow_coord_offset) do
        arrow_coord = {
            tile_coord[1] + coord_offset[1],
            tile_coord[2] + coord_offset[2],
        }

        -- bounds checking
        local tile_position = iterrain.get_position_by_coord(arrow_coord)
        if not tile_position then
            iconstruct_arrow.hide(e, idx)
            goto continue
        end

        -- only tiles that don't have a building or the same type of building can be set
        local building_type = iterrain.get_tile_building_type(arrow_coord)
        if building_type and building_type ~= e.construct_arrows_building_type then
            iconstruct_arrow.hide(e, idx)
            goto continue
        end

        tile_position[2] = yaxis
        local game_object = e.construct_arrows[idx]
        if not game_object then
            local prefab = ecs.create_instance("/pkg/vaststars.resources/construct_arrow.prefab")
            iom.set_position(prefab.root, tile_position)
            iom.set_rotation(prefab.root, math3d.ref(math3d.quaternion{axis = mc.YAXIS, r = arrow_yaxis_rotation[idx]}))

            prefab.on_message = on_prefab_message
            local game_object = iprefab_object.create(prefab, {
                data = {
                    [component_name] = {
                        tile_coord = tile_coord,
                        arrow_coord = arrow_coord,
                    },
                },
            })

            e.construct_arrows[idx] = game_object
        else
            local prefab_object = igame_object.get_prefab_object(game_object)
            prefab_object:send("set_arrow_coord", component_name, arrow_coord, tile_coord, tile_position)
            prefab_object:send("show")
        end
        ::continue::
    end
    w:sync("construct_arrows:out", e)
end
