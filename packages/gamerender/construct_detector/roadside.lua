local ecs = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"

local __check_neighbors_road ; do
    local coord_offset = {
        N = {0, -1},
        E = {-1, 0},
        S = {0, 1},
        W = {1, 0},
    }

    function __check_neighbors_road(coord, dir, width, height)
        local offset = coord_offset[dir]
        local i = {
            coord[1] + offset[1] + (offset[1] * (width  // 2)),
            coord[2] + offset[2] + (offset[2] * (height // 2)),
        }

        return (iterrain.get_tile_building_type(i) == "road")
    end
end

local __check_building_coord ; do
    function __check_building_coord(coord, width, height)
        for x = coord[1] - (width // 2), coord[1] + (width // 2) do
            for y = coord[2] - (height // 2), coord[2] + (height // 2) do
                if iterrain.get_tile_building_type({x, y}) ~= nil  then
                    return false
                end
            end
        end

        return true
    end
end

local function __can_construct(coord, dir, width, height)
    if not __check_neighbors_road(coord, dir, width, height) then
        return false
    end

    return __check_building_coord(coord, width, height)
end

return function(position, dir, area)
    local width = area[1]
    local height = area[2]

    local coord = iterrain.get_coord_by_position(position)
    return __can_construct(coord, dir, width, height)
end
