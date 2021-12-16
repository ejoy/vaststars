local packCoord = require "construct.gameplay_entity.packcoord"

return function(building_id, tile_coord)
    local x = tile_coord[1]
    local y = tile_coord[2]

    print("road", x, y)

    return {
        entity = {
            position = packCoord(x, y),
            prototype = 0,
            direction = 0,
        },
        road = true,
    }
end
