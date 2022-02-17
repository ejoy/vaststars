local ecs = ...
local world = ecs.world
local w = world.w

local arrow_coord_offset = {{0, -1}, {-1, 0}, {1, 0}, {0, 1}}
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"

local iconstruct_arrow = ecs.interface "iconstruct_arrow"
local construct_arrow_sys = ecs.system "construct_arrow_system"
local canvas_new_item_mb = world:sub {"canvas_update", "new_item"}
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"

function construct_arrow_sys.data_changed()
    for _, _, e, component_name, ep in canvas_new_item_mb:unpack() do
        w:sync(("%s?in"):format(component_name), ep)
        if ep[component_name] then
            w:sync("scene:in", e)
            ipickup_mapping.mapping(e.scene.id, ep, {component_name})
        end
    end
end

function iconstruct_arrow.hide(e, idx)
    w:sync("construct_arrows:in", e)
    if not idx then
        for idx, canvas in pairs(e.construct_arrows) do
            icanvas.remove_item(canvas.id)
            w:remove(canvas.e)
            e.construct_arrows[idx] = nil
        end
    else
        local canvas = e.construct_arrows[idx]
        if canvas then
            icanvas.remove_item(canvas.id)
            w:remove(canvas.e)
            e.construct_arrows[idx] = nil
        end
    end
    w:sync("construct_arrows:out", e)
end

local textures = {
    [1] = {
        path = "/pkg/vaststars.resources/textures/arrow_1.png",
        w = 203,
        h = 271,
    },
    [2] = {
        path = "/pkg/vaststars.resources/textures/arrow_2.png",
        w = 271,
        h = 203,
    },
    [3] = {
        path = "/pkg/vaststars.resources/textures/arrow_3.png",
        w = 271,
        h = 203,
    },
    [4] = {
        path = "/pkg/vaststars.resources/textures/arrow_4.png",
        w = 203,
        h = 271,
    },
}

function iconstruct_arrow.show(e, component_name, position)
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

        local texture = textures[idx]
        if not texture then
            goto continue
        end

        -- bounds checking
        local pos = iterrain.get_begin_position_by_coord(arrow_coord[1], arrow_coord[2])
        if not pos then
            goto continue
        end

        local ep = ecs.create_entity {
            policy = {
                "ant.scene|scene_object",
            },
            data = {
                [component_name] = {
                    tile_coord = tile_coord,
                    arrow_coord = arrow_coord,
                },
                reference = true,
                scene = {srt={}},
            }
        }

        local itemids = icanvas.add_items({
            texture = {
                path = texture.path,
                rect = {
                    x = 0, y = 0,
                    w = texture.w, h = texture.h,
                },
            },
            x = pos[1], y = pos[3],
            w = 10, h = 10,
            param = {component_name, ep},
        })

        e.construct_arrows[idx] = {id = itemids[1], e = ep}
        ::continue::
    end
    w:sync("construct_arrows:out", e)
end
