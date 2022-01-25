local ecs = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"

return function(position, _, _)
    local coord = iterrain.get_coord_by_position(position)
    if iterrain.get_tile_building_type(coord) == nil then
        return true
    else
        return false
    end
end