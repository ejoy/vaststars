local ecs   = ...
local world = ecs.world
local w     = world.w

local iterrain = ecs.interface "iterrain"

local function generate_terrain_fields(w, h)
    local fields = {}
    for ih = 1, h do
        for iw = 1, w do
            fields[#fields+1] = {
                type    = "dust",
                height  = 0,
            }
        end
    end

    return fields
end

function iterrain.create()
    --
    local width, height = 256, 256
    local unit = 1
    local srt = {
        t = {-width//2 + unit/2, 0.0, -height//2 + unit/2}, -- 地形偏移
    }
    local shape = {}
    shape[1] = srt.t
    shape[2] = {shape[1][1] + width * unit, shape[1][2], shape[1][3] + height * unit}

    local terrain_fields = generate_terrain_fields(width, height)
    local entity = ecs.create_entity{
        policy = {
            "ant.scene|scene_object",
            "ant.terrain|shape_terrain",
            "ant.general|name",
            "vaststars|terrain",
        },
        data = {
            name = "shape_terrain_test",
            reference = true,
            scene = {
                srt = srt,
            },
            shape_terrain = {
                terrain_fields = terrain_fields, -- tile 类型
                width = width, -- width 与 height 的 tile 个数
                height = height,
                section_size = math.max(1, width > 4 and width//4 or width//2),
                unit = unit,  --- 所有数据的比例
                edge = {
                    color = 0xffe5e5e5,
                    thickness = 0.08,
                },
            },
            materials = {
                shape = "res/shape_terrain.material",
                edge = "res/shape_terrain_edge.material",
            },

            --
            terrain = {
                shape = shape,
                tile_bounds = {
                    {1, shape[2][1] - shape[1][1]},
                    {1, shape[2][3] - shape[1][3]},
                },
                tile_terrain_types = {},  -- = {[x][y] = terrain_type, ...}
                tile_building_types = {}, -- = {[x][y] = building_type, ...} 
            }
        }
    }
end

function iterrain.get_coord_by_position(position)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in")
    local shape = e.terrain.shape
    local unit = e.shape_terrain.unit

    if position[1] < shape[1][1] or position[1] > shape[2][1] then
        return
    end

    if position[3] < shape[1][3] or position[3] > shape[2][3] then
        return
    end

    local x = math.ceil((position[1] - shape[1][1]) / unit)
    local y = math.ceil((position[3] - shape[1][3]) / unit)

    return {x, y}
end

-- return the center of the tile
function iterrain.get_position_by_coord(tile_coord)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    local tile_bounds = e.terrain.tile_bounds
    local srt = e.scene.srt
    local unit = e.shape_terrain.unit

    for i = 1, #tile_bounds do
        if tile_coord[i] < tile_bounds[i][1] or tile_coord[i] > tile_bounds[i][2] then
            return
        end 
    end
    return {((tile_coord[1] - 1) * unit + unit / 2) + srt.t[1], 0, ((tile_coord[2] - 1) * unit + unit / 2) + srt.t[3]}
end

function iterrain.get_tile_building_type(tile_coord)
    local x = tile_coord[1]
    local y = tile_coord[2]

    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    if not e.terrain.tile_building_types[x] then
        return
    end

    return e.terrain.tile_building_types[x][y]
end

function iterrain.set_tile_building_type(tile_coord, building_type)
    local x = tile_coord[1]
    local y = tile_coord[2]

    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    e.terrain.tile_building_types[x] = e.terrain.tile_building_types[x] or {}
    e.terrain.tile_building_types[x][y] = building_type
end

function iterrain.can_construct(posision)
    local tile_coord = iterrain.get_coord_by_position(posision)
    return (iterrain.get_tile_building_type(tile_coord) == nil)
end
