local ecs   = ...
local world = ecs.world
local w     = world.w

local iterrain  = ecs.import.interface "ant.terrain|iterrain"
local road = {}
local UNIT <const> = 10

local function _convert_coord(t)
    assert(road._offset)
    for _, v in ipairs(t) do
        local x, y = v[1], v[2]
        v[1], v[2] = x - road._offset[1], y - road._offset[1]
    end
    return t
end

-- shape = "I" / "U" / "L" / "T" / "O"
-- dir = "N" / "E" / "S" / "W"
-- t = {{x, y, shape, dir}, ...}
function road.init(w, h, offset_x, offset_y, t)
    assert(w == h)
    assert(offset_x == offset_y)
    road._offset = {offset_x, offset_y}
    iterrain.gen_terrain_field(w, h, offset_x, offset_y)
    iterrain.create_roadnet_entity(_convert_coord(t))
end

-- shape = "I" / "U" / "L" / "T" / "O"
-- dir = "N" / "E" / "S" / "W"
-- t = {{x, y, shape, dir}, ...}
function road.update(t)
    iterrain.update_roadnet_entity(_convert_coord(t))
end

-- t = {{x, y}, ...}
function road.del(t)
    iterrain.delete_roadnet_entity(_convert_coord(t))
end

return road