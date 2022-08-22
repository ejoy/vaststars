#pragma once

#include <stdint.h>
#include "roadnet_road_crossroad.h"
#include "roadnet_road_straight.h"
#include "roadnet_dynarray.h"
#include "roadnet_line.h"

namespace roadnet {
    struct world {
        static inline const uint8_t kMarkedWhite = 0;
        static inline const uint8_t kMarkedBlack = 1;

        void        update(uint64_t ti);
        basic_road& Road(roadid id);
        lorry&      Lorry(lorryid id);
        lorryid&    LorryInRoad(uint32_t index);
        line&       Line(lineid id);
        dynarray<road::crossroad> crossAry;
        dynarray<road::straight>  straightAry;
        dynarray<lorryid>         lorryAry;
        std::vector<line>         lineVec;
        std::vector<lorry>        lorryVec;
        uint8_t                   marked = kMarkedWhite;
    };
}
