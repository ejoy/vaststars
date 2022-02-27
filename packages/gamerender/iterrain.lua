local ecs   = ...
local world = ecs.world
local w     = world.w

local iterrain = ecs.interface "iterrain"
local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"
local UP = require "vector2".UP

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
            scene = {
                srt = srt,
            },
            shape_terrain = {
                terrain_fields = generate_terrain_fields(width, height),
                width = width,
                height = height,
                section_size = math.max(1, width > 4 and width//4 or width//2),
                unit = unit,
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
                    {0, 0},
                    {(shape[2][1] - shape[1][1]) // unit - 1, (shape[2][3] - shape[1][3]) // unit - 1},
                },
                origin = {shape[1][1], shape[2][3]}, -- origin in logical coordinates
                tile_building_types = {}, -- = {[x][y] = building_type, ...}
            },
        }
    }
end

function iterrain.verify_coord(x, y)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    if not e then
        log.error("can not found terrain")
        return false
    end

    local tile_bounds = e.terrain.tile_bounds

    if x < tile_bounds[1][1] or x > tile_bounds[2][1] then
        return false
    end

    if y < tile_bounds[1][2] or y > tile_bounds[2][2] then
        return false
    end

    return true
end

function iterrain.get_coord_by_position(position)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in")
    local shape = e.terrain.shape
    local origin = e.terrain.origin
    local shape_terrain = e.shape_terrain
    local unit = shape_terrain.unit

    if position[1] < shape[1][1] or position[1] > shape[2][1] then
        log.error(("out of bounds (%s) : (%s) - (%s)"):format(table.concat(position, ","), table.concat(shape[1], ","), table.concat(shape[2], ",")))
        return
    end

    if position[3] < shape[1][3] or position[3] > shape[2][3] then
        log.error(("out of bounds (%s) : (%s) - (%s)"):format(table.concat(position, ","), table.concat(shape[1], ","), table.concat(shape[2], ",")))
        return
    end

    return {math.ceil((position[1] - origin[1]) / unit) - 1, math.ceil((origin[2] - position[3]) / unit) - 1}
end

function iterrain.get_begin_position_by_coord(x, y)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    local tile_bounds = e.terrain.tile_bounds
    local shape_terrain = e.shape_terrain
    local unit = shape_terrain.unit
    local origin = e.terrain.origin

    if not iterrain.verify_coord(x, y) then
        log.error(("out of bounds (%s,%s) : (%s) - (%s)"):format(x, y, table.concat(tile_bounds[1], ","), table.concat(tile_bounds[2], ",")))
        return
    end
    return {origin[1] + (x * unit), 0, origin[2] - (y * unit)}
end

function iterrain.adjust_position(position, area)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    local unit = e.shape_terrain.unit
    local coord = iterrain.get_coord_by_position(position)
    if not coord then
        return
    end

    local width, height = igameplay_adapter.unpack_coord(area)
    coord[2] = coord[2] + UP[2] * (height - 1)

    local begining = iterrain.get_begin_position_by_coord(coord[1], coord[2])
    if not begining then
        return
    end

    return coord, {begining[1] + (width * unit // 2), position[2], begining[3] - (height * unit // 2)}
end

-- return the center of the tile
function iterrain.get_position_by_coord(x, y)
    local e = w:singleton("terrain", "terrain:in shape_terrain:in scene:in")
    local unit = e.shape_terrain.unit
    local position = iterrain.get_begin_position_by_coord(x, y)
    if not position then
        return
    end
    return {position[1] + unit // 2, position[2], position[3] - unit // 2}
end

function iterrain.get_tile_building_type(coord)
    local x, y = coord[1], coord[2]
    local e = w:singleton("terrain", "terrain:in shape_terrain:in")
    if not e.terrain.tile_building_types[x] then
        return
    end

    return e.terrain.tile_building_types[x][y]
end

function iterrain.set_tile_building_type(coord, building_type, area)
    local e = w:singleton("shape_terrain", "terrain:in shape_terrain:in")
    local terrain = e.terrain
    local width, height = igameplay_adapter.unpack_coord(area)

    for x = 0, width - 1 do
        for y = 0, height - 1 do
            local px = coord[1] + x
            local py = coord[2] + y
            terrain.tile_building_types[px] = terrain.tile_building_types[px] or {}
            terrain.tile_building_types[px][py] = building_type
        end
    end
end
