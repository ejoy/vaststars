local packCoord = require "construct.gameplay_entity.packcoord"

return function(building_id, tile_coord)
    local x = tile_coord[1]
    local y = tile_coord[2]

    print("logistics_center", x, y)

    return {
        station = {
			position = packCoord(x, y),
			id = building_id,
		}
    }
end
