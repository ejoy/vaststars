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
        void loadMap(world& w, const std::map<loction, uint8_t>& mapData);

        lorryid createLorry(world& w);
        endpointid createEndpoint(world& w);
        bool    pushLorry(world& w, lorryid lorryId, endpointid starting, endpointid ending);
        lorryid popLorry(world& w, endpointid e);

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
            roadid neighbor; // the next crossroad along this straight road
            straightData(uint16_t id, uint16_t len, loction loc, direction start_dir, direction finish_dir, roadid neighbor)
                : id(id)
                , len(len)
                , loc(loc)
                , start_dir(start_dir)
                , finish_dir(finish_dir)
                , neighbor(neighbor)
            {}
        };

        struct endpointData {
            roadid id;
            uint16_t offset;
            endpointid eid;
            endpointData(roadid id, uint16_t offset, endpointid eid)
                : id(id)
                , offset(offset)
                , eid(eid)
            {}
        };

        std::vector<straightData> straightVec;
        std::vector<endpointData> endpointDataVec;
        std::map<loction, roadid> crossMap;
        std::map<roadid, loction> crossMapR;

        roadid   findCrossRoad(loction l);
        std::optional<loction> whereCrossRoad(roadid id);
    };
}
