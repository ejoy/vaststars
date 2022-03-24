local ecs = ...
local world = ecs.world
local w = world.w
local vector2 = require "vector2"

local arrow_coord_offset = {vector2.RIGHT, vector2.DOWN, vector2.LEFT, vector2.UP}
local arrow_rotation = {math.rad(0), math.rad(90.0), math.rad(180.0), math.rad(270.0)}

local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local iconstruct_arrow = ecs.interface "iconstruct_arrow"
local prototype = ecs.require "prototype"
local construct_arrows = {}

function iconstruct_arrow.hide()
    for _, canvas in pairs(construct_arrows) do
        icanvas.remove_item(canvas.id)
    end
    construct_arrows = {}
end

function iconstruct_arrow.show(sx, sy)
    -- remove all items at first
    iconstruct_arrow.hide()

    for idx, coord_offset in ipairs(arrow_coord_offset) do
        local dx = sx + coord_offset[1]
        local dy = sy + coord_offset[2]

        local item_id = icanvas.add_items("arrow.png", dx, dy, {r = arrow_rotation[idx]})
        construct_arrows[prototype.pack_coord(dx, dy)] = {id = item_id, sx = sx, sy = sy, dx = dx, dy = dy}
    end
end
