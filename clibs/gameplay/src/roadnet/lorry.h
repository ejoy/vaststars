#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <vector>

struct world;

namespace roadnet {
    class world;
    struct road_coord;
    enum class lorry_status : uint8_t {
        want_sell,
        go_sell,
        want_buy,
        go_buy,
        want_home,
        go_home,
    };
    struct lorry {
        uint16_t capacitance = 0;
        road_coord ending;
        uint16_t item;
        uint16_t sell_endpoint;
        uint16_t buy_endpoint;
        uint8_t tick;
        lorry_status status;
        bool nextDirection(world& w, roadid C, direction& dir);
        void initTick(uint8_t tick);
        void update(world& w, uint64_t ti);
        bool ready();
        void reset(::world& w);
    };
}
