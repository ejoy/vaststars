#pragma once

#include <stdint.h>
#include <optional>
#include "roadnet/road_crossroad.h"
#include "roadnet/road_straight.h"
#include "roadnet/road_endpoint.h"
#include "util/dynarray.h"
#include "util/flatmap.h"

namespace roadnet {
    struct route_key {
        roadid S;
        roadid E;
        bool operator==(const route_key& rhs) const {
            return S == rhs.S && E == rhs.E;
        }
    };
    struct route_value {
        uint16_t dir : 2;
        uint16_t n : 14;
    };

    class network {
    public:
        network() = default;

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

        std::optional<road_coord> coordConvert(map_coord  mc);
        std::optional<map_coord> coordConvert(road_coord rc);

        dynarray<road::crossroad> crossAry;
        dynarray<road::straight>  straightAry;
        std::vector<road::endpoint>  endpointVec;
        dynarray<lorryid>           lorryAry;
        std::vector<lorry>          lorryVec;
        std::vector<lorryid>        lorryFreeList;
        flatmap<route_key, route_value> routeMap;

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
    private:
        void setEndpoint(loction loc, direction a, direction b, uint16_t straightId);
        roadid   findCrossRoad(loction l);
    };
}
