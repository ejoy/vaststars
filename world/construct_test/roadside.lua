local ecs = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.import.interface "vaststars|iterrain"
local construct_cfg = ecs.require "lualib.config.construct"

local function __get_building_size(building_type)
    local cfg = construct_cfg[building_type]
    if not cfg then
        return
    end

    return cfg.size
end

local __check_neighbors_road ; do
    local tile_coord_offset = {{0, -1}, {-1, 0}, {1, 0}, {0, 1}} -- top, left, right, bottom
    function __check_neighbors_road(tile_coord, width, height)
        local coord

        -- the spec grid's building type must be 'road'
        for _, coord_offset in ipairs(tile_coord_offset) do
            coord = {
                tile_coord[1] + coord_offset[1],
                tile_coord[2] + coord_offset[2],
            }

            if coord_offset[1] ~= 0 then
                coord[1] = coord[1] + (coord_offset[1] * (width - 1))
            end
            if coord_offset[2] ~= 0 then
                coord[2] = coord[2] + (coord_offset[2] * (height - 1))
            end

            if iterrain.get_tile_building_type(coord) == "road" then
                return true
            end
        end

        return false
    end
end

local __check_building_coord ; do
    function __check_building_coord(tile_coord, width, height)
        local coord
        for i = 0, width do
            for j = 0, height do
                coord = {
                    tile_coord[1] + i,
                    tile_coord[2] + j,
                }

                if iterrain.get_tile_building_type(coord) ~= nil  then
                    return false
                end
            end
        end

        return true
    end
end

-- tile_coord : topleft
local function __can_construct(tile_coord, width, height)
    if not __check_neighbors_road(tile_coord, width, height) then
        return false
    end

    return __check_building_coord(tile_coord, width, height)
end

return function(building_type, position)
    local size = __get_building_size(building_type)
    if not size then
        print(("Cannot found building_type(%s)"):format(building_type))
        return false
    end

    local width = size[1]
    local height = size[2]

    local coord = iterrain.get_coord_by_position(position)
    coord[1] = coord[1] - (width // 2)
    coord[2] = coord[2] - (height // 2)

    return __can_construct(coord, width, height)
end