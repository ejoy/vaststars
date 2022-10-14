#pragma once

#include <stdint.h>
#include <optional>
#include "roadnet_road_crossroad.h"
#include "roadnet_road_straight.h"
#include "roadnet_endpoint.h"
#include "roadnet_dynarray.h"

namespace roadnet {
    class world {
    public:
        world() = default;

        void loadMap(const std::map<loction, uint8_t>& mapData);
        lorryid createLorry();
        endpointid createEndpoint(map_coord mc);
        bool    pushLorry(lorryid lorryId, endpointid starting, endpointid ending);
        lorryid popLorry(endpointid e);

        void        update(uint64_t ti);
        basic_road& Road(roadid id);
        lorry&      Lorry(lorryid id);
        lorryid&    LorryInRoad(uint32_t index);
        endpointid& EndpointInRoad(uint32_t index);
        endpoint&   Endpoint(endpointid id);

        road_coord coordConvert(map_coord  mc);
        map_coord  coordConvert(road_coord rc);

        dynarray<road::crossroad> crossAry;
        dynarray<road::straight>  straightAry;
        dynarray<endpointid>      endpointAry;
        std::vector<endpoint>     endpointVec;
        dynarray<lorryid>         lorryAry;
        std::vector<lorry>        lorryVec;

    private:
        uint8_t map[256][256] = {0};

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
