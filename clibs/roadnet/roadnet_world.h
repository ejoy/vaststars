#pragma once

#include <stdint.h>
#include "roadnet_road_crossroad.h"
#include "roadnet_road_straight.h"
#include "roadnet_endpoint.h"
#include "roadnet_dynarray.h"

namespace roadnet {
    struct world {
        void        update(uint64_t ti);
        basic_road& Road(roadid id);
        lorry&      Lorry(lorryid id);
        lorryid&    LorryInRoad(uint32_t index);
        dynarray<road::crossroad>   crossAry;
        dynarray<road::straight>    straightAry;
        dynarray<endpointManager> endpointsAry;
        dynarray<lorryid>         lorryAry;
        std::vector<lorry>        lorryVec;
    };
}
