#pragma once

#include <stdint.h>
#include <optional>
#include "roadnet/road_crossroad.h"
#include "roadnet/road_straight.h"
#include "roadnet/road_endpoint.h"
#include "util/dynarray.h"
#include "flatmap.h"

namespace roadnet {
    struct route_key {
        straightid S;
        straightid E;
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
        void             updateMap(flatmap<loction, uint8_t> const& map);
        uint32_t         reloadMap(flatmap<loction, uint8_t> const& map);
        lorryid          createLorry(world& w, uint16_t classid);
        void             destroyLorry(world& w, lorryid id);
        void             update(uint64_t ti);
        road::straight&  StraightRoad(straightid id);
        road::crossroad& CrossRoad(crossid id);
        lorry&           Lorry(lorryid id);
        lorryid&         LorryInRoad(uint32_t index);
        map_coord        LorryInCoord(uint32_t index);
        road::endpoint&  Endpoint(endpointid id);

        dynarray<road::crossroad>       crossAry;
        dynarray<road::straight>        straightAry;
        dynarray<road::endpoint>        endpointAry;
        dynarray<lorryid>               straightLorry;
        dynarray<map_coord>             straightCoord;
        std::vector<lorry>              lorryVec;
        std::vector<lorryid>            lorryFreeList;
        flatmap<route_key, route_value> routeCached;
    };
}
