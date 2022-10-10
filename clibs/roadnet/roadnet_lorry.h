#pragma once

#include "roadnet_type.h"
#include "roadnet_coord.h"
#include <vector>

namespace roadnet {
    struct world;
    struct road_coord;

    struct lorry {
        uint8_t marked: 1; // avoid tick twice in one tick when moving to next location
        uint8_t tick: 7;
        road_coord ending;
        uint8_t pathIdx;
        std::vector<direction> path;
        direction getDirection(world& w);
        void nextDirection(world& w);
        void initTick(world& w, uint8_t v);
        uint8_t updateTick(world& w);
    };
}
