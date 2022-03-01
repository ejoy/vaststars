local ecs   = ...
local world = ecs.world
local w     = world.w

local terrain = {}

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

function terrain.create()
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

            --
            terrain = {
                shape = shape,
                tile_bounds = {
                    {0, 0},
                    {(shape[2][1] - shape[1][1]) // unit - 1, (shape[2][3] - shape[1][3]) // unit - 1},
                },
                origin = {shape[1][1], shape[2][3]}, -- origin in logical coordinates
            },
        }
    }
end

return terrain