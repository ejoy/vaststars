local ecs = ...
local world = ecs.world
local w = world.w

--[[
            (0, -1):270
(-1, 0):180             (1, 0):0
            (0, 1):90
--]]
local arrow_coord_offset = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
local arrow_rotation = {math.rad(0), math.rad(90.0), math.rad(180.0), math.rad(270.0)}

local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"

local iconstruct_arrow = ecs.interface "iconstruct_arrow"

function iconstruct_arrow.hide(e)
    w:sync("construct_arrows:in", e)
    for _, canvas in pairs(e.construct_arrows) do
        icanvas.remove_item(canvas.id)
    end
    e.construct_arrows = {}
    w:sync("construct_arrows:out", e)
end

function iconstruct_arrow.show(e, position)
    w:sync("construct_arrows:in", e)
    local tile_coord = iterrain.get_coord_by_position(position)
    local arrow_coord

    -- remove all items at first
    iconstruct_arrow.hide(e)

    for idx, coord_offset in ipairs(arrow_coord_offset) do
        arrow_coord = {
            tile_coord[1] + coord_offset[1],
            tile_coord[2] + coord_offset[2],
        }

        local item_id = icanvas.add_items("arrow.png", arrow_coord[1], arrow_coord[2], {r = arrow_rotation[idx]})
        e.construct_arrows[igameplay_adapter.pack_coord(arrow_coord[1], arrow_coord[2])] = {id = item_id, tile_coord = tile_coord, arrow_coord = arrow_coord,}
    end
    w:sync("construct_arrows:out", e)
end
