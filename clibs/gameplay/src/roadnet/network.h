#pragma once

#include <stdint.h>
#include <optional>
#include "roadnet/road_crossroad.h"
#include "roadnet/road_straight.h"
#include "roadnet/road_endpoint.h"
#include "util/dynarray.h"

namespace roadnet {
    class network {
    public:
        network() = default;

        void init(uint8_t time, uint8_t waitTime, uint8_t crossTime);

        std::map<loction, uint8_t> getMap() const;
        void updateMap(const std::map<loction, uint8_t>& mapData);
        uint32_t reloadMap();
        lorryid    createLorry(world& w, uint16_t classid);
        void       destroyLorry(world& w, lorryid id);

        void        update(uint64_t ti);
        road::straight& StraightRoad(roadid id);
        road::crossroad& CrossRoad(roadid id);
        lorry&      Lorry(lorryid id);
        lorryid&    LorryInRoad(uint32_t index);
        road::endpoint& Endpoint(endpointid id);
        endpointid EndpointId(loction loc);

         std::optional<road_coord> coordConvert(map_coord  mc);
        std::optional<map_coord> coordConvert(road_coord rc);

        dynarray<road::crossroad> crossAry;
        dynarray<road::straight>  straightAry;
        std::vector<road::endpoint>  endpointVec;
        std::map<loction, endpointid> endpointMap;
        dynarray<lorryid>           lorryAry;
        std::vector<lorry>          lorryVec;
        std::vector<lorryid>        lorryFreeList;
        std::map<std::pair<roadid,roadid>, direction> routeMap;

        struct straightData {
            roadid    id;
            uint16_t  len;
            loction   loc;
            direction start_dir;
            direction finish_dir;
            roadid neighbor; // the next crossroad along this straight road
            straightData(roadid id, uint16_t len, loction loc, direction start_dir, direction finish_dir, roadid neighbor)
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

        uint8_t time = (uint8_t)(150);
        uint8_t waitTime = (uint8_t)(80);
        uint8_t crossTime = (uint8_t)(30);
    private:
        roadid   findCrossRoad(loction l);
        std::optional<loction> whereCrossRoad(roadid id);
    };
}
