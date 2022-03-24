local ecs = ...
local world = ecs.world
local w = world.w
local vector2 = require "vector2"

local arrow_coord_offset = {vector2.RIGHT, vector2.DOWN, vector2.LEFT, vector2.UP}
local arrow_rotation = {math.rad(0), math.rad(90.0), math.rad(180.0), math.rad(270.0)}

local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local iinput = ecs.import.interface "vaststars.gamerender|iinput"
local iconstruct_arrow = ecs.interface "iconstruct_arrow"
local construct_arrow_sys = ecs.system "construct_arrow_system"
local prototype = ecs.require "prototype"
local pickup_mapping_canvas_mb = world:sub {"pickup_mapping", "canvas"}
local terrain = ecs.require "terrain"

local construct_arrows = {}

function construct_arrow_sys:pickup_mapping()
    for _ in pickup_mapping_canvas_mb:unpack() do
        local coord = terrain.get_coord_by_position(iinput.get_mouse_world_position())
        local k = prototype.pack_coord(coord[1], coord[2])
        local v = construct_arrows[k]
        if v then
            v.func(v.prototype_name, v.dx, v.dy)
        end
    end
end

function iconstruct_arrow.hide()
    for _, canvas in pairs(construct_arrows) do
        icanvas.remove_item(canvas.id)
    end
    construct_arrows = {}
end

function iconstruct_arrow.show(prototype_name, sx, sy, func)
    -- remove all items at first
    iconstruct_arrow.hide()

    for idx, coord_offset in ipairs(arrow_coord_offset) do
        local dx = sx + coord_offset[1]
        local dy = sy + coord_offset[2]

        local item_id = icanvas.add_items("arrow.png", dx, dy, {r = arrow_rotation[idx]})
        construct_arrows[prototype.pack_coord(dx, dy)] = {id = item_id, func = func, prototype_name = prototype_name, sx = sx, sy = sy, dx = dx, dy = dy}
    end
end
