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
    local width, height = 256, 256
    local unit = 10
    local srt = {
        t = {-(width * unit)//2 + unit//2, 0.0, -(height * unit)//2 + unit//2}, -- offset
    }
    local shape = {}
    shape[1] = srt.t
    shape[2] = {shape[1][1] + width * unit, shape[1][2], shape[1][3] + height * unit}

    ecs.create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.terrain|shape_terrain",
            "ant.general|name",
            "vaststars.gamerender|terrain",
        },
        data = {
            name = "shape_terrain",
            reference = true,
            scene = {
                srt = srt,
            },
            shape_terrain = {
                terrain_fields = generate_terrain_fields(width, height), -- tile 类型
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
                shape = "/pkg/vaststars.resources/shape_terrain.material",
                edge = "/pkg/vaststars.resources/shape_terrain_edge.material",
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
            },
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
function iterrain.get_position_by_coord(x, y)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    local tile_bounds = e.terrain.tile_bounds
    local srt = e.scene.srt
    local unit = e.shape_terrain.unit

    for i = 1, #tile_bounds do
        if x < tile_bounds[i][1] or y > tile_bounds[i][2] then
            return
        end
    end
    return {((x - 1) * unit + unit / 2) + srt.t[1], 0, ((y - 1) * unit + unit / 2) + srt.t[3]}
end

function iterrain.get_begin_position_by_coord(...)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    local tile_bounds = e.terrain.tile_bounds
    local srt = e.scene.srt
    local unit = e.shape_terrain.unit

    local coord = {...}
    for i = 1, #tile_bounds do
        if coord[i] < tile_bounds[i][1] or coord[i] > tile_bounds[i][2] then
            return
        end
    end
    return {((coord[1] - 1) * unit) + srt.t[1], 0, ((coord[2] - 1) * unit + unit) + srt.t[3]}
end

function iterrain.get_confirm_ui_position(position)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    local srt = e.scene.srt
    local unit = e.shape_terrain.unit

    local coord = iterrain.get_coord_by_position(position)
    return {((coord[1] - 1) * unit - unit) + srt.t[1], 0, ((coord[2] - 1) * unit + 2 * unit) + srt.t[3]},
           {((coord[1] - 1) * unit + unit) + srt.t[1], 0, ((coord[2] - 1) * unit + 2 * unit) + srt.t[3]},
           {((coord[1] - 1) * unit ) + srt.t[1], 0, ((coord[2] - 1) * unit) + srt.t[3]}
end

function iterrain.get_tile_centre_position(position)
    local coord = iterrain.get_coord_by_position(position)
    return iterrain.get_position_by_coord(coord[1], coord[2])
end

function iterrain.get_tile_building_type(coord)
    local x = coord[1]
    local y = coord[2]

    local e = w:singleton("terrain", "terrain:in shape_terrain:in")
    if not e.terrain.tile_building_types[x] then
        return
    end

    return e.terrain.tile_building_types[x][y]
end

function iterrain.set_tile_building_type(coord, building_type, area)
    local width = area[1]
    local height = area[2]

    local e = w:singleton("shape_terrain", "terrain:in shape_terrain:in")
    local terrain = e.terrain

    for x = coord[1] - (width // 2), coord[1] + (width // 2) do
        for y = coord[2] - (height // 2), coord[2] + (height // 2) do
            terrain.tile_building_types[x] = terrain.tile_building_types[x] or {}
            terrain.tile_building_types[x][y] = building_type
        end
    end
end
