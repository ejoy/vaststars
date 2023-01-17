#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <vector>

namespace roadnet {
    class world;
    struct road_coord;

    struct lorry {
        uint8_t tick;
        road_coord ending;
        struct where {
            uint16_t endpoint;
        };
        struct  {
            uint16_t item;
            where sell;
            where buy;
        } gameplay;
        bool nextDirection(world& w, roadid C, direction& dir);
        void initTick(uint8_t v);
        void update(world& w, uint64_t ti);
        bool ready();
    };
}
