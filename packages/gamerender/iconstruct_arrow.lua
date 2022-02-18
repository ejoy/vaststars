local ecs = ...
local world = ecs.world
local w = world.w

local arrow_coord_offset = {{0, -1}, {-1, 0}, {1, 0}, {0, 1}}
local arrow_rotation = {math.rad(-90.0), math.rad(180.0), math.rad(0), math.rad(90.0)}

local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"

local iconstruct_arrow = ecs.interface "iconstruct_arrow"

function iconstruct_arrow.hide(e, idx)
    w:sync("construct_arrows:in", e)
    if not idx then
        for idx, canvas in pairs(e.construct_arrows) do
            icanvas.remove_item(canvas.id)
            e.construct_arrows[idx] = nil
        end
    else
        local canvas = e.construct_arrows[idx]
        if canvas then
            icanvas.remove_item(canvas.id)
            e.construct_arrows[idx] = nil
        end
    end
    w:sync("construct_arrows:out", e)
end

function iconstruct_arrow.show(e, position)
    w:sync("construct_arrows:in", e)
    local tile_coord = iterrain.get_coord_by_position(position)
    local arrow_coord

    for idx, coord_offset in ipairs(arrow_coord_offset) do
        arrow_coord = {
            tile_coord[1] + coord_offset[1],
            tile_coord[2] + coord_offset[2],
        }

        local canvas = e.construct_arrows[idx]
        if canvas then
            icanvas.remove_item(canvas.id)
        end

        -- bounds checking
        local pos = iterrain.get_begin_position_by_coord(arrow_coord[1], arrow_coord[2])
        if not pos then
            goto continue
        end

        local itemids = icanvas.add_items({
            texture = {
                name = "arrow.png",
            },
            x = pos[1], y = pos[3],
            w = 10, h = 10,
            srt = {
                r = arrow_rotation[idx],
            }
        })

        e.construct_arrows[igameplay_adapter.pack_coord(arrow_coord[1], arrow_coord[2])] = {id = itemids[1], tile_coord = tile_coord, arrow_coord = arrow_coord,}
        ::continue::
    end
    w:sync("construct_arrows:out", e)
end
