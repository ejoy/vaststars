#pragma once

#include "roadnet_type.h"
#include "roadnet_coord.h"
#include <vector>

namespace roadnet {
    struct world;
    struct road_coord;

    struct lorry {
        uint8_t tick;
        road_coord ending;
        uint8_t pathIdx;
        std::vector<direction> path;
        struct  {
            uint16_t item;
            uint16_t sell;
            uint16_t buy;
        } gameplay;
        direction getDirection(world& w);
        void nextDirection(world& w);
        void initTick(uint8_t v);
        void update(world& w, uint64_t ti);
        bool ready();
    };
}
