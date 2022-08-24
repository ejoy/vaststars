#pragma once

#include "roadnet_world.h"
#include "roadnet_coord.h"
#include <map>
#include <optional>
#include <string_view>

namespace roadnet {
    class builder {
    public:
        builder();
        void    loadMap(world& w, std::string_view strmap);
        lineid  addLine(world& w, std::string_view strpath);
        lorryid addLorry(world& w, lineid lineId, uint8_t lineIdx, road_coord where);
        lorryid addLorry(world& w, lineid lineId, uint8_t lineIdx, loction l, uint8_t z);

        road_coord coordConvert(world& w, loction l, direction from, direction to, uint8_t z);
        road_coord coordConvert(world& w, map_coord  mc);
        map_coord  coordConvert(world& w, road_coord rc);

    private:
        uint8_t map[256][256];
        
        struct straightData {
            uint16_t  id;
            uint16_t  len;
            loction   loc;
            direction start_dir;
            direction finish_dir;
            roadid neighbor;
            straightData(uint16_t id, uint16_t len, loction loc, direction start_dir, direction finish_dir, roadid neighbor)
                : id(id)
                , len(len)
                , loc(loc)
                , start_dir(start_dir)
                , finish_dir(finish_dir)
                , neighbor(neighbor)
            {}
        };

        std::vector<straightData>    straightVec;
        std::map<loction, roadid>    crossMap;
        std::map<roadid, loction>    crossMapR;
        uint16_t genCrossId = 0;
        uint16_t genStraightId = 0;

        uint16_t getCrossId();
        uint16_t getStraightId();
        roadid   findCrossRoad(loction l);
        std::optional<loction> whereCrossRoad(roadid id);
    };
}
