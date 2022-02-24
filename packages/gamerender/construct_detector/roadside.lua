local ecs = ...
local world = ecs.world
local w = world.w

local dir = require "dir"
local dir_offset_of_entry = dir.offset_of_entry
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"

local check_entry_road ; do
    function check_entry_road(coord, dir, width, height)
        local offset = dir_offset_of_entry(dir)
        local i = {
            coord[1] + offset[1] + (offset[1] * (width // 2)),
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
    if not check_entry_road(coord, dir, width, height) then
        return false
    end

    return __check_building_coord(coord, width, height)
end

return function(position, dir, area)
    local width, height = igameplay_adapter.unpack_coord(area)
    local coord = iterrain.get_coord_by_position(position)
    return __can_construct(coord, dir, width, height)
end
