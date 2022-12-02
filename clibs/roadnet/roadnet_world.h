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
        endpointid createEndpoint(uint8_t connection_x, uint8_t connection_y, direction connection_dir);
        bool    pushLorry(lorryid lorryId, endpointid starting, endpointid ending);
        lorryid popLorry(endpointid e);
        void placeLorry(endpointid e, lorryid l);

        void        update(uint64_t ti);
        road::straight& StraightRoad(roadid id);
        road::crossroad& CrossRoad(roadid id);
        lorry&      Lorry(lorryid id);
        lorryid&    LorryInRoad(uint32_t index);
        endpointid& EndpointInRoad(uint32_t index);
        endpoint&   Endpoint(endpointid id);

        road_coord coordConvert(map_coord  mc);
        road_coord coordConvert(loction l, direction dir, uint16_t offset = 0);
        map_coord  coordConvert(road_coord rc);

        void debugEndpointLorry();

        dynarray<road::crossroad> crossAry;
        dynarray<road::straight>  straightAry;
        dynarray<endpointid>      endpointAry;
        std::vector<endpoint>     endpointVec;
        dynarray<lorryid>         lorryAry;
        std::vector<lorry>        lorryVec;

        struct straightData {
            uint16_t  id;
            uint16_t  len;
            loction   loc;
            direction start_dir;
            direction finish_dir;
            roadid neighbor; // the next crossroad along this straight road
            straightData() {}
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
            uint8_t x;
            uint8_t y;
            direction dir;
            endpointData() {}
            endpointData(roadid id, uint16_t offset, uint8_t x, uint8_t y, direction dir)
                : id(id)
                , offset(offset)
                , x(x)
                , y(y)
                , dir(dir)
            {}
        };

        std::map<loction, uint8_t> map;
        std::vector<straightData> straightVec;
        std::map<loction, roadid> crossMap;
        std::map<roadid, loction> crossMapR;
        std::map<endpointid, road_coord> EndpointToRoadcoordMap; // temporary map, endpointid -> road_coord, used for bsf

    private:
        roadid   findCrossRoad(loction l);
        std::optional<loction> whereCrossRoad(roadid id);
        road_coord whereEndpoint(endpointid ep);
    };
}
