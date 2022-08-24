#pragma once

#include "roadnet_type.h"
#include "roadnet_line.h"

namespace roadnet {
    struct world;

    using lorryid = objectid;

    struct lorry {
        uint8_t marked: 1; // avoid tick twice in one tick when moving to next location
        uint8_t tick: 7;
        uint8_t lineIdx;
        lineid lineId;
        void initLine(lineid id, uint8_t idx);
        direction getDirection(world& w);
        void nextDirection(world& w);
        void initTick(world& w, uint8_t v);
        uint8_t updateTick(world& w);
    };
}
