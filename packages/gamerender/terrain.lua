local ecs   = ...
local world = ecs.world
local w     = world.w
local UP_LEFT = require "gameplay.utility.vector2".UP_LEFT

local M = {}
local terrain = {}

local function unpackCoord(v)
    return v >> 8, v & 0xFF
end

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

function M.create()
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
        }
    }

    terrain.shape = shape
    terrain.tile_bounds = {
        {0, 0},
        {(shape[2][1] - shape[1][1]) // unit - 1, (shape[2][3] - shape[1][3]) // unit - 1},
    }
    terrain.origin = {shape[1][1], shape[2][3]} -- origin in logical coordinates
end

function M.verify_coord(x, y)
    local e = w:singleton("shape_terrain", "shape_terrain:in scene:in")
    if not e then
        log.error("can not found terrain")
        return false
    end

    local tile_bounds = terrain.tile_bounds

    if x < tile_bounds[1][1] or x > tile_bounds[2][1] then
        return false
    end

    if y < tile_bounds[1][2] or y > tile_bounds[2][2] then
        return false
    end

    return true
end

function M.get_coord_by_position(position)
    local e = w:singleton("shape_terrain", "shape_terrain:in")
    local shape = terrain.shape
    local origin = terrain.origin
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

function M.get_begin_position_by_coord(x, y)
    local e = w:singleton("shape_terrain", "shape_terrain:in scene:in")
    local tile_bounds = terrain.tile_bounds
    local shape_terrain = e.shape_terrain
    local unit = shape_terrain.unit
    local origin = terrain.origin

    if not M.verify_coord(x, y) then
        log.error(("out of bounds (%s,%s) : (%s) - (%s)"):format(x, y, table.concat(tile_bounds[1], ","), table.concat(tile_bounds[2], ",")))
        return
    end
    return {origin[1] + (x * unit), 0, origin[2] - (y * unit)}
end

function M.get_position_by_coord(x, y, area)
    local e = w:singleton("shape_terrain", "shape_terrain:in scene:in")
    local unit = e.shape_terrain.unit

    local width, height = unpackCoord(area)
    local begining = M.get_begin_position_by_coord(x, y)
    if not begining then
        return
    end

    return {begining[1] + (width * unit // 2), begining[2], begining[3] - (height * unit // 2)} --TODO 越界判断
end

function M.adjust_position(position, width, height)
    local e = w:singleton("shape_terrain", "shape_terrain:in scene:in")
    local unit = e.shape_terrain.unit
    local coord = M.get_coord_by_position(position)
    if not coord then
        return
    end

    coord[1] = coord[1] + UP_LEFT[1] * (width // 2)
    coord[2] = coord[2] + UP_LEFT[2] * (height // 2)

    local begining = M.get_begin_position_by_coord(coord[1], coord[2])
    if not begining then
        return
    end

    return coord, {begining[1] + (width * unit // 2), position[2], begining[3] - (height * unit // 2)}
end

--TODO bad taste
function M.get_adjust_position(x, y, position, new_width, new_height)
    local e = w:singleton("shape_terrain", "shape_terrain:in scene:in")
    local unit = e.shape_terrain.unit
    local begining = M.get_begin_position_by_coord(x, y)
    if not begining then
        return
    end

    return {begining[1] + (new_width * unit // 2), position[2], begining[3] - (new_height * unit // 2)}
end

return M