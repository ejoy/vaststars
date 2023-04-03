#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <vector>

struct world;
struct lua_State;

namespace roadnet {
    class network;
    struct road_coord;
    struct lorry {
        uint32_t capacitance;
        roadid ending;
        uint16_t classid;
        uint16_t item_classid;
        uint16_t item_amount;
        uint8_t tick;
        bool nextDirection(network& w, roadid C, direction& dir);
        void initTick(uint8_t tick);
        void update(network& w, uint64_t ti);
        bool ready();
        void reset(world& w);
        void init(world& w, uint16_t classid);
    };
}
